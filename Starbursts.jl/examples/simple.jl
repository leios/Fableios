using Fable, Images, Starbursts

function simple_example(num_particles, num_iterations; shape = :rectangle,
                        ArrayType = Array, num_frames = 10,
                        output_type = :video, shape_color = Shaders.black)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

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

    starburst = StarburstLayer(shape = object, transform = :simple,
                               ArrayType = ArrayType)

    for i = 1:num_frames
        run!(starburst; frame = i)

        if output_type == :video
            write_video!(video_out, [bg, starburst])
        else
            filename = "out"*lpad(i, 3, "0")*".png"
            write_image([bg, starburst]; filename = filename)
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
                                      output_type = :video)\n"*
      "shapes can be {:square, rectangle, circle, triangle}")
