module LolliPeople
using Fable
using Images
using KernelAbstractions

export LolliLayer, LolliPerson

mutable struct LolliLayer
    layer::FractalLayer

    head::FractalOperator
    head_transforms::Union{Tuple, FractalOperator,
                           Vector{FractalOperator},
                           Nothing}
    body::FractalOperator
    body_transforms::Union{Tuple, FractalOperator,
                           Vector{FractalOperator},
                           Nothing}

    pre_objects::Union{Vector{FractalOperator}, Nothing, Vector{Nothing}}
    pre_object_transforms::Union{Tuple, FractalOperator,
                                 Vector{FractalOperator},
                                 Nothing, Vector{Nothing}}

    post_objects::Union{Vector{FractalOperator}, Nothing, Vector{Nothing}}
    post_object_transforms::Union{Tuple, FractalOperator,
                                  Vector{FractalOperator},
                                  Nothing, Vector{Nothing}}

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
Fable.run!(layer::LolliLayer; kwargs...) = Fable.run!(layer.layer; kwargs...)
Fable.reset!(layer::LolliLayer) = Fable.reset!(layer.layer)

LolliPerson(args...; kwargs...) = LolliLayer(args...; kwargs...)

include("skins/simple.jl")

include("animations/movements.jl")

include("constructor.jl")
end
