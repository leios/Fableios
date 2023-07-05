export simple_eyes, blink!

simple_eyes = @fum color function simple_eyes(x, y;
                                              size = 1.0,
                                              head_position = (-0.25*size, 0.0),
                                              ellipticity = 2.5,
                                              location = (0.0, 0.0),
                                              inter_eye_distance = 0.150*size,
                                              eye_color=RGBA{Float32}(1,1,1,1),
                                              eye_size = size*0.08,
                                              show_brows = false,
                                              brow_angle = 0.0,
                                              brow_size = (0.3, 1.25),
                                              brow_height = 1.0)

    location = location .+ head_position
    r2 = eye_size*0.5
    r1 = ellipticity*r2
    y_height = location[1] + r1 - 2*r1 * brow_height
    if y >= y_height
        if in_ellipse(y,x,location.+(0, 0.5*inter_eye_distance),0.0,r1,r2) ||
           in_ellipse(y,x,location.-(0, 0.5*inter_eye_distance),0.0,r1,r2)
            return eye_color
        end
    end

    if Bool(show_brows)
        brow_size = brow_size .* eye_size
        brow_x = 0.5*inter_eye_distance + brow_size[2]*0.1
        if in_rectangle(y, x, (y_height-brow_size[1]*0.5, brow_x),
                        brow_angle, brow_size[2], brow_size[1]) ||
           in_rectangle(y, x, (y_height-brow_size[1]*0.5, -brow_x),
                        brow_angle, brow_size[2], brow_size[1])
            return eye_color
        end
    end

    return color

end

# This causes a LolliPerson to blink.
function blink!(lolli::LolliLayer, curr_frame, start_frame, end_frame)
    # split into 3rds, 1 close, 1 closed, 1 open
    third_frame = (end_frame - start_frame)*0.333

    fis = lolli.head.color_fis[1][2]
    if curr_frame < start_frame + third_frame
        brow_height = 1 - (curr_frame - start_frame)/(third_frame)
    elseif curr_frame >= start_frame + third_frame &&
           curr_frame <= start_frame + third_frame*2
        brow_height = 0.0
    else
        brow_height = (curr_frame - start_frame - third_frame*2)/(third_frame)
    end

    if brow_height < 1.0
        show_brows = true
    else
        show_brows = false
    end

    brow_height_idx = find_fi_index(:brow_height, fis)
    if isnothing(brow_height_idx)
        @warn("Brow height not set as FractalInput. Blinking will not work!")
    else
        set!(fis[brow_height_idx], brow_height)
    end

    show_brows_idx = find_fi_index(:show_brows, fis)
    if isnothing(show_brows_idx)
        @warn("show_brows not set as FractalInput. Blinking will not work!")
    else
        set!(fis[show_brows_idx], show_brows)
    end
end
