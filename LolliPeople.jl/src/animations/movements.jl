export rotate, translate, lean_head, lean_body, jump_smear, bounce!, jump!,
       set_walk_transforms!, walk!

#------------------------------------------------------------------------------#
# Transforms
#------------------------------------------------------------------------------#

rotate = @fum function rotate(x, y; angle = 0.0, pivot = (0,0),
                              translation = (0,0))
    y_temp = y - pivot[1]
    x_temp = x - pivot[2]

    y = x_temp*sin(angle) + y_temp*cos(angle) + pivot[1] + translation[1]
    x = x_temp*cos(angle) - y_temp*sin(angle) + pivot[2] + translation[2]

    return point(y,x)
end

translate = @fum function translate(x, y; translation = (0,0))
    return point(y + translation[1], x + translation[2])
end

#------------------------------------------------------------------------------#
# Jump / Bounce
#------------------------------------------------------------------------------#

jump_smear = @fum function jump_smear(x, y; foot_position = (0.0, 0.0),
                                      stretch_factor = 1.0,
                                      body_height = 1.0,
                                      jump_height = 0.0)
    y += (stretch_factor*(y - foot_position[1])/body_height) - 
         (jump_height*(1-(foot_position[1] - y)/body_height))
    x *= 1/(1+2*(stretch_factor - jump_height))
    return point(y, x)
end

function bounce!(lolli::LolliLayer, curr_frame, start_frame, end_frame;
                 max_bounce_height = 0.1*lolli.params.size)

    factor = sin(2*pi*(curr_frame)/(end_frame - start_frame))*max_bounce_height
    dfactor = factor-(sin(2*pi*(curr_frame-1)/
                               (end_frame - start_frame))*max_bounce_height)

    stretch_factor_idx = find_fi_index(:stretch_factor, lolli.additional_fis)
    if isnothing(stretch_factor_idx)
        @warn("stretch_factor not set as a FractalInput! Bouncing will fail!")
    end

    stretch_factor = lolli.additional_fis[stretch_factor_idx]
    set!(stretch_factor, factor)

    head_position_idx = find_fi_index(:position, lolli.head.ops[1].fis)

    head_position = lolli.head.ops[1].fis[head_position_idx]
    set!(head_position, (value(head_position)[1]-dfactor,
                         value(head_position)[2]))
end

function jump!(lolli::LolliLayer, curr_frame, start_frame, end_frame;
               max_jump_height = 0.1*lolli.params.size)

    factor = sin(2*pi*(curr_frame)/(end_frame - start_frame))*max_jump_height
    dfactor = factor-(sin(2*pi*(curr_frame-1)/
                               (end_frame - start_frame))*max_jump_height)
    
    stretch_factor_idx = find_fi_index(:stretch_factor, lolli.additional_fis)
    if isnothing(stretch_factor_idx)
        @warn("stretch_factor not set as a FractalInput! Bouncing will fail!")
    end

    stretch_factor = lolli.additional_fis[stretch_factor_idx]
    set!(stretch_factor, factor)

    jump_height_idx = find_fi_index(:jump_height, lolli.additional_fis)
    if isnothing(jump_height_idx)
        @warn("stretch_factor not set as a FractalInput! Bouncing will fail!")
    end

    jump_height = lolli.additional_fis[jump_height_idx]
    set!(jump_height, max(0.0, factor - 0.5*max_jump_height))

    head_position_idx = find_fi_index(:position, lolli.head.ops[1].fis)

    head_position = lolli.head.ops[1].fis[head_position_idx]
    set!(head_position, (value(head_position)[1]-dfactor,
                         value(head_position)[2]))

end

#------------------------------------------------------------------------------#
# Lean
#------------------------------------------------------------------------------#

