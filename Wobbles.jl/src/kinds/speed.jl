export floppy_speed, simple_airfoil

floppy_speed = @fum function floppy_speed(y, x; wobble_factor = 0.0,
                                          wobble_direction = 0.0)
    return point(y,x)
end

simple_airfoil = @fum function simple_airfoil(y, x; wobble_factor = 0.0,
                                              wobble_direction = 0.0)
    return point(y,x)
end
