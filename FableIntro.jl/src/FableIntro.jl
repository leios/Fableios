module FableIntro

using Fable
using Colors
using Random
using Images

include("fums.jl")
include("scene_1.jl")

function make_video(num_particles, num_iterations; ArrayType = Array,
                    filebase = "output/out",
                    start_time = 0, end_time = 1/Fable.FPS)
    world_size = (9*0.125, 16*0.125)
    ppu = 1920/world_size[2]
    scene_1(num_particles, num_iterations; ArrayType = ArrayType,
            start_time = 0, end_time = end_time, world_size = world_size,
            ppu = ppu, filebase = filebase)
end
end
