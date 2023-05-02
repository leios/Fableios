export rotate, translate, lean_head, lean_body, jump_smear, bounce!, jump!

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

    head_position_idx = find_fi_index(:position, lolli.head.H1.fis[1])

    head_position = lolli.head.H1.fis[1][head_position_idx]
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

    head_position_idx = find_fi_index(:position, lolli.head.H1.fis[1])

    head_position = lolli.head.H1.fis[1][head_position_idx]
    set!(head_position, (value(head_position)[1]-dfactor,
                         value(head_position)[2]))

end

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

