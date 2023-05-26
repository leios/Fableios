using Fable, Images, LolliPeople

function walk_example(num_particles, num_iterations; num_steps = 1,
                      startup_frames = 3, p1 = (0,0), p2 = (0,0),
                      height = 0.5, ArrayType = Array, num_frames = 10, 
                      filebase = "out", output_type = :video)

    num_frames += startup_frames * 2
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    lolli = LolliPerson(size = height; ArrayType = ArrayType,
                        num_particles = num_particles, 
                        num_iterations = num_iterations)

    if startup_frames > 0
        set_walk_transforms!(lolli; startup = true, p1 = p1, p2 = p2,
                             start_frame = 1, end_frame = startup_frames)
    else
        set_walk_transforms!(lolli; p1 = p1, p2 = p2,
                             start_frame = 1, end_frame = num_frames)
    end

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = filebase*".mp4")
    end
    for i = 1:num_frames
        #walk!(lolli)
        run!(lolli; frame = i)
        if output_type == :video
            write_video!(video_out, [bg, lolli])
        else
            write_image([bg, lolli]; filename = filebase*lpad(i, 3, "0")*".png")
        end
        reset!(lolli)
        reset!(bg)

        if i == startup_frames && num_frames - 2*startup_frames != 0
            set_walk_transforms!(lolli, p1 = p1, p2 = p2, 
                                 start_frame = startup_frames + 1, 
                                 end_frame = num_frames - startup_frames)
        elseif i == num_frames - startup_frames && startup_frames > 0
            set_walk_transforms!(lolli; cooldown = true, p1 = p1, p2 = p2,
                                 start_frame = num_frames - startup_frames + 1,
                                 end_frame = num_frames)
        end

    end

    if output_type == :video
        close_video(video_out)
    end

end

@info("Created function walk_example(num_particles, num_iterations;
                                    num_steps = 1, startup_frames = 3,
                                    height = 0.5, ArrayType = Array,
                                    num_frames = 10, filebase = 'out',
                                    output_type = :video)\n"*
      "output_type can be {:video, :image}")
