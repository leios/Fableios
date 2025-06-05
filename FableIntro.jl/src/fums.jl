#------------------------------------------------------------------------------#
# AUX
#------------------------------------------------------------------------------#

function pcg(x)
    count= (x >> 59)
    x ^= x >> (5 + count)
    x *= UInt(12605985483714917081)
    return x ^ (x >> 43)
end


#------------------------------------------------------------------------------#
# Asteroid
#------------------------------------------------------------------------------#

comet_wiggle = @fum function comet_wiggle(y, x; comet_distance = 0.5,
                                          wiggle_frequency = 20,
                                          wiggle_amplitude = 0.01)
    r = sqrt(x*x + y*y)
    theta = atan(y/x)
    if x < 0
        theta -= pi
    end
    r += wiggle_amplitude*sin(wiggle_frequency*theta)

    return point(r*sin(theta), r*cos(theta))
end

comet_fire = @fum color function comet_fire(y, x; current_size = 0.3)
    r = sqrt(x*x + y*y)
    red = 1
    green = 0.25 + 0.75*(r / current_size)
    blue = r / current_size
    alpha = 0.5+0.5*(1-(r / current_size))
    return RGBA{Float32}(red, green, blue, alpha)
end

comet_hole = @fum color function comet_hole(y, x; comet_size = 0.04,
                                            comet_distance = 0.5,
                                            comet_angle = -0.25*pi,
                                            ellipse_factor = 1.2)
    x_location = (ellipse_factor)*comet_distance*cos(-comet_angle)
    y_location = -comet_distance*sin(-comet_angle)

    r = sqrt((x_location-x)^2 + (y_location-y)^2)

    #return RGBA{Float32}((r*100)%0.99, 0, 0, 1)

    if r < 0.25*comet_size
        return RGBA{Float32}(color.r*0.1, color.b*0.1, color.g*0.1,
                             color.alpha)
    else
        return color
    end
    
end

comet_shape = @fum function comet_shape(y, x;
                                        primitive_radius = 0.3,
                                        comet_distance = 0.5,
                                        comet_angle = -0.25*pi,
                                        comet_size = 0.04,
                                        tail_size = 10,
                                        ellipse_factor = 1.2,
                                        velocity = 10)

    max_angle = velocity * tail_size

    x *= comet_size
    y *= comet_size
    if y > 0
        x *= (1-(y/comet_size))
    end

    x += comet_distance
    v1 = x*sin(comet_angle) + y*cos(comet_angle)
    v2 = x*cos(comet_angle) - y*sin(comet_angle)
    y = v1
    x = v2

    angle = atan(y,x)
    if y > 0
        angle -= 2pi
    end

    angle += 2*pi*trunc(comet_angle / (2*pi))

    if x >= 0 && y <= 0 && y >= -primitive_radius * comet_size
        angle -= 2pi
    end
    if x >= 0 && y >= 0 && y <= primitive_radius * comet_size
        angle += 2pi
    end

    if angle >= comet_angle #||
        #(y >= 0 && y <= primitive_radius * comet_size)
        angle -= comet_angle
        angle *= tail_size

        v1 = x*sin(angle) + y*cos(angle)
        v2 = x*cos(angle) - y*sin(angle)

        y = v1
        x = v2
    end
    x *= ellipse_factor
    return point(y, x)
end

#------------------------------------------------------------------------------#
# Rings
#------------------------------------------------------------------------------#

make_disk = @fum function make_disk(y, x;
                                    radius = 0.425,
                                    thickness = 0.15,
                                    current_radius = 0.3)
    theta = atan(y, x)

    inner_radius = radius - 0.5*thickness

    x = x * (thickness / current_radius) + inner_radius * cos(theta)
    y = y * (thickness / current_radius) + inner_radius * sin(theta)

    return point(y, x)
end

color_disk = @fum color function color_disk(y, x;
                                            num_bands = 4, current_radius = 0.3)
    r = sqrt(x*x + y*y)
    current_band = floor(Int, num_bands *(r / current_radius))
    seed = simple_rand(current_band^2)

    green = 0

    red = 0.5 + 0.5*(seed / typemax(UInt))
    seed = simple_rand(seed)
    blue = 0.5 + 0.5*(seed / typemax(UInt))

    a = (num_bands * r / current_radius)%1

    return RGBA(red, green, blue, a)
