using Fable, Wobbles, Colors

function wobbly_ball_example(num_particles, num_iterations; 
                             num_frames = 10, ball_radius = 0.2,
                             ArrayType = Array, filebase = "out")
    world_size = (9*0.15, 16*0.15)
    ppu = 1920/world_size[2]

    # define fractal inputs
    scale = fi("scale", (1, 1))
    ball_position = fi("ball_position", (0,-2))

    cl = ColorLayer(RGB(0,0,0); ppu = ppu, world_size = world_size,
                    ArrayType = ArrayType)

    circle = define_circle(color = Shaders.white, radius = ball_radius,
                           position = ball_position)

    smear = fo(Smears.stretch_and_rotate(scale = scale,
                                         object_position = ball_position))

    fl = FractalLayer(H = circle, H_post = smear, ppu = ppu,
                      world_size = world_size,
                      ArrayType = ArrayType)

    layers = [cl, fl]
    for i = 1:num_frames
        final_scale = 1+(i-1)/num_frames
        final_ball_position = -1.2 + (i-1)*2.4/num_frames
        if final_ball_position + final_scale*ball_radius >= 1.2
            final_scale += 1.2-(final_ball_position + 
                                final_scale*ball_radius)
        end
        println(final_scale)
        set!(scale, (1, final_scale))
        set!(ball_position, (0, final_ball_position))
        run!(layers)
        write_image(layers; filename = filebase*lpad(i-0, 5, "0")*".png")
    end
end
