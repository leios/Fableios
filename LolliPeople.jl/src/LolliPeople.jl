module LolliPeople
using Fable
using Images
using KernelAbstractions

export LolliLayer, LolliPerson

mutable struct LolliLayer <: AbstractLayer
    layer::FractalLayer

    head::FractalOperator
    head_transformations::Union{FractalOperator, Vector{FractalOperator}}
    body::FractalOperator
    body_transformations::Union{FractalOperator, Vector{FractalOperator}}
    eyes::Union{Nothing, FractalUserMethod}
    body_color::FractalUserMethod

    position::Tuple
    world_size::Tuple
    ppu::Number
    params::NamedTuple
    postprocessing_steps::Vector{APP} where APP <: AbstractPostProcess
    additional_fis::Vector{FractalInput}
end

LolliPerson(args...; kwargs...) = LolliLayer(args...; kwargs...)

include("skins/simple.jl")

include("animations/movements.jl")

include("constructor.jl")
end
