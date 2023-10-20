module Ecosystem

using Revise

# Write your package code here.

abstract type Species end
abstract type Agent{S<:Species} end

@enum Sex female male

export Agent, Species, Sex, male, female

include("./animal.jl")
export Sheep, Wolf, AnimalSpecies, Animal

include("./plant.jl")
export Grass, PlantSpecies

include("./world.jl")
export World, kill_agent!, every_nth, find_food, reproduce!, find_mate, agent_step!, agent_count, world_step!, eat!

end
