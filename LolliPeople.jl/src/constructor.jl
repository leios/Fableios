export LolliLayer, LolliPerson, set_transforms!, rebuild_operators!

function create_lolli_Hs(transforms, post_transforms)

    kept_transforms = FableOperator[]
    keep_post_transforms = false
    if !minimum(isnothing.(post_transforms))
        keep_post_transforms = true
        kept_post_transforms = FableOperator[]
    else
        H_post = nothing
    end

    for i = 1:length(transforms)
        if !isnothing(transforms[i])
            push!(kept_transforms, fo(transforms[i]))
            if keep_post_transforms
                push!(kept_post_transforms, fo(post_transforms[i]))
            end
        end
    end

    H = Hutchinson(kept_transforms)
    if keep_post_transforms
        H_post = Hutchinson(kept_post_transforms)
    end

    return H, H_post
end

function params(a::Type{LolliLayer}; numthreads = 256, numcores = 4,
                ArrayType = Array, FloatType = Float32,
                logscale = false, gamma = 2.2, calc_max_value = false,
                max_value = 1, num_ignore = 20, num_particles = 1000,
                num_iterations = 1000, dims = 2, solver_type = :random,
                scale = 1.0,
                head_position = (-0.25*scale, 0.0), head_radius = scale*0.25,
                foot_position = (0.5*scale, 0.0), body_width = 0.1*scale,
                body_height = 0.45*scale, body_position = (0.275*scale, 0.0))

    return (numthreads = numthreads,
            numcores = numcores,
            ArrayType = ArrayType,
            FloatType = FloatType,
            logscale = logscale,
            gamma = gamma,
            max_value = max_value,
            calc_max_value = calc_max_value,
            num_ignore = num_ignore,
            num_particles = num_particles,
            num_iterations = num_iterations,
            dims = dims,
            solver_type = solver_type,
            scale = scale,
            head_position = head_position,
            head_radius = head_radius,
            foot_position = foot_position,
            body_width = body_width,
            body_height = body_height,
            body_position = body_position)
end

function LolliLayer(; scale = 1.0,
                      head_position = (-0.25*scale, 0.0),
                      head_radius = scale*0.25,
                      foot_position = (0.5*scale, 0.0),
                      body_width = 0.1*scale,
                      body_height = 0.45*scale,
                      body_position = (0.275*scale, 0.0),
                      body_color = Shaders.black,
                      ArrayType = Array,
                      ppu = 1200,
                      world_size = (0.9, 1.6),
                      num_particles = 1000,
                      num_iterations = 1000,
                      postprocessing_steps = Vector{AbstractPostProcess}([]),
                      eye_fum::Union{FableUserMethod, Nothing} = nothing,
                      head_transforms = nothing,
                      body_transforms = nothing,
                      additional_fis = Vector{FableInput}([]),
                      set_as_fis = false,
                      pre_objects::Union{Vector, Tuple} = [nothing],
                      post_objects::Union{Vector, Tuple} = [nothing],
                      pre_object_transforms::Union{Vector, Tuple} = [nothing],
                      post_object_transforms::Union{Vector, Tuple} = [nothing])
    if set_as_fis
        head_position = fi(:head_position, value(head_po)sition)
        head_radius = fi(:head_radius, value(head_radius))
        foot_position = fi(:foot_position, value(foot_position))
        body_width = fi(:body_width, value(body_width)[2])
        body_height = fi(:body_height, value(body_height)[1])
        body_position = fi(:body_position, value(body_position))
    end

    p = params(LolliLayer; ArrayType = ArrayType,
                           head_position = head_position,
                           head_radius = head_radius,
                           foot_position = foot_position,
                           body_width = body_width,
                           body_height = body_height,
                           body_position = body_position)

    if eye_fum == nothing
        eye_fum = simple_eyes(head_position = head_position,
                              inter_eye_distance = scale * 0.15,
                              scale = scale)
    end

    postprocessing_steps = vcat([CopyToCanvas()], postprocessing_steps)
    layer_position = (foot_position[1] - scale*0.5, foot_position[2])
    body = create_rectangle(; position = body_position,
                              rotation = 0.0,
                              scale_x = body_width,
                              scale_y = body_height,
                              color = body_color)

    head = create_circle(; position = head_position,
                           radius = head_radius,
                           color = (body_color, eye_fum))

    H, H_post = create_lolli_Hs([pre_objects..., body, head, post_objects...],
                                [pre_object_transforms..., body_transforms,
                                 head_transforms, post_object_transforms...])

    layer = FableLayer(num_particles = num_particles,
                         num_iterations = num_iterations,
                         ppu = ppu, world_size = world_size,
                         position = layer_position, ArrayType = ArrayType,
                         H = H, H_post = H_post, overlay = true)

    return LolliLayer(layer, head, head_transforms,
                      body, body_transforms,
                      pre_objects, pre_object_transforms,
                      post_objects, post_object_transforms,
                      eye_fum, body_color, layer_position, world_size, ppu, p,
                      postprocessing_steps, additional_fis)

