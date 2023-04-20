export LolliLayer, LolliPerson

function LolliLayer(height; angle=0.0, foot_position=(height*0.5,0.0),
                    body_multiplier = min(1, height),
                    eye_color = Shaders.white, body_color = Shaders.black,
                    head_position = (-height*1/4, 0.0),
                    head_radius = height*0.25,
                    name = "", ArrayType = Array,
                    known_operations = [],
                    ppu = 1200, world_size = (0.9, 1.6),
                    num_particles = 1000, num_iterations = 1000,
                    postprocessing_steps = Vector{AbstractPostProcess}([]),
                    eye_fum::Union{FractalUserMethod, Nothing} = nothing,
                    head_smears = Vector{FractalOperator}([]),
                    body_smears = Vector{FractalOperator}([]),
                    additional_fis = Vector{FractalInput}([]))

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
                              inter_eye_distance = height * 0.15,
                              size = height*0.08)
    end

    postprocessing_steps = vcat([CopyToCanvas()], postprocessing_steps)
    offset = 0.1*body_multiplier
    layer_position = (foot_position[1] - height*0.5, foot_position[2])
    body = define_rectangle(; position = foot_position .- (height*0.25, 0),
                              rotation = 0.0,
                              scale_x = 0.1*body_multiplier,
                              scale_y = 0.5*height-offset,
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
    return LolliLayer(head_layer, eye_fum, body_layer, angle, foot_position,
                      height, body_color, nothing, nothing, nothing,
                      canvas, layer_position, world_size, ppu,
                      params(LolliLayer; ArrayType = ArrayType),
                      postprocessing_steps, additional_fis)
    
end