lean_head = @fum function lean_head(x, y;
                                    foot_position = (0.0, 0.0),
                                    head_radius = 0.25,
                                    lean_velocity = 0.0,
                                    lean_angle = 0.0)
    y_temp = y - foot_position[1]
    x_temp = x - foot_position[2]

    lean_angle += lean_velocity*x_temp/head_radius

    y = x_temp*sin(lean_angle) + y_temp*cos(lean_angle) + foot_position[1]
    x = x_temp*cos(lean_angle) - y_temp*sin(lean_angle) + foot_position[2]

    return point(y,x)
end

lean_body = @fum function lean_body(x, y;
                                    height = 1.0,
                                    foot_position = (0,0),
                                    lean_velocity = 0.0,
                                    lean_angle = 0.0)
    x_temp = x - foot_position[2]
    y_temp = y - foot_position[1]

    lean_angle *= -(y - foot_position[1])/(0.5*height)
    lean_angle += lean_velocity*x_temp/(0.1*height)

    x_temp2 = x_temp*cos(lean_angle) - y_temp*sin(lean_angle)
    y_temp = x_temp*sin(lean_angle) + y_temp*cos(lean_angle)

    x = x_temp2 + foot_position[2]
    y = y_temp + foot_position[1]

    return point(y,x)
end

#------------------------------------------------------------------------------#
# Step / Walk
#------------------------------------------------------------------------------#

crouch = @fum function crouch(y, x, frame; foot_position = (0,0), head = false,
                              reverse = false, shrink_factor = 0,
                              start_frame = 1, end_frame = 1,
                              translation = (0,0), body_height = 0.5)
    if start_frame <= frame <= end_frame
        if reverse
            shrink_factor = shrink_factor*
                            (1-(frame-start_frame)/(end_frame - start_frame))
        else
            shrink_factor = shrink_factor*
                            (frame-start_frame)/(end_frame - start_frame)
        end

        if head
            y += shrink_factor*body_height
        else
            y -= ((y - foot_position[1]))*shrink_factor
        end

        if head
            x += translation[2]
        else
            x = x*min(1.5,1/(1-shrink_factor)) + translation[2]
        end

    end
    return point(y, x)
end

leap = @fum function leap(y, x, frame; start_frame = 0, end_frame = 0,
                          p1 = (0,0), p2 = (0,0), jump_height = 0, 
                          foot_position = (0,0), shrink_factor = 0,
                          body_height = 1.0, head = false)

    if start_frame <= frame <= end_frame

        # This ranges from 0 -> 1
        ratio = (frame - start_frame) / (end_frame - start_frame)

        # This ranges from 0 -> 1 from start_frame + total_frames/4 ->
        # end_frame - total_frames / 4
        movement_ratio = ratio*2-0.5
        if movement_ratio <= 0
            movement_ratio = 0
        elseif movement_ratio >= 1
            movement_ratio = 1
        end

        max_lean = min(pi/4, (p2[2] - p1[2])/(body_height*10))
        lean_angle = max_lean * sin(2*pi*ratio)
        jump_height *= movement_ratio*sin(pi*movement_ratio)
        shrink_factor = shrink_factor - shrink_factor*sin(pi*movement_ratio) +
                        jump_height

        y_temp = y - foot_position[1]
        x_temp = x - foot_position[2]

        if head
            y_temp += shrink_factor*body_height

            y = x_temp*sin(lean_angle) + y_temp*cos(lean_angle)
            x = x_temp*cos(lean_angle) - y_temp*sin(lean_angle)
        else
            lean_angle *= -(y_temp)/(body_height)
            y_temp -= shrink_factor*y_temp
            x_temp = x_temp*min(1.5,1/(1-shrink_factor))

            x = x_temp*cos(lean_angle) - y_temp*sin(lean_angle)
            y = x_temp*sin(lean_angle) + y_temp*cos(lean_angle)

        end

        y += p1[1] + (p2[1] - p1[1])*movement_ratio - jump_height
        x += p1[2] + (p2[2] - p1[2])*movement_ratio

        y += foot_position[1]
        x += foot_position[2]
    end

    return point(y, x)
end

