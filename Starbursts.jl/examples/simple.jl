using Fable, Images, Starbursts

function simple_example(num_particles, num_iterations; shape = :rectangle,
                        ArrayType = Array, num_frames = 10,
                        output_type = :video, shape_color = Shaders.black)

    world_size = (9, 16)
    ppu = 1920 / 16
    res = (1080, 1920)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType, ppu = ppu,
                    world_size = world_size)

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = "out.mp4")
    end

    # Amaras said no to this, but it would have been fun, so I'll do it when 
    # they are no longer around...
    #eval(Symbol("define_$shape"))(1)

    if shape == :rectangle || shape == :square
        object = define_rectangle(color = shape_color)
    elseif shape == :circle
        object = define_rectangle(color = shape_color)
    elseif shape == :triangle
        object = define_rectangle(color = shape_color)
    else
        error("No object of type " * string(shape) *" available")
    end

    starburst = simple_starburst(start_frame = 1, end_frame = 10)
    starburst_transform = Hutchinson(starburst, Shaders.black(), 1.0)
    layer = FractalLayer(; ArrayType = ArrayType, logscale = false,
                         world_size = world_size, ppu = ppu,
                         H1 = object, H2 = starburst_transform,
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
    end

    if output_type == :video
        close_video(video_out)
    end

end

@info("Created function simple_example(num_particles, num_iterations;
                                      ArrayType = Array,
                                      num_frames = 10,
                                      shape = :rectangle,
                                      shape_color = Shaders.black,
                                      output_type = :video)\n"*
      "shapes can be {:square, rectangle, circle, triangle}")
