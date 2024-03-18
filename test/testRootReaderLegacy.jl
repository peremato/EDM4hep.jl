using EDM4hep.RootIO

@testset "TTreeReaderLegacy" begin
    f =  "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
    #f = "/Users/mato/cernbox/Data/events_000189367.root"

    reader = RootIO.Reader(f)
    events = RootIO.get(reader, "events")
    
    @test reader.isRNTuple == false
    @test length(reader.collectionIDs) == 16
    @test length(reader.btypes) > 54
    @test reader.btypes["Particle"] == MCParticle

    events = RootIO.get(reader, "events")
    @test length(events) == 100000

    # Loop over MC particles
    for evt in Iterators.take(events, 100)
        recps = RootIO.get(reader, evt, "ReconstructedParticles");
        tracks = RootIO.get(reader, evt, "EFlowTrack")
        pids  =  RootIO.get(reader, evt, "ParticleIDs")
        muons = recps[RootIO.get(reader, evt, "Muon#0")]
        if length(muons) == 2
            @test abs(sum(muons.charge)) <= 2.0f0
        end
    end

end
