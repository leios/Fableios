using Fable, Images, LolliPeople

function lean_example(num_particles, num_iterations;
                      height = 2.0, ArrayType = Array, num_frames = 10)
    bg = ColorLayer(RGBA(0.5, 0.5, 0.5, 1); ArrayType = ArrayType)
    res = (1080, 1920)

    lean_angle = fi("lean_angle", 0)
    lean_velocity = fi("lean_velocity", 0.0)
    head_fo = fo(lean_head(foot_position = (height*0.5,0.0),
                           head_radius = height*0.25,
                           lean_velocity = lean_velocity,
                           lean_angle = lean_angle))
    body_fo = fo(lean_body(height = height,
                           foot_position = (height*0.5,0.0),
                           lean_velocity = lean_velocity,
                           lean_angle = lean_angle))
    lolli = LolliPerson(height; 
                        ArrayType = ArrayType,
                        num_particles = num_particles,
                        num_iterations = num_iterations,
                        head_smears = [head_fo],
                        body_smears = [body_fo])

    video_out = open_video(res; framerate = 30, filename = "out.mp4")
    for i = 1:num_frames
        new_angle = 0.25*pi*sin(2*pi*i/num_frames)
        set!(lean_velocity, abs(value(lean_angle) - new_angle))
        set!(lean_angle, new_angle)

        run!(lolli)
        write_video!(video_out, [bg, lolli])
        reset!(lolli)
        reset!(bg)
    end

    close_video(video_out)

end

@info("Created function lean_example(num_particles, num_iterations;
                                    height = 2.0, brow_height = 0.5,
                                    ArrayType = Array, num_frames = 10)")
