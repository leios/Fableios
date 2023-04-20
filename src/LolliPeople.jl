module LolliPeople
using Fable
using Images
using KernelAbstractions
using CUDA
using AMDGPU

export LolliLayer, LolliPerson

mutable struct LolliLayer <: AbstractLayer
    head::FractalLayer
    eyes::Union{Nothing, FractalUserMethod}
    body::FractalLayer

    angle::Union{FT, FractalInput} where FT <: Number
    foot_position::Union{Tuple, FractalInput}
    head_height::Union{FT, FractalInput} where FT <: Number

    body_color::FractalUserMethod

    transform::Union{Nothing, FractalUserMethod}
    head_transform::Union{Nothing, FractalUserMethod}
    body_transform::Union{Nothing, FractalUserMethod}

    canvas::Union{Array{C}, CuArray{C}, ROCArray{C}} where C <: RGBA
    position::Tuple
    world_size::Tuple
    ppu::Number
    params::NamedTuple
    postprocessing_steps::Vector{APP} where APP <: AbstractPostProcess
    additional_fis::Vector{FractalInput}
end

LolliPerson(args...; kwargs...) = LolliLayer(args...; kwargs...)

include("fable_interface.jl")

include("skins/simple.jl")

include("animations/movements.jl")

include("constructor.jl")
end
