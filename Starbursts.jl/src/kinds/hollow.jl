export hollow_starburst

hollow_starburst = @fum function hollow_starburst(y, x, frame;
                                                  start_frame = 0,
                                                  end_frame = 0,
                                                  max_range = 1,
                                                  translation = (0,0))
    if start_frame <= frame <= end_frame
        theta = atan(y,x)
        
        ratio = (frame - start_frame) / (end_frame - start_frame)
        r = ratio*max_range+sin(0.5*pi*ratio)
        x = x*sin(pi*ratio) + r*cos(theta)
        y = y*sin(pi*ratio) + r*sin(theta)
    end
    return point(y,x)
end
