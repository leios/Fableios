export simple_eyes, blink!, change_skin

change_skin = @fum color function change_skin(y, x, color;
                                              skin_color = (0,0,0,1),
                                              new_color = (0,0,0,1))
    if color == RGBA{Float32}(skin_color)
        return RGBA{Float32}(new_color)
    end

    return color
end

simple_eyes = @fum color function simple_eyes(x, y;
                                              scale = 1.0,
                                              head_position = (-0.25*scale,
                                                               0.0),
                                              ellipticity = 2.5,
                                              location = (0.0, 0.0),
                                              inter_eye_distance = 0.150*scale,
                                              eye_color=RGBA{Float32}(1,1,1,1),
                                              eye_scale = scale*0.08,
                                              show_brows = false,
                                              brow_angle = 0.0,
                                              brow_scale = (0.3, 1.25),
                                              brow_height = 1.0)

    location = location .+ head_position
    r2 = eye_scale*0.5
    r1 = ellipticity*r2
    @inbounds y_height = location[1] + r1 - 2*r1 * brow_height
    if y >= y_height
        if in_ellipse(y,x,location.+(0, 0.5*inter_eye_distance),0.0,r1,r2) ||
           in_ellipse(y,x,location.-(0, 0.5*inter_eye_distance),0.0,r1,r2)
            return eye_color
        end
    end

    if Bool(show_brows)
        brow_scale = brow_scale .* eye_scale
        @inbounds begin
            brow_x = 0.5*inter_eye_distance + brow_scale[2]*0.1
            if in_rectangle(y, x, (y_height-brow_scale[1]*0.5, brow_x),
                            brow_angle, brow_scale[2], brow_scale[1]) ||
               in_rectangle(y, x, (y_height-brow_scale[1]*0.5, -brow_x),
                            brow_angle, brow_scale[2], brow_scale[1])
                return eye_color
            end
        end
    end

    return color

end

# This causes a LolliPerson to blink.
function blink!(lolli::LolliLayer, curr_frame, start_frame, end_frame)
    # split into 3rds, 1 close, 1 closed, 1 open
    third_frame = (end_frame - start_frame)*0.333

    @inbounds fis = lolli.head.colors[1][2].fis
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
        @warn("Brow height not set as FableInput. Blinking will not work!")
    else
        @inbounds set!(fis[brow_height_idx], brow_height)
    end

    show_brows_idx = find_fi_index(:show_brows, fis)
    if isnothing(show_brows_idx)
        @warn("show_brows not set as FableInput. Blinking will not work!")
    else
        @inbounds set!(fis[show_brows_idx], show_brows)
    end
end