end

project_disk = @fum function project_disk(y, x; angle = pi*0.4, distance = -2)
    new_angle = (distance / (distance + y*sin(angle)))
    return point(new_angle * y * cos(angle), new_angle * x)

end

color_projected_disk = @fum color function color_projected_disk(y, x;
    planet_radius = 0.3, angle = -0.1*pi)
    angle *= -1
    x = x*cos(angle) - y*sin(angle)
    y = x*sin(angle) + y*cos(angle)

    if y < 0
        r = sqrt(x*x + y*y)
        a = color.alpha
        if r <= planet_radius
            a = 0
        end
        return RGBA{Float32}(color.r, color.g, color.b, a)
    else
        return color
    end
end

#------------------------------------------------------------------------------#
# Planet
#------------------------------------------------------------------------------#

planet_swirl = @fum function planet_swirl(y, x; total_rotations = 7,
                                          planet_radius = 0.3,
                                          global_rotation = 0.0)
    r = sqrt(x*x + y*y)
    theta = (planet_radius-r)*(total_rotations*2*pi)

    v1 = x*cos(theta) + y*sin(theta)
    v2 = x*sin(theta) - y*cos(theta)

    y = v1
    x = v2

    v1 = x*cos(global_rotation) + y*sin(global_rotation)
    v2 = x*sin(global_rotation) - y*cos(global_rotation)

    return point(v1, v2)
end

base_planet_color = @fum color function base_planet_color(y, x;
                                                          num_divisions = 10)
    segment = floor(Int, num_divisions * ((atan(y, x) + pi)/(2*pi)))

    seed = simple_rand(segment^3)

    red = 0.5 + 0.5*(seed/typemax(UInt))
    seed = simple_rand(seed)
    blue = 0.5 + 0.5*(seed/typemax(UInt))
    
    return RGBA{Float32}(red, 0, blue, 1)
end

planet_glow = @fum color function panet_glow(y, x, color;
                                             glow_offset = (-0.1, -0.1),
                                             gradient_radius = 0.3)


    r = sqrt((x-glow_offset[2])^2 + (y-glow_offset[1])^2)

    ratio = (1 - (r/gradient_radius))
    if ratio < 0
        ratio = 0
    end

    r = color.r * ratio
    g = 0.5*ratio
    b = color.b * ratio


    return RGBA{Float32}(r, g, b, 1)
    
end

#------------------------------------------------------------------------------#
# Stars
#------------------------------------------------------------------------------#

stars = @fum function stars(y, x; num_stars = 5000,
                                  world_size = (9*0.125, 16*0.125),
                                  base_size = 0.0025)
    seed = rand(1:num_stars)
    seed = FableIntro.pcg(seed)

    new_x = world_size[2]*((seed/typemax(UInt))-0.5)

    seed = FableIntro.pcg(seed)
    new_y = world_size[1]*((seed/typemax(UInt))-0.5)

    seed = FableIntro.pcg(seed)
    scale_factor = base_size*(1 + 0.3 * ((seed/typemax(UInt))-0.5))
    x = scale_factor * x + new_x
    y = scale_factor * y + new_y

    return point(y, x)
    
end

#------------------------------------------------------------------------------#
# BG
#------------------------------------------------------------------------------#

background_texture = @fum color function background(y, x)
    r = sqrt(x*x + y*y)
    b = (1-1.5*r)
    if b < 0
        b = 0
    end 
    return RGBA{Float32}(0,0,b,1)
end

translate = @fum function translate(y, x;
                                    translation = (0,0))
    @inbounds x += translation[2]
    @inbounds y += translation[1]
    return point(y, x)
end


scale = @fum function scale(y, x; scale_factor = 1)
    return point(y*scale_factor, x*scale_factor)
end

rotate = @fum function rotate(y, x; angle = 0)
    return point(x*sin(angle) + y*cos(angle),
                 x*cos(angle) - y*sin(angle))
end

