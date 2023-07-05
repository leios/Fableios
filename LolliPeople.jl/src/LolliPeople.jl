module LolliPeople
using Fable
using Images
using KernelAbstractions

export LolliLayer, LolliPerson

mutable struct LolliLayer
    layer::FractalLayer

    head::FractalOperator
    head_transformations::Union{FractalOperator,
                                Vector{FractalOperator},
                                Nothing}
    body::FractalOperator
    body_transformations::Union{FractalOperator,
                                Vector{FractalOperator},
                                Nothing}
    eyes::Union{Nothing, FractalUserMethod}
    body_color::FractalUserMethod

    position::Tuple
    world_size::Tuple
    ppu::Number
    params::NamedTuple
    postprocessing_steps::Vector{APP} where APP <: AbstractPostProcess
    additional_fis::Vector{FractalInput}
end

Fable.to_canvas!(layer::LolliLayer) = Fable.to_canvas!(layer.layer)
Fable.run!(layer::LolliLayer) = Fable.run!(layer.layer)

LolliPerson(args...; kwargs...) = LolliLayer(args...; kwargs...)

include("skins/simple.jl")

include("animations/movements.jl")

include("constructor.jl")
end
