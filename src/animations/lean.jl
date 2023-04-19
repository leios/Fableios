export lean_head, lean_body

lean_head = @fum function lean_head(x, y;
                                    foot_position = (0.0, 0.0),
                                    head_radius = 0.25,
                                    lean_velocity = 0.0,
                                    lean_angle = 0.0)
    x_temp = x - foot_position[2]
    y_temp = y - foot_position[1]

    lean_angle += lean_velocity*x_temp/head_radius

    x_temp2 = x_temp*cos(lean_angle) - y_temp*sin(lean_angle)
    y_temp = x_temp*sin(lean_angle) + y_temp*cos(lean_angle)

    x = x_temp2 + foot_position[2]
    y = y_temp + foot_position[1]
    
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