function set_walk_transforms!(lolli::LolliLayer; startup = false,
                                                 cooldown = false,
                                                 start_frame = 0,
                                                 end_frame = 0,
                                                 p1 = (0,0),
                                                 p2 = (0,0),
                                                 jump_height = 0.25)
    max_shrink = 0.25 + 0.75*(1/(2^(jump_height / lolli.params.body_height)))
    if startup && cooldown
        error("Cannot use both startup and cooldown for walk transforms!")
    elseif startup
        set_transforms!(lolli, crouch(foot_position=lolli.params.foot_position,
                                      shrink_factor = max_shrink,
                                      start_frame = start_frame,
                                      end_frame = end_frame,
                                      translation = p1,
                                      body_height = lolli.params.body_height);
                        layer = :body)
        set_transforms!(lolli, crouch(foot_position=lolli.params.foot_position,
                                      shrink_factor = max_shrink,
                                      head = true,
                                      start_frame = start_frame,
                                      end_frame = end_frame,
                                      translation = p1,
                                      body_height = lolli.params.body_height);
                        layer = :head)
    elseif cooldown
        set_transforms!(lolli, crouch(foot_position=lolli.params.foot_position,
                                      shrink_factor = max_shrink,
                                      reverse = true,
                                      start_frame = start_frame,
                                      end_frame = end_frame,
                                      translation = p2,
                                      body_height = lolli.params.body_height);
                        layer = :body)
        set_transforms!(lolli, crouch(foot_position=lolli.params.foot_position,
                                      shrink_factor = max_shrink,
                                      head = true,
                                      reverse = true,
                                      start_frame = start_frame,
                                      end_frame = end_frame,
                                      translation = p2,
                                      body_height = lolli.params.body_height);
                        layer = :head)
    else
        set_transforms!(lolli, [leap(;start_frame, end_frame, p1, p2,
                                     foot_position = lolli.params.foot_position,
                                     shrink_factor = max_shrink,
                                     body_height = lolli.params.body_height,
                                     jump_height)];
                        layer = :body)
        set_transforms!(lolli, [leap(;start_frame, end_frame, p1, p2,
                                     foot_position = lolli.params.foot_position,
                                     shrink_factor = max_shrink,
                                     body_height = lolli.params.body_height,
                                     jump_height, head = true)];
                        layer = :head)
    end

end

function walk!(lolli::LolliLayer; start_frame = 0, num_frames = 0, frame = 0,
               p1 = (0,0), p2 = (0,0), startup_frames = 0, num_steps = 0)
    walk!(lolli, frame, p1, p2, num_steps, start_frame,
          num_frames, startup_frames)
end

function walk!(lolli::LolliLayer, frame, p1, p2, num_steps,
               start_frame, num_frames, startup_frames)

    if frame == start_frame
        set_walk_transforms!(lolli; startup = true, p1 = p1, p2 = p2,
                             start_frame = 1, end_frame = startup_frames)
    elseif frame == start_frame + startup_frames && num_steps == 1
        set_walk_transforms!(lolli, p1 = p1, p2 = p2, 
                             start_frame = frame, 
                             end_frame = frame + num_frames)
    elseif frame == start_frame + num_frames + startup_frames
        set_walk_transforms!(lolli; cooldown = true, p1 = p1, p2 = p2,
                             start_frame = frame,
                             end_frame = frame + startup_frames)
    elseif (frame-start_frame-startup_frames)%(num_frames / num_steps) == 0 &&
           num_steps != 1
        p1_temp = p1
        p1 = p1 .+ (p2 .- p1) .* ((frame - start_frame - startup_frames) /
                                  (num_frames - start_frame+1))
        p2 = p1_temp .+ (p2 .- p1_temp) .* ((frame + (num_frames / num_steps) -
                                             start_frame - startup_frames) /
                                            (num_frames - start_frame+1))
        set_walk_transforms!(lolli, p1 = p1, p2 = p2, 
                             start_frame = frame, 
                             end_frame = frame + (num_frames / num_steps))
    elseif frame == start_frame + num_frames + 2*startup_frames
        reset_transforms!(lolli)
    end
end
