export floppy_speed, simple_airfoil

floppy_speed = @fum function floppy_speed(y, x; wobble_factor = 0.0,
                                          wobble_direction = 0.0,
                                          splat_factor = 0.0)
    
    slope = -tan(wobble_direction)
    mag = sqrt(slope^2 + 1)
    r = (slope*x + y)/mag
    u = (slope/mag, 1/mag)

    y += r*u[2]*splat_factor*(wobble_factor)
    x += r*u[1]*splat_factor*(wobble_factor)

    y -= u[1]*wobble_factor*r^2
    x += u[2]*wobble_factor*r^2

    return point(y, x)
end

simple_airfoil = @fum function simple_airfoil(y, x; wobble_factor = 0.0,
                                              wobble_direction = 0.0,
                                              splat_factor = 0.0,
                                              object_width = 1.0)
    # to avoid inf for the perpendicular slope
    if wobble_direction == 0
        wobble_direction += 0.000001
    end

    slope = -tan(wobble_direction)

    mag = sqrt(slope^2 + 1)
    mag_perp = sqrt((-1/slope)^2 + 1)

    r = (slope*x + y)/mag
    r_perp = (-x/slope + y)/mag_perp

    u = (slope/mag, 1/mag)

    y += r*u[2]*splat_factor*(wobble_factor)
    x += r*u[1]*splat_factor*(wobble_factor)

    y += u[1]*wobble_factor*(abs(r)-object_width)*(r_perp + object_width)
    x -= u[2]*wobble_factor*(abs(r)-object_width)*(r_perp + object_width)

    return point(y,x)
end