end

function set_transforms!(lolli::LolliLayer, fum::FableUserMethod;
                         layers = [:head, :body],
                         additional_fis = FableInput[])
    set_transforms!(lolli, fo(fum, Shaders.previous); layers,
                    additional_fis)
end

function set_transforms!(lolli::LolliLayer, fums::Vector{FUM};
                         additional_fis = FableInput[],
                         layers = [:head, :body]) where FUM <: FableUserMethod
    set_transforms!(lolli,
                    [fo(fums[i], Shaders.previous) for i = 1:length(fums)];
                    layers = layers, additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer,
                         fum::FableUserMethod, color_fum::FableUserMethod;
                         layers = [:head, :body],
                         additional_fis = FableInput[])
    fo = fractalOperator(fum, color_fum)
    set_transforms!(lolli, fo; layers = layers, additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer,
                         fums::Vector{FableUserMethod},
                         color_fums::Vector{FableUserMethod},
                         layers = [:head, :body],
                         additional_fis = FableInput[])
    fos = [fractalOperator(fums[i], color_fums[i]) for i = 1:length(fums)]
    set_transforms!(lolli, fos; layers, additional_fis)
end

function set_transforms!(lolli::LolliLayer, fo::FableOperator;
                         layers = [:head, :body],
                         additional_fis = FableInput[])
    for i = 1:length(layers)
        if layers[i] == :head
            lolli.head_transforms = fo
        elseif layers[i] == :body
            lolli.body_transforms = fo
        elseif layers[i] == :pre_objects
            lolli.pre_object_transforms = fo
        elseif layers[i] == :post_objects
            lolli.post_object_transforms = fo
        elseif layers[i] == :all
            lolli.head_transforms = fo
            lolli.body_transforms = fo
            lolli.pre_object_transforms = fo
            lolli.post_object_transforms = fo
        else
            @warn("Layer "*string(layers[i])*"not available! Skipping...")
        end
    end

    rebuild_operators!(lolli)

    if length(additional_fis) > 0
        lolli.additional_fis = vcat(lolli.additional_fis, additional_fis)
    end

end

function set_transforms!(lolli::LolliLayer, fos::Vector{FableOperator};
                         layers = [:head, :body],
                         additional_fis = FableInput[])
    for i = 1:length(layers)
        if layers[i] == :head
            lolli.head_transforms = fos
        elseif layers[i] == :body
            lolli.body_transforms = fos
        elseif layers[i] == :pre_objects
            lolli.pre_object_transforms = fos
        elseif layers[i] == :post_objects
            lolli.post_object_transforms = fos
        elseif layers[i] == :all
            lolli.head_transforms = fos
            lolli.body_transforms = fos
            lolli.pre_object_transforms = fos
            lolli.post_object_transforms = fos
        else
            @warn("Layer "*string(layers[i])*"not available! Skipping...")
        end
    end

    rebuild_operators!(lolli)

    if length(additional_fis) > 0
        lolli.additional_fis = vcat(lolli.additional_fis, additional_fis)
    end
end

function reset_transforms!(lolli; layers = [:head, :body])
    for i = 1:length(layers)
        if layers[i] == :head
            lolli.head_transforms = fo(Smears.null, Shaders.null)
        elseif layers[i] == :body
            lolli.body_transforms = fo(Smears.null, Shaders.null)
        elseif layers[i] == :pre_objects
            lolli.pre_object_transforms = fo(Smears.null, Shaders.null)
        elseif layers[i] == :post_objects
            lolli.post_object_transforms = fo(Smears.null, Shaders.null)
        elseif layers[i] == :all
            lolli.head_transforms = nothing
            lolli.body_transforms = nothing
            lolli.pre_object_transforms = nothing
            lolli.post_object_transforms = nothing
            lolli.layer.H_post = nothing
        else
            @warn("Layer "*string(layers[i])*"not available! Skipping...")
        end
    end

    rebuild_operators!(lolli)

end

function rebuild_operators!(lolli)
    H, H_post = create_lolli_Hs([lolli.pre_objects...,
                                 lolli.body, lolli.head,
                                 lolli.post_objects...],
                                [lolli.pre_object_transforms...,
                                 lolli.body_transforms,
                                 lolli.head_transforms,
                                 lolli.post_object_transforms...])
    lolli.layer.H = H
    lolli.layer.H_post = H_post
end
