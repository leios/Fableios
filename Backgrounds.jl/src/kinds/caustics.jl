#------------caustics.jl-------------------------------------------------------#
# Purpose: This file is meant to show how to create somewhat "physical"
#          caustics in Fable by using IFSs to our advantage
#   Notes: This could also be done by doing a raymarching sim and writing
#              everything out to a texture
#          Instead, we are using the fact that each point in the IFS can act as
#              a ray. So the idea is to generate a simple white object and then
#              send the points through a single caustic postprocessing fum
#          This approach will not work for reflections off of surfaces
#------------------------------------------------------------------------------#

export Caustics

module Caustics
import Fable.@fum
import Fable.FPS
import Fable.point

function normalize(t::Tuple{N1,N2}) where {N1 <: Number, N2 <: Number}
    mag = sqrt(t[1]^2 + t[2]^2)
    return (t[1]/mag, t[2]/mag)
end

function normalize(t::Tuple{N1,N2,N3}) where {N1 <: Number,
                                              N2 <: Number,
                                              N3 <: Number}
    mag = sqrt(t[1]^2 + t[2]^2 + t[3]^2)
    return (t[1]/mag, t[2]/mag, t[3]/mag)
end


abstract type AbstractWave end;

struct NullWave <: AbstractWave
end

struct Wake{T, FT} <: AbstractWave
    position::T
    velocity::T
    wavelength::FT
    intensity::FT
    start_time::FT
    end_time::FT
end

struct VerticalWave{T, FT} <: AbstractWave
    position::T
    angle::FT
    wavelength::FT
    intensity::FT
    start_time::FT
    end_time::FT
end

struct CircularWave{T, FT} <: AbstractWave
    position::T
    wavelength::FT
    intensity::FT
    start_time::FT
    end_time::FT
end

struct Rain{I, FT} <: AbstractWave
    seed::I
    intensity::FT
    frequency::FT
    start_time::FT
    end_time::FT
end

struct Buldge{T, FT} <: AbstractWave
    position::T
    intensity::FT
    start_time::FT
    end_time::FT
end

struct Splash{T, FT, B} <: AbstractWave
    position::T
    intensity::FT
    start_time::FT
    end_time::FT
    inward::B
end

# defaults to deep ocean water
function water_wavespeed(wavelength; depth = wavelength)
    if depth > 0.5*wavelength
        return sqrt(9.81*wavelength/(2*pi))
    elseif depth < 0.05*wavelength
        return sqrt(9.81*depth)
    else
        return sqrt((9.81*wavelength/(2*pi))*tanh(2*pi*depth/wavelength))
    end
end

function water_surface_probe(position, wave::WT, time;
                             dims = 2) where WT <: AbstractWave
    return 0.0
end

function water_surface_probe(position, wave::Wake, time; dims = 2)
end

function water_surface_probe(position, wave::VerticalWave, time; dims = 2)
    wavespeed = water_wavespeed(wave.wavelength)
    position = (position[2]*sin(wave.angle) + position[1]*cos(wave.angle),
                position[2]*cos(wave.angle) - position[1]*sin(wave.angle))

    position = position .+ wave.position
    
    if position[1] >= 0 &&
       time >= wave.start_time + position[1]/wavespeed &&
       time <= wave.end_time + position[1]/wavespeed
        curr_time = time - wave.start_time
        return -1*wave.intensity*sin((2*pi*wavespeed/wave.wavelength)*
                                     (position[1]-curr_time*wavespeed))
    else
        return 0 
    end

end

function water_surface_probe(position, wave::CircularWave, time; dims = 2)
    wavespeed = water_wavespeed(wave.wavelength)
    r = sqrt(sum((wave.position[:] .- position[:]).^2))
    if time >= wave.start_time + r/wavespeed &&
       time <= wave.end_time + r/wavespeed
        curr_time = time - wave.start_time
        return -1*wave.intensity*
                  sin((2*pi*wavespeed/wave.wavelength)*(r-curr_time*wavespeed))
    else
        return 0 
    end
end

function water_surface_probe(position, wave::Rain, time; dims = 2)
end

function water_surface_probe(position, wave::Buldge, time; dims = 2)
end

function water_surface_probe(position, wave::Splash, time; dims = 2)
end

function water_surface_probe(position, waves::Tuple, time; dims = 2)
    val = 0.0
    for wave in waves
        val += water_surface_probe(position, wave, time; dims)
    end
    return val
end

function water_surface!(surface::AT, waves, time;
                        dims = length(size(surface)),
                        bounds = (-10, 10, -10, 10)) where AT <: AbstractArray
    if dims > 2 || dims < 1
        error("Surface waves can only be 1 or 2 dimensional!")
    end

    for i = 1:length(surface)
        if dims == 2
            index = ((i-1)%size(surface)[1]+1,
                     floor(Int, (i-1)/size(surface)[1])+1)
            pos = ((index[1]/size(surface)[1])*(bounds[2]-bounds[1])+bounds[1],
                   (index[2]/size(surface)[2])*(bounds[4]-bounds[3])+bounds[3])

        else
            pos = ((i/length(surface))*(bounds[2]-bounds[1])+bounds[1],)
        end
        surface[i] = water_surface_probe(pos, waves, time; dims)
    end
end

function water_surface(res, bounds, waves, time; ArrayType = Array)
    surface = ArrayType(zeros(res))
    water_surface!(surface, waves, time; bounds)
    return surface
end

# This assumes there is a single beam of light shooting from the sky onto
# a plane at the bottom of the pool
# Note: probably should use 3d instead of 2d here...
function top_down_refract(y, x, time, waves, epsilon, depth)
    # find the correct height based on the intensity at a particular location
    intensity = water_surface_probe((y, x), waves, time)

    depth += intensity

    dx = intensity - water_surface_probe((y, x+epsilon), waves, time)
    dy = intensity - water_surface_probe((y+epsilon, x), waves, time)

    # Snell's law: https://en.wikipedia.org/wiki/Snell%27s_law#Vector_form
    # Air to water Index of Refraction Ratio
    ratio = 1.0 / 1.33
    normal = normalize((dx, dy, epsilon))

    ray = (0, 0, -1)

    c = sum(-1 .* normal .* ray)

    out = ratio .* ray .+ ((ratio*c - sqrt(1-ratio^2*(1-c^2))).*normal)

    # return slopes only
    return (out[2]/out[3], out[1]/out[3])
end

pool_caustics = @fum function pool_caustics(y, x, frame; epsilon = 0.1,
                                            waves = NullWave(), depth = 1.0)
    time = frame / FPS

    slopes = top_down_refract(y, x, time, waves, epsilon, depth)

    # find out intersection with plane
    return point(y + depth*(slopes[1]), x + depth*(slopes[2]))
end
end
