using Fable, Images, LolliPeople

function jump_example(num_particles, num_iterations;
                      height = 2.0, ArrayType = Array, num_frames = 10,
                      transform_type = :bounce)
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    if transform_type == :jump
    elseif transform_type == :bounce
        stretch_factor = fi(:stretch_factor, 1.0)
        head_position = fi(:head_position, (-height*1/4, 0.0))
        body_fo = fo(jump_smear(height = height,
                                foot_position = (height*0.5,0.0),
                                stretch_factor = stretch_factor))
        lolli = LolliPerson(size = height,
                            ArrayType = ArrayType,
                            num_particles = num_particles,
                            num_iterations = num_iterations,
                            head_position = head_position,
                            additional_fis = [stretch_factor],
                            body_smears = [body_fo])

        video_out = open_video(res; framerate = 30, filename = "out.mp4")
        for i = 1:num_frames
            bounce!(lolli, i, 1, num_frames)
    
            run!(lolli)
            write_video!(video_out, [bg, lolli])
            reset!(lolli)
            reset!(bg)
        end
    end

    close_video(video_out)

end
