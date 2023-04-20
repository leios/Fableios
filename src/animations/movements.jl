export rotate, translate, lean_head, lean_body, jump_smear, bounce!

jump_smear = @fum function jump_smear(x, y; foot_position = (0.0, 0.0),
                                      stretch_factor = 1.0,
                                      height = 1.0,
                                      jump_height = 0.0)
    y = stretch_factor*(y - foot_position[1]) + jump_height + foot_position[1]
    stretch_factor = abs(stretch_factor)
    if stretch_factor > 1.0
        x *= 1/stretch_factor
    elseif stretch_factor < 1.0
        temp_y = abs(y-foot_position[1]-height*0.5)
        factor = (1+height*0.25)/(temp_y+1)
        x = (x - foot_position[2])*factor + foot_position[2]
    end
    return point(y, x)
end

function bounce!(lolli::LolliLayer, curr_frame, start_frame, end_frame)

    factor = 1+sin(2*pi*curr_frame/(end_frame - start_frame))*0.25
    stretch_factor_idx = find_fi_index(:stretch_factor, lolli.additional_fis)
    if isnothing(stretch_factor_idx)
        @warn("stretch_factor not set as a FractalInput! Bouncing will fail!")
    end

    stretch_factor = lolli.additional_fis[stretch_factor_idx]
    set!(stretch_factor,
         value(stretch_factor)*factor)

    head_position_idx = find_fi_index(:position, lolli.head.H1.fis[1])

    head_position = lolli.head.H1.fis[1][head_position_idx]
    set!(head_position, (value(head_position)[1]*factor,
                         value(head_position)[2]))
end

function jump!(lolli::LolliLayer, curr_frame, start_frame, end_frame)

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

