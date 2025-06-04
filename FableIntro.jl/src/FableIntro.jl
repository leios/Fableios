module FableIntro

using Fable
using Colors
using Random
using Images

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
    seed = pcg(seed)

    new_x = world_size[2]*((seed/typemax(UInt))-0.5)

    seed = pcg(seed)
    new_y = world_size[1]*((seed/typemax(UInt))-0.5)

    seed = pcg(seed)
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

#------------------------------------------------------------------------------#
# MAIN
#------------------------------------------------------------------------------#

function create_keyframes()
    return Dict("mom" => 1.333333,
                "stars" => 2.333333,
                "comet" => 3.161616,
                "rings" => 3.66666,
                "kinda" => 7.266)
end

function space_example(num_particles, num_iterations;
                       ArrayType = Array, filebase = "output/out",
                       background_texture = background_texture,
                       make_disk = make_disk,
                       color_disk = color_disk,
                       project_disk = project_disk,
                       color_projected_disk = color_projected_disk,
                       base_planet_color = base_planet_color,
                       planet_swirl = planet_swirl,
                       planet_glow = planet_glow,
                       comet_fire = comet_fire,
                       comet_hole = comet_hole,
                       comet_shape = comet_shape,
                       comet_wiggle = comet_wiggle,
                       translate = translate,
                       scale = scale,
                       stars = stars,
                       start_time = 0.0,
                       end_time = 1/Fable.FPS)
    world_size = (9*0.125, 16*0.125)
    ppu = 1920/world_size[2]

    keyframes = create_keyframes()
    mom_image = ArrayType{RGBA{Float32}}(load("res/not_to_scale.png"))
    mom_layer = ImageLayer(mom_image;
                           ppu = ppu, ArrayType = ArrayType)
    kinda_image = ArrayType{RGBA{Float32}}(load("res/kinda.png"))
    kinda_layer = ImageLayer(kinda_image;
                             ppu = ppu, ArrayType = ArrayType)

    # Define fable inputs
    planet_rotation = fi("planet_rotation", 0)
    star_scale = fi("star_scale", 1)
    ring_wobble = fi("ring_wobble", -0.2*pi)
    comet_angle = fi("comet_angle", 0.25*pi)
    ring_radius = fi("ring_radius", 0.425)
    comet_wiggle_amplitude = fi("comet_wiggle_amplitude", 0.0)

    circle = define_circle(radius = 0.3, color = Shaders.white)
    fo_1 = fo((stars, scale(scale_factor = star_scale)),
              (Shaders.white, Shaders.previous), (0.5, 0.5))
    fo_2 = fo((Smears.null, planet_swirl(global_rotation = planet_rotation),
               Smears.null),
              (base_planet_color, Shaders.previous,  planet_glow),
              (0.33, 0.33, 0.34))
    fo_3 = fo((Smears.null, make_disk(radius = ring_radius), project_disk, rotate(angle = ring_wobble)),
              (color_disk, Shaders.previous, Shaders.previous, color_projected_disk(angle = ring_wobble)),
              (0.25, 0.25, 0.25, 0.25))
    fo_4 = fo((Smears.null, comet_shape(comet_angle = comet_angle),
               comet_wiggle(wiggle_amplitude = comet_wiggle_amplitude)),
              (comet_fire, comet_hole(comet_angle = comet_angle),
               Shaders.previous),
              (0.33, 0.33, 0.34))

    transformations = Hutchinson((fo_1, fo_2, fo_4))

    H = Hutchinson((circle, circle, circle))

    flayer = FableLayer(num_particles = num_particles,
                        num_iterations = num_iterations,
                        H = H, H_post = transformations,
                        ppu = ppu,
                        world_size = world_size,
                        ArrayType = ArrayType,
                        overlay = true)

    r_transforms = fo_3
    r_H = circle

    rlayer = FableLayer(num_particles = num_particles,
                        num_iterations = num_iterations,
                        H = r_H, H_post = r_transforms,
                        ppu = ppu,
                        world_size = world_size,
                        ArrayType = ArrayType,
                        overlay = true)

    clayer = ShaderLayer(background_texture;
                         ArrayType = ArrayType,
                         world_size = world_size,
                         ppu = ppu)

    curr_time = start_time
    while curr_time < keyframes["kinda"]
        set!(planet_rotation, 0.5*curr_time*2*pi)
        set!(ring_wobble, (-0.1*pi)+0.1*sin(0.5*curr_time*2*pi))
        set!(comet_angle, -(0.5*curr_time*2*pi))
        #println(round(Int,curr_time * Fable.FPS))
        #println(value(comet_angle))

        run!(clayer)
        run!(flayer)
        run!(rlayer)

        if curr_time > keyframes["stars"] &&
           curr_time < keyframes["stars"] + 1
            x = curr_time - keyframes["stars"]
            set!(star_scale, 1 + 0.02*sin(3*pi*x*x)/(x+0.01))
        end

        if curr_time > keyframes["comet"] &&
           curr_time < keyframes["comet"] + 0.5
            x = 2*(curr_time - keyframes["comet"])
            set!(comet_wiggle_amplitude, 0.02 * x)
        elseif curr_time > keyframes["comet"] + 0.5 &&
           curr_time < keyframes["comet"] + 1
            x = 2*(keyframes["comet"]+1-curr_time)
            set!(comet_wiggle_amplitude, 0.02 * x)
        elseif value(comet_wiggle_amplitude) != 0
            set!(comet_wiggle_amplitude, 0)
        end

        if curr_time > keyframes["rings"] &&
           curr_time < keyframes["rings"] + 1
            x = curr_time - keyframes["rings"]
            set!(ring_radius, 0.425 + 0.02*sin(3*pi*x*x)/(x+0.01))
        end

        curr_frame = round(Int,curr_time * Fable.FPS)
        filename = filebase*lpad(string(curr_frame),5,"0")*".png"
        if curr_time > keyframes["mom"] &&
           curr_time < keyframes["mom"] + 0.5

            write_image([clayer, flayer, rlayer, mom_layer];
                        filename = filename, reset = false)
            reset!([clayer, flayer, rlayer])
        else
            write_image([clayer, flayer, rlayer];
                        filename = filename)
        end

        curr_time += 1/Fable.FPS

    end
    while curr_time < end_time
        curr_frame = round(Int,curr_time * Fable.FPS)
        filename = filebase*lpad(string(curr_frame),5,"0")*".png"
        curr_time += 1/Fable.FPS
        write_image(kinda_layer; filename = filename, reset = false)
    end

end
end
