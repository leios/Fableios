export LolliLayer, LolliPerson


function params(a::Type{LolliLayer}; numthreads = 256, numcores = 4,
                ArrayType = Array, FloatType = Float32,
                logscale = false, gamma = 2.2, calc_max_value = false,
                max_value = 1, num_ignore = 20, num_particles = 1000,
                num_iterations = 1000, dims = 2, solver_type = :random,
                size = 1.0,
                head_position = (-0.25*size, 0.0), head_radius = size*0.25,
                foot_position = (0.5*size, 0.0), body_width = 0.1*size,
                body_height = 0.45*size, body_position = (0.275*size, 0.0))

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
            size = size,
            head_position = head_position,
            head_radius = head_radius,
            foot_position = foot_position,
            body_width = body_width,
            body_height = body_height,
            body_position = body_position)
end

function LolliLayer(; size = 1.0,
                      head_position = (-0.25*size, 0.0),
                      head_radius = size*0.25,
                      foot_position = (0.5*size, 0.0),
                      body_width = 0.1*size,
                      body_height = 0.45*size,
                      body_position = (0.275*size, 0.0),
                      body_color = Shaders.black,
                      ArrayType = Array,
                      ppu = 1200,
                      world_size = (0.9, 1.6),
                      num_particles = 1000,
                      num_iterations = 1000,
                      postprocessing_steps = Vector{AbstractPostProcess}([]),
                      eye_fum::Union{FractalUserMethod, Nothing} = nothing,
                      head_transforms = nothing,
                      body_transforms = nothing,
                      additional_fis = Vector{FractalInput}([]),
                      set_as_fis = false)
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
                              inter_eye_distance = size * 0.15,
                              size = size)
    end

    postprocessing_steps = vcat([CopyToCanvas()], postprocessing_steps)
    layer_position = (foot_position[1] - size*0.5, foot_position[2])
    body = define_rectangle(; position = body_position,
                              rotation = 0.0,
                              scale_x = body_width,
                              scale_y = body_height,
                              color = body_color)

    head = define_circle(; position = head_position,
                           radius = head_radius,
                           color = (body_color, eye_fum))

    H = Hutchinson([body, head])
    if isnothing(body_transforms)
        H_post = nothing
    elseif isnothing(head_transforms)
        H_post = nothing
    else
        H_post = Hutchinson([fo(body_transforms), fo(head_transforms)])
    end
    layer = FractalLayer(num_particles = num_particles,
                         num_iterations = num_iterations,
                         ppu = ppu, world_size = world_size,
                         position = layer_position, ArrayType = ArrayType,
                         H = H, H_post = H_post)

    return LolliLayer(layer, head, head_transforms,
                      body, body_transforms, eye_fum, body_color,
                      layer_position, world_size, ppu, p,
                      postprocessing_steps, additional_fis)


end

function set_transforms!(lolli::LolliLayer, fum::FractalUserMethod;
                         layer = :both, additional_fis = FractalInput[])
    set_transforms!(lolli, fo(fum, Shaders.previous); layer = layer,
                    additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer, fums::Vector{FUM};
                         additional_fis = FractalInput[],
                         layer = :both) where FUM <: FractalUserMethod
    set_transforms!(lolli,
                    [fo(fums[i], Shaders.previous) for i = 1:length(fums)];
                    layer = layer, additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer,
                         fum::FractalUserMethod, color_fum::FractalUserMethod;
                         layer = :both, additional_fis = FractalInput[])
    fo = fractalOperator(fum, color_fum)
    set_transforms!(lolli, fo; layer = layer, additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer,
                         fums::Vector{FractalUserMethod},
                         color_fums::Vector{FractalUserMethod},
                         layer = :both, additional_fis = FractalInput[])
    fos = [fractalOperator(fums[i], color_fums[i]) for i = 1:length(fums)]
    set_transforms!(lolli, fos; layer = layer, additional_fis = additional_fis)
end

function set_transforms!(lolli::LolliLayer, fo::FractalOperator; layer = :both,
                         additional_fis = FractalInput[])
    H = Hutchinson(fo)
    if layer == :head
        lolli.head_transforms = H
    elseif layer == :body
        lolli.body_transforms = H
    else
        lolli.head_transforms = H
        lolli.body_transforms = H
    end

    rebuild_operators(lolli)

    if length(additional_fis) > 0
        lolli.additional_fis = vcat(lolli.additional_fis, additional_fis)
    end

end

function set_transforms!(lolli::LolliLayer, fos::Vector{FractalOperator};
                         layer = :both, additional_fis = FractalInput[])
    H = Hutchinson(fos)
    if layer == :head
        lolli.head_transforms = H
    elseif layer == :body
        lolli.body_transforms = H
    else
        lolli.head_transforms = H
        lolli.body_transforms = H
    end

    rebuild_operators(lolli)

    if length(additional_fis) > 0
        lolli.additional_fis = vcat(lolli.additional_fis, additional_fis)
    end
end

function reset_transforms!(lolli; layer = :both)
    if layer == :head
        lolli.head_transforms = fo(Smears.null, Shaders.null)
        lolli.layer.H_post = Hutchinson([fo(lolli.body_transforms),
                                         fo(lolli.head_transforms)])
    elseif layer == :body
        lolli.body_transforms = fo(Smears.null, Shaders.null)
        lolli.layer.H_post = Hutchinson([fo(lolli.body_transforms),
                                         fo(lolli.head_transforms)])
    else
        lolli.head_transforms = nothing
        lolli.body_transforms = nothing
        lolli.layer.H_post = nothing
    end

end

function rebuild_operators(lolli)
    H = Hutchinson([lolli.body, lolli.head])
    H_post = Hutchinson([fo(lolli.body_transforms),
                         fo(lolli.head_transforms)])
    lolli.layer.H = H
    lolli.layer.H_post = H_post
end
