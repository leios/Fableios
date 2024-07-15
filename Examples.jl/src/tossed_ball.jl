#------------------------------------------------------------------------------#
#
# Notes: 
#     1. solve kinematic at each timestep for time (who cares about verlet?)
#     2. move ball and then scene upwards
#     3. Figure out sky colors and sun and lens flare
#     4. Prince of tennis
#
#------------------------------------------------------------------------------#
using Fable, Wobbles, Colors

function kinematic_velocity(time, v_0, a)
    return v_0 + a .* (time^2)
end

function kinematic(time, x_0, v_0, a)
    return x_0 .+ v_0 .* time .+ 0.5 .* a .* (time^2)
end

simple_sky = @fum color function simple_sky(y, x, frame;
                                            camera_position = (0,0),
                                            horizon = 0)
    y += camera_position[1]
    if y <= horizon
        red = 0.3*exp((y-horizon)*5)
        green = 0.3*exp((y-horizon)*5)
        blue = exp((y-horizon)*4)
        return RGBA{Float32}(red, green, blue, 1.0)
    else
        return RGBA{Float32}(0,0,0,1)
    end
end

function tossed_ball_example(num_particles, num_iterations; 
                             num_frames = 9, ball_radius = 0.2,
                             ArrayType = Array, filebase = "out",
                             initial_velocity = 5.0,
                             acceleration = -10.0,
                             sky_fum = simple_sky)

    world_size = (9*0.15, 16*0.15)
    ppu = 1920/world_size[2]

    initial_loc = 0.5*world_size[1]

    t_1 = (-initial_velocity+sqrt(initial_velocity^2 - 4*initial_loc*5)) /
          acceleration
    t_2 = - initial_velocity / acceleration

    # 2/3 the time will be used for scene 1 and 2 and 1/3 for scene 3
    frame_interval = ceil(Int, (num_frames*2/3)*t_1/(t_2))
    scene_1_frames = 1:frame_interval

    frame_interval = ceil(Int, (num_frames*2/3)*(t_2-t_1)/(t_2))
    scene_2_frames = scene_1_frames[end]:scene_1_frames[end]+frame_interval-1

    scene_3_frames = scene_2_frames[end]:num_frames

    # define fractal inputs
    scale = fi("scale", (1, 1))
    ball_position = fi("ball_position", (world_size[1]*0.5,0))
    camera_position = fi("camera_position", (0,0))

    sl = ShaderLayer(sky_fum(camera_position = camera_position,
                             horizon = world_size[1]*0.5);
                     ppu = ppu, world_size = world_size, ArrayType = ArrayType)
    
    circle = create_circle(color = Shaders.white, radius = ball_radius,
                           position = ball_position)

    smear = fo(Smears.stretch_and_rotate(scale = scale,
                                         object_position = ball_position))

    fl = FableLayer(H = circle, H_post = smear, ppu = ppu,
                      world_size = world_size,
                      ArrayType = ArrayType)

    layers = [sl, fl]
    for i = scene_1_frames
        current_time = t_2*3*i/(num_frames*2)
        final_scale = 2 * kinematic_velocity(current_time,
                                            initial_velocity,
                                            acceleration) / initial_velocity
        final_ball_position = kinematic(current_time, initial_loc,
                                        -initial_velocity, -acceleration)

        set!(scale, (final_scale, 1))
        set!(ball_position, (final_ball_position, 0))
        run!(layers)
        write_image(layers; filename = filebase*lpad(Int(i-1), 5, "0")*".png")
    end

    for i = scene_2_frames
        current_time = t_2*3*i/(num_frames*2)
        final_scale = 2 * kinematic_velocity(current_time,
                                            initial_velocity,
                                            acceleration) / initial_velocity
        final_ball_position = kinematic(current_time, initial_loc,
                                        -initial_velocity, -acceleration)

        set!(scale, (final_scale, 1))
        set!(camera_position, (final_ball_position, 0))
        run!(layers)
        write_image(layers; filename = filebase*lpad(Int(i-1), 5, "0")*".png")
    end
end
