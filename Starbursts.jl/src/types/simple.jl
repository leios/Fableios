export simple_starburst

simple_starburst = @fum function simple_starburst(y, x, frame;
                                                  start_frame = 0,
                                                  end_frame = 0)
    if start_frame <= frame <= end_frame
        ratio = (frame-start_frame)/(end_frame - start_frame)
        x = x*sin(pi*ratio)
        y = y*sin(pi*ratio)
    end
    return point(y,x)
end
