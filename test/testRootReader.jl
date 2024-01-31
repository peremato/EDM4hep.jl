using EDM4hep.RootIO

@testset "$(T)Reader" for T in (:TTree, :RNTuple)

    if T == :RNTuple
        f = joinpath(@__DIR__, "../examples/Output_REC_rntuple.root")
    else
        f = joinpath(@__DIR__, "../examples/Output_REC.root")
    end

    reader = RootIO.Reader(f)
    events = RootIO.get(reader, "events")
    
    @test reader.isRNTuple == (T == :RNTuple)
    @test length(reader.collectionIDs) == 88
    @test length(reader.btypes) > 88
    @test reader.btypes["MCParticle"] == MCParticle

    events = RootIO.get(reader, "events")
    @test length(events) == 25

    # Loop over MC particles
    evt = events[1]
    hits = RootIO.get(reader, evt, "InnerTrackerBarrelCollection")
    mcps = RootIO.get(reader, evt, "MCParticle")

    collid = reader.collectionIDs["InnerTrackerBarrelCollection"]
    for (i,hit) in enumerate(hits[1:20])
        @test hit.index.collectionID == collid
        @test hit.index.index == i - 1
        @test hit.mcparticle isa MCParticle
    end

    for p in mcps[1:20]
        for d in p.daughters  # each particle with daughters must be in the parents of each daughter
            @test p in d.parents
        end
        #if !isempty(p.daughters)  # momentum conservation
        #    pmomentum = sum(Set(m.momentum for d in p.daughters for m in d.parents))    # sum the momentum of the parents
        #    @test !isapprox(pmomentum, sum(d.momentum for d in p.daughters), atol=1e-1) # compare with the sum of the daughters
        #end
        for m in p.parents
            @test p in m.daughters  # each particle with parents must be in the daughters of each parent 
        end
    end

    barrel_clusters = RootIO.get(reader, evt, "ECalBarrelCollection")
    contributions = RootIO.get(reader, evt, "AllCaloHitContributionsCombined")

    for c in barrel_clusters[1:20]
        if length(c.contributions) > 0
            @test c.contributions[1] isa CaloHitContribution
        end
    end

end
 