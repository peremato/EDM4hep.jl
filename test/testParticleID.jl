@testset "ParticleID" begin

    pid1 = ParticleID(type=1, PDG=11) |> register
    pid2 = ParticleID(type=2, PDG=22, parameters=[1.0f0, 2.0f0, 3.0f0]) |> register

    @test !iszero(pid1.index)
    @test !iszero(pid1.index)

    @test length(pid1.parameters) == 0
    @test length(pid2.parameters) == 3

    pid1 = set_parameters(pid1, pid2.parameters) # can we make this more generically?
    @test length(pid1.parameters) == 3

    @test pid2.parameters[1] == 1.0f0
    @test pid2.parameters[2] == 2.0f0
    @test pid2.parameters[3] == 3.0f0
end
