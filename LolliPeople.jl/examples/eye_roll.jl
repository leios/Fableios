using Fable, Images, LolliPeople

function eyeroll_example(num_particles, num_iterations;
                         height = 0.5, ArrayType = Array, num_frames = 10)
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    eye_location = fi("eye_location", (0.0, 0.0))
    eye_operator = simple_eyes(location = eye_location, size = height)
    lolli = LolliPerson(size = height, eye_fum = eye_operator,
                        ArrayType = ArrayType,
                        num_particles = num_particles,
                        num_iterations = num_iterations)

    video_out = open_video(res; framerate = 30, filename = "out.mp4")
    for i = 1:num_frames
        angle = 2*pi*i/num_frames
        radius = i*height*0.5/num_frames
        location = (radius*sin(angle), radius*cos(angle))
        set!(eye_location, location)

        run!(lolli)
        write_video!(video_out, [bg, lolli])
        reset!(lolli)
        reset!(bg)
    end

    close_video(video_out)

end

@info("Created function eyeroll_example(num_particles,num_iterations;
                                       height = 0.5,
                                       ArrayType = Array,
                                       num_frames = 10)\n")
