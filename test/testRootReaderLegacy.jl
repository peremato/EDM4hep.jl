using EDM4hep
using Test
using EDM4hep.RootIO

#@testset "TTreeReaderLegacy"
    f =  "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"

    reader = RootIO.Reader(f)
    events = RootIO.get(reader, "events")
    
    @test reader.isRNTuple == false
    @test length(reader.collectionIDs) == 16
    @test length(reader.btypes) > 54
    @test reader.btypes["Particle"] == MCParticle

    events = RootIO.get(reader, "events")
    @test length(events) == 100000

    # Loop over MC particles
    evt = events[1]
    recps = RootIO.get(reader, evt, "ReconstructedParticles");
    
    recps[1]
#end
