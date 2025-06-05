
function scene_1(num_particles, num_iterations; ArrayType = Array,
                 start_time = 0, end_time = 1/Fable.FPS,
                 filebase = "output/out",
                 world_size = (9*0.125, 16*0.125),
                 ppu = 1920/world_size[2])

    keyframes =  Dict("mom" => 1.333333,
                      "stars" => 2.333333,
                      "comet" => 3.161616,
                      "rings" => 3.66666,
                      "kinda" => 7.266)
    mom_image = ArrayType{RGBA{Float32}}(load("res/not_to_scale.png"))
    mom_layer = ImageLayer(mom_image;
                           ppu = ppu, ArrayType = ArrayType)
    kinda_image = ArrayType{RGBA{Float32}}(load("res/kinda.png"))
    kinda_layer = ImageLayer(kinda_image;
                             ppu = ppu, ArrayType = ArrayType)

    # Define fable inputs
    planet_rotation = fi("planet_rotation", 0)
    star_scale = fi("star_scale", 1)
    ring_wobble = fi("ring_wobble", -0.2*pi)
    comet_angle = fi("comet_angle", 0.25*pi)
    ring_radius = fi("ring_radius", 0.425)
    comet_wiggle_amplitude = fi("comet_wiggle_amplitude", 0.0)

    circle = define_circle(radius = 0.3, color = Shaders.white)
    fo_1 = fo((stars, scale(scale_factor = star_scale)),
              (Shaders.white, Shaders.previous), (0.5, 0.5))
    fo_2 = fo((Smears.null, planet_swirl(global_rotation = planet_rotation),
               Smears.null),
              (base_planet_color, Shaders.previous,  planet_glow),
              (0.33, 0.33, 0.34))
    fo_3 = fo((Smears.null, make_disk(radius = ring_radius), project_disk, rotate(angle = ring_wobble)),
              (color_disk, Shaders.previous, Shaders.previous, color_projected_disk(angle = ring_wobble)),
              (0.25, 0.25, 0.25, 0.25))
    fo_4 = fo((Smears.null, comet_shape(comet_angle = comet_angle),
               comet_wiggle(wiggle_amplitude = comet_wiggle_amplitude)),
              (comet_fire, comet_hole(comet_angle = comet_angle),
               Shaders.previous),
              (0.33, 0.33, 0.34))

    transformations = Hutchinson((fo_1, fo_2, fo_4))

    H = Hutchinson((circle, circle, circle))

    flayer = FableLayer(num_particles = num_particles,
                        num_iterations = num_iterations,
                        H = H, H_post = transformations,
                        ppu = ppu,
                        world_size = world_size,
                        ArrayType = ArrayType,
                        overlay = true)

    r_transforms = fo_3
    r_H = circle

    rlayer = FableLayer(num_particles = num_particles,
                        num_iterations = num_iterations,
                        H = r_H, H_post = r_transforms,
                        ppu = ppu,
                        world_size = world_size,
                        ArrayType = ArrayType,
                        overlay = true)

    clayer = ShaderLayer(background_texture;
                         ArrayType = ArrayType,
                         world_size = world_size,
                         ppu = ppu)

    curr_time = start_time
    while curr_time < keyframes["kinda"] && curr_time < end_time

        set!(planet_rotation, 0.5*curr_time*2*pi)
        set!(ring_wobble, (-0.1*pi)+0.1*sin(0.5*curr_time*2*pi))
        set!(comet_angle, -(0.5*curr_time*2*pi))

        run!(clayer)
        run!(flayer)
        run!(rlayer)

        if curr_time > keyframes["stars"] &&
           curr_time < keyframes["stars"] + 1
            x = curr_time - keyframes["stars"]
            set!(star_scale, 1 + 0.02*sin(3*pi*x*x)/(x+0.01))
        end

        if curr_time > keyframes["comet"] &&
           curr_time < keyframes["comet"] + 0.5
            x = 2*(curr_time - keyframes["comet"])
            set!(comet_wiggle_amplitude, 0.02 * x)
        elseif curr_time > keyframes["comet"] + 0.5 &&
           curr_time < keyframes["comet"] + 1
            x = 2*(keyframes["comet"]+1-curr_time)
            set!(comet_wiggle_amplitude, 0.02 * x)
        elseif value(comet_wiggle_amplitude) != 0
            set!(comet_wiggle_amplitude, 0)
        end

        if curr_time > keyframes["rings"] &&
           curr_time < keyframes["rings"] + 1
            x = curr_time - keyframes["rings"]
            set!(ring_radius, 0.425 + 0.02*sin(3*pi*x*x)/(x+0.01))
        end

        curr_frame = round(Int,curr_time * Fable.FPS)
        filename = filebase*lpad(string(curr_frame),5,"0")*".png"
        if curr_time > keyframes["mom"] &&
           curr_time < keyframes["mom"] + 0.5

            write_image([clayer, flayer, rlayer, mom_layer];
                        filename = filename, reset = false)
            reset!([clayer, flayer, rlayer])
        else
            write_image([clayer, flayer, rlayer];
                        filename = filename)
        end

        curr_time += 1/Fable.FPS

    end
    while curr_time < end_time
        curr_frame = round(Int,curr_time * Fable.FPS)
        filename = filebase*lpad(string(curr_frame),5,"0")*".png"
        curr_time += 1/Fable.FPS
        write_image(kinda_layer; filename = filename, reset = false)
    end

end
