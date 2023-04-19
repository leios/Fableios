using Fable, Images, LolliPeople

function check_example(num_particles, num_iterations;
                       height = 2.0, ArrayType = Array, num_frames = 10,
                       transform_type = :check, filename = "out.png")
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    if transform_type == :check
        lolli = LolliPerson(height; ArrayType = ArrayType,
                            num_particles = num_particles,
                            num_iterations = num_iterations)
        run!(lolli)
        write_image([bg, lolli]; filename = filename)
    elseif transform_type == :check_video
        lolli = LolliPerson(height; ArrayType = ArrayType,
                            num_particles = num_particles,
                            num_iterations = num_iterations)
        video_out = open_video(res; framerate = 30, filename = "out.mp4")
        for i = 1:num_frames
            run!(lolli)
            write_video!(video_out, [bg, lolli])
        end

        close_video(video_out)
    end

end

@info("Created function check_example(num_particles, num_iterations;
                                     height = 2.0,
                                     ArrayType = Array,
                                     num_frames = 10,
                                     transform_type = :check,
                                     filename = 'out.png')\n"*
      "transform_type can be {:check, :check_video}")
