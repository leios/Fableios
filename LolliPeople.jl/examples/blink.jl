using Fable, Images, LolliPeople

function blink_example(num_particles, num_iterations;
                       height = 0.5, brow_height = 0.5,
                       ArrayType = Array, num_frames = 10,
                       transform_type = :brow, filename = "out.png")
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    if transform_type == :brow
        eye_operator = simple_eyes(size = height,
                                   brow_height = brow_height,
                                   show_brows = true)
        lolli = LolliPerson(size = height, eye_fum = eye_operator,
                            ArrayType = ArrayType,
                            num_particles = num_particles,
                            num_iterations = num_iterations)

        run!(lolli)
        write_image([bg, lolli]; filename = filename)
    elseif transform_type == :blink
        brow_height = fi("brow_height", 1.0)
        show_brows = fi("show_brows", false)
        eye_operator = simple_eyes(size = height,
                                   brow_height = brow_height,
                                   show_brows = show_brows)
        lolli = LolliPerson(size = height, eye_fum = eye_operator,
                            ArrayType = ArrayType,
                            num_particles = num_particles,
                            num_iterations = num_iterations)

        video_out = open_video(res; framerate = 30, filename = "out.mp4")
        for i = 1:num_frames
            blink!(lolli, i, 1, num_frames)

            run!(lolli)
            write_video!(video_out, [bg, lolli])
            reset!(lolli)
            reset!(bg)
        end

        close_video(video_out)
    end

end

@info("Created function blink_example(num_particles, num_iterations;
                                     height = 0.5, brow_height = 0.5,
                                     ArrayType = Array, num_frames = 10,
                                     transform_type = :brow,
                                     filename = 'out.png')\n"*
      "transform_type can be {:brow, :blink}")
