@testset "SimTrackerHit" begin

    p1 = MCParticle(PDG=1) |> register
    p2 = MCParticle(PDG=2) |> register

    @test !iszero(p1.index)
    @test !iszero(p2.index)
    
    nsh = 5
    for j in 1:nsh
        SimTrackerHit(cellID=0xabadcaffee, EDep=j*0.000001, position=(j * 10., j * 20., j * 5.), mcparticle=p1) |> register
        SimTrackerHit(cellID=0xcaffeebabe, EDep=j*0.001, position=(-j * 10., -j * 20., -j * 5.), mcparticle=p2) |> register
    end

    hits = getEDStore(SimTrackerHit).objects
    @test length(hits) == 2*nsh

    # iterate over simulation hits
    for (i,hit) in enumerate(hits)
        @test hit.cellID == (isodd(i) ? 0xabadcaffee : 0xcaffeebabe)
        @test hit.mcparticle isa MCParticle
        @test hit.mcparticle.PDG == (isodd(i) ? 1 : 2)
    end
end
