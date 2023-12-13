@testset "MCParticle" begin
    p1 = MCParticle()
    @test p1.index.index == -1 # unregistered
    @test isbits(p1)
    p1 = register(p1)
    @test p1.index.index == 0
    p2 = MCParticle(PDG=11)
    @test p2.index.index == -1
    p2 = register(p2)
    @test p2.index.index == 1


end