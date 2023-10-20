mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end

function World(agents::Vector{<:Agent})
    max_id = maximum(a.id for a in agents)
    World(Dict(a.id=>a for a in agents), max_id)
end

function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (_,a) in w.agents
        println(io,"  $a")
    end
end


kill_agent!(a::Animal, w::World) = delete!(w.agents, a.id)

mates(a1::Animal{A}, a2::Animal{A}) where A<:AnimalSpecies = a1.sex != a2.sex
mates(::Agent, ::Agent) = false

function find_mate(a::Animal, w::World)
    partners = filter(x -> mates(a, x), collect(values(w.agents)))
    isempty(partners) ? nothing : rand(partners)
end

function reproduce!(a::Animal{A}, w::World) where {A}
    mate = find_mate(a, w)
    mate |> isnothing && return

    a.energy /= 2

    vals = [getproperty(a,n) for n in fieldnames(Animal) if n ∉ [:id, :sex]]
    new_id = w.max_id + 1
    ŝ = Animal{A}(new_id, vals..., randsex())
    w.agents[ŝ.id] = ŝ
    w.max_id = new_id
end

eats(::Animal{Sheep},g::Plant{Grass}) = g.size > 0
eats(g::Plant{Grass},::Animal{Sheep}) = false
eats(::Animal{Wolf}, ::Animal{Sheep}) = true
eats(s::Animal{Sheep}, w::Animal{Wolf}) = !eats(w,s)
eats(::Animal{Wolf},g::Plant{Grass}) = false
eats(::Animal{A}, ::Animal{A}) where A <: AnimalSpecies = false

function find_food(a::Animal, w::World)    
    foods = filter(x -> eats(a, x), collect(values(w.agents)))
    return isempty(foods) ? nothing : rand(foods)
end

function every_nth(f::Function, n::Int) 
    counter = 0
    function fun(args...)
        counter += 1
        if counter == n
            counter = 0
            return f(args...)
        end
    end
end

agent_count(p::Plant) = p.size / p.max_size
agent_count(::Animal) = 1
agent_count(as::Vector{<:Agent}) = sum(agent_count,as)

function agent_count(w::World)
    function op(d::Dict,a::A) where A<:Agent
        n = nameof(A)
        d[n] = haskey(d,n) ? d[n]+agent_count(a) : agent_count(a)
        return d
    end
    reduce(op, w.agents |> values, init=Dict{Symbol,Float64}())
end

function agent_step!(a::Animal, w::World)
    a.energy -= 1;
    if rand() <= a.foodprob
        food = find_food(a, w)
        !isnothing(food) && eat!(a, food, w)
    end
    if a.energy < 0
        kill_agent!(a, w)
        return
    end
    if rand() <= a.reprprob
        reproduce!(a, w)
    end
end

function agent_step!(p::Plant, w::World)
    if p.size < p.max_size
        p.size += 1
    end
end

function world_step!(world)
    agent_ids = deepcopy(keys(world.agents))
    for id  in agent_ids
        id in keys(world.agents) && agent_step!(world.agents[id], world)
    end
end


function eat!(eater::Animal{Wolf}, eaten::Animal{Sheep}, wrld::World)
    eater.energy += eaten.energy * eater.Δenergy
    kill_agent!(eaten, wrld)
end


function eat!(sheep::Animal{Sheep}, grass::Plant{Grass}, w::World)
    sheep.energy += grass.size * sheep.Δenergy
    grass.size = 0
end