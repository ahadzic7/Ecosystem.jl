abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

mutable struct Animal{A<:AnimalSpecies} <: Agent{A}
    const id::Int
    energy::Float64
    const Δenergy::Float64
    const reprprob::Float64
    const foodprob::Float64
    const sex::Sex
end

Base.show(io::IO, ::Type{Sheep}) = print(io, "🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io, "🐺")

function Base.show(io::IO, a::Animal{A}) where {A<:AnimalSpecies}
    s = a.sex == male ? "♂" : "♀"
    print(io, "$A$s #$(a.id) E=$(a.energy) ΔE=$(a.Δenergy) pr=$(a.reprprob) pf=$(a.foodprob)")
end

function (A::Type{<:AnimalSpecies})(id,E,ΔE,pr,pf,s)
    Animal{A}(id,E,ΔE,pr,pf,s)
end

randsex() = rand(instances(Sex))
Sheep(id; E=4.0, ΔE=0.2, pr=0.8, pf=0.6, s=randsex()) = Sheep(id, E, ΔE, pr, pf, s)
Wolf(id; E=10.0, ΔE=8.0, pr=0.1, pf=0.2, s=randsex()) = Wolf(id, E, ΔE, pr, pf, s)