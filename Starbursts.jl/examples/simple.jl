using Fable, Images, Starbursts

function simple_example(num_particles, num_iterations;
                        shape = define_rectangle(color = Shaders.black),
                        ArrayType = Array, num_frames = 10,
                        output_type = :video,
                        starburst = simple_starburst, 
                        starburst_color = Shaders.black)

    world_size = (9, 16)
    ppu = 1920 / 16
    res = (1080, 1920)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType, ppu = ppu,
                    world_size = world_size)

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = "out.mp4")
    end

    starburst = starburst(start_frame = 1, end_frame = num_frames,
                          translation = (0.5, 1.5))
    starburst_transform = Hutchinson(starburst, starburst_color, 1.0)
    layer = FractalLayer(; ArrayType = ArrayType, logscale = false,
                         world_size = world_size, ppu = ppu,
                         H1 = shape, H2 = starburst_transform,
                         num_particles = num_particles,
                         num_iterations = num_iterations)

    for i = 1:num_frames
        run!(layer; frame = i)

        if output_type == :video
            write_video!(video_out, [bg, layer])
        else
            filename = "out"*lpad(i, 3, "0")*".png"
            write_image([bg, layer]; filename = filename)
        end
        reset!(layer)
        reset!(bg)
    end

    if output_type == :video
        close_video(video_out)
    end

end

@info("Created function simple_example(num_particles, num_iterations;
                                      ArrayType = Array, num_frames = 10,
                                      output_type = :video, 
                                      starburst = simple_starburst, 
                                      starburst_color = Shaders.black)\n"*
      "shapes can be {:square, rectangle, circle, triangle}")
