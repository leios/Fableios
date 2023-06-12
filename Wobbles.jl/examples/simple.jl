using Fable, Images, Starbursts

function simple_example(num_particles, num_iterations;
                        shape = define_circle(color = Shaders.black),
                        ArrayType = Array, num_frames = 10,
                        output_type = :video,
                        wobble = speed_wobble, 
                        wobble_color = Shaders.black,
                        wobble_direction = 0.0,
                        max_wobble = 1.0)

    world_size = (9, 16)
    ppu = 1920 / 16
    res = (1080, 1920)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType, ppu = ppu,
                    world_size = world_size)

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = "out.mp4")
    end

    wobble_factor = fi("wobble_factor", 0.0)
    wobble_transform = wobble(wobble_factor = wobble_factor,
                              wobble_direction = wobble_direction)
    layer = FractalLayer(; ArrayType = ArrayType, logscale = false,
                         world_size = world_size, ppu = ppu,
                         H1 = shape, H2 = wobble_transform,
                         num_particles = num_particles,
                         num_iterations = num_iterations)

    for i = 1:num_frames
        run!(layer)
        set!(wobble_factor, max_wobble*i/num_frames)

        if output_type == :video
            write_video!(video_out, [bg, layer])
        else
            filename = "out"*lpad(i, 3, "0")*".png"
            write_image([bg, layer]; filename = filename)
        end
    end

    if output_type == :video
        close_video(video_out)
    end

end

@info("Created function simple_example(num_particles, num_iterations;
                                      shape = define_circle(...),
                                      ArrayType = Array, num_frames = 10,
                                      output_type = :video,
                                      wobble = speed_wobble, 
                                      wobble_color = Shaders.black,
                                      wobble_direction = 0.0,
                                      max_wobble = 1.0)\n"*
      "output_type can be {:image, :video}\n"*
      "wobble can be any defined starburst such as {speed_wobble,
                                                simple_airfoil}")
