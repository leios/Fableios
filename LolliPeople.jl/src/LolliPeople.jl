module LolliPeople
using Fable
using Images
using KernelAbstractions

export LolliLayer, LolliPerson

mutable struct LolliLayer <: AbstractLayer
    head::FractalLayer
    eyes::Union{Nothing, FractalUserMethod}
    body::FractalLayer

    body_color::FractalUserMethod

    canvas::AT where AT <: AbstractArray{C} where C <: RGBA
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
