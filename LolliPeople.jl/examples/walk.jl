using Fable, Images, LolliPeople

function walk_example(num_particles, num_iterations; num_steps = 1,
                      startup_frames = 3, p1 = (0,0), p2 = (0,0),
                      height = 0.5, ArrayType = Array, num_frames = 10, 
                      filebase = "out", output_type = :video)

    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    lolli = LolliPerson(scale = height; ArrayType = ArrayType,
                        num_particles = num_particles, 
                        num_iterations = num_iterations)

    if output_type == :video
        video_out = open_video(res; framerate = 30, filename = filebase*".mp4")
    end

    for i = 1:num_frames + startup_frames*2
        walk!(lolli; start_frame = 1, num_frames,
              frame = i, p1, p2, startup_frames, num_steps)
        run!(lolli; frame = i)
        if output_type == :video
            write_video!(video_out, [bg, lolli.layer])
        else
            write_image([bg, lolli.layer];
                        filename = filebase*lpad(i, 3, "0")*".png")
        end
        reset!(lolli)
        reset!(bg)

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
