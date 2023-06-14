export crunch

crunch = @fum function crunch(y, x; clockwise_rotation = true,
                              wobble_direction = 0.0,
                              object_location = (0,0),
                              object_width = 0.25,
                              splat_factor = 1.0,
                              object_height = 1.0)
    # rotate
    if object_location != (0,0)
        x -= object_location[2]
        y -= object_location[1]
    end
    if wobble_direction != 0
        x_temp = x*cos(wobble_direction) - y*sin(wobble_direction)
        y_temp = x*sin(wobble_direction) + y*cos(wobble_direction)
    else
        x_temp = x
        y_temp = y
    end

    # crunch

    if splat_factor < 1.0
        temp_y += object_height*0.5
        theta = acos(splat_factor)
        if clockwise_direction
            theta *= -1
        end

        x_temp = x*cos(theta) - y*sin(theta)
        y_temp = x*sin(theta) + y*cos(theta)

        x_temp = abs(((x_temp+object_width*2)%(object_width*2))-object_width)-
                 object_width*0.5
    else
        y *= splat_factor
    end

    # rotate back
    if wobble_direction != 0
        x = x_temp*cos(-wobble_direction) - y_temp*sin(-wobble_direction)
        y = x_temp*sin(-wobble_direction) + y_temp*cos(-wobble_direction)
    else
        x = x_temp
        y = y_temp
    end
    if object_location != (0,0)
        x += object_location[2]
        y += object_location[1]
    end

    return point(y,x)
end
