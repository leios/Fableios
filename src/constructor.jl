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
                      head_smears = Vector{FractalOperator}([]),
                      body_smears = Vector{FractalOperator}([]),
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

    H2_head = nothing
    H2_body = nothing

    if length(head_smears) > 0
        H2_head = Hutchinson()
        for i = 1:length(head_smears)
            H2_head = Hutchinson(H2_head, Hutchinson(head_smears[i]))
        end
    end

    if length(body_smears) > 0
        H2_body = Hutchinson()
        for i = 1:length(body_smears)
            H2_body = Hutchinson(H2_body, Hutchinson(body_smears[i]))
        end
    end

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

    body_layer = FractalLayer(num_particles = num_particles,
                              num_iterations = num_iterations,
                              ppu = ppu, world_size = world_size,
                              position = layer_position, ArrayType = ArrayType,
                              H1 = body, H2 = H2_body)

    head = define_circle(; position = head_position,
                           radius = head_radius,
                           color = (body_color, eye_fum))

    head_layer = FractalLayer(num_particles = num_particles,
                              num_iterations = num_iterations,
                              ppu = ppu, world_size = world_size,
                              position = layer_position, ArrayType = ArrayType,
                              H1 = head, H2 = H2_head)

    canvas = copy(head_layer.canvas)
    return LolliLayer(head_layer, eye_fum, body_layer, body_color,
                      canvas, layer_position, world_size, ppu, p,
                      postprocessing_steps, additional_fis)


end
