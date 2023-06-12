export floppy_speed, simple_airfoil

floppy_speed = @fum function floppy_speed(y, x; wobble_factor = 0.0,
                                          wobble_direction = 0.0,
                                          splat_factor = 1.0)
    
    slope = -tan(wobble_direction)
    mag = sqrt(slope^2 + 1)
    r = (slope*x + y)/mag
    u = (slope/mag, 1/mag)

    return point(y-u[1]*wobble_factor*r^2,
                 x+u[2]*wobble_factor*r^2)
end

simple_airfoil = @fum function simple_airfoil(y, x; wobble_factor = 0.0,
                                              wobble_direction = 0.0)
    return point(y,x)
end
