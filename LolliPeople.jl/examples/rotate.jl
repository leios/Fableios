using Fable, LolliPeople, Images

function rotate_example(num_particles, num_iterations; num_frames = 10,
                        ArrayType = Array, height = 0.5)
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)
    rotation = fi("rotation", 0.0)
    rotation_fo = fo(rotate(angle = rotation))
    lolli = LolliPerson(size = height, ArrayType = ArrayType,
                        num_particles = num_particles,
                        num_iterations = num_iterations,
                        head_transforms = [rotation_fo],
                        body_transforms = [rotation_fo])

    video_out = open_video(res; framerate = 30, filename = "out.mp4")
    for i = 1:num_frames
        set!(rotation, 2*pi*i/num_frames)
        run!(lolli)
        write_video!(video_out, [bg, lolli.layer])
    end

    close_video(video_out)
end

@info("Created function rotate_example(num_particles, num_iterations;
                                      ArrayType = Array, num_frames = 10,
                                      height = 0.5)\n")
