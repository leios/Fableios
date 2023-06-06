export simple_starburst

simple_starburst = @fum function simple_starburst(y, x, frame)
    x = x*sin(2*pi*frame/10)
    y = y*sin(2*pi*frame/10)
    return point(y,x)
end
