using Fable, Wobbles, Colors

function crunch_example(num_particles, num_iterations;
                        ArrayType = Array, num_frames = 10,
                        output_type = :video,
                        wobble_direction = 0.0,
                        object_height = 2, object_width = 0.5)

    shape = define_rectangle(color = Shaders.black,
                             scale_y = object_height, scale_x = 0.1)

    world_size = (9, 16)
    ppu = 1920 / 16
    res = (1080, 1920)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType, ppu = ppu,
                    world_size = world_size)

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = "out.mp4")
    end

    splat_factor = fi("splat_factor", 1.0)
    wobble_transform = crunch(splat_factor = splat_factor,
                              wobble_direction = wobble_direction,
                              object_height = object_height,
                              object_width = object_width)
    H_post = Hutchinson(wobble_transform, Shaders.previous, 1.0)
    layer = FractalLayer(; ArrayType = ArrayType, logscale = false,
                         world_size = world_size, ppu = ppu,
                         H = shape, H_post = H_post,
                         num_particles = num_particles,
                         num_iterations = num_iterations)

    for i = 1:num_frames
        run!(layer)
        set!(splat_factor, 1-0.75*(i)/num_frames)

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

@info("Created function crunch_example(num_particles, num_iterations;
                                      ArrayType = Array, num_frames = 10,
                                      output_type = :video,
                                      wobble_direction = 0.0,
                                      object_height = 2, object_width = 0.5)\n"*
      "output_type can be {:image, :video}")

