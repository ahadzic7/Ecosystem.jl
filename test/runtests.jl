using Ecosystem
using Test

@testset "Ecosystem.jl" begin
    # Write your tests here.

end

@testset "Base.show" begin
    g = Grass(1, 1, 1)
    s = Sheep(2,1,1,1,1,male)
    w = Animal{Wolf}(3,1,1,1,1,female)
    @test repr(g) == "🌿  #1 100% grown"
    @test repr(s) == "🐑♂ #2 E=1.0 ΔE=1.0 pr=1.0 pf=1.0"
    @test repr(w) == "🐺♀ #3 E=1.0 ΔE=1.0 pr=1.0 pf=1.0"
end
