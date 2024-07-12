module LolliPeople
using Fable
using Images

export LolliLayer, LolliPerson

mutable struct LolliLayer
    layer::FableLayer

    head::FableOperator
    head_transforms::Union{Tuple, FableOperator,
                           Vector{FableOperator},
                           Nothing}
    body::FableOperator
    body_transforms::Union{Tuple, FableOperator,
                           Vector{FableOperator},
                           Nothing}

    pre_objects::Union{Vector{FableOperator}, Nothing, Vector{Nothing}}
    pre_object_transforms::Union{Tuple, FableOperator,
                                 Vector{FableOperator},
                                 Nothing, Vector{Nothing}}

    post_objects::Union{Vector{FableOperator}, Nothing, Vector{Nothing}}
    post_object_transforms::Union{Tuple, FableOperator,
                                  Vector{FableOperator},
                                  Nothing, Vector{Nothing}}

    eyes::Union{Nothing, FableUserMethod}
    body_color::FableUserMethod

    position::Tuple
    world_size::Tuple
    ppu::Number
    params::NamedTuple
    postprocessing_steps::Vector{APP} where APP <: AbstractPostProcess
    additional_fis::Vector{FableInput}
end

Fable.to_canvas!(layer::LolliLayer) = Fable.to_canvas!(layer.layer)
Fable.run!(layer::LolliLayer; kwargs...) = Fable.run!(layer.layer; kwargs...)
Fable.reset!(layer::LolliLayer) = Fable.reset!(layer.layer)

LolliPerson(args...; kwargs...) = LolliLayer(args...; kwargs...)

include("skins/simple.jl")

include("animations/movements.jl")

include("constructor.jl")
end
