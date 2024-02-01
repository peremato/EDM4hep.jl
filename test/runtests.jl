using Test
using EDM4hep

@testset "EDM4hep tests" verbose = true begin
    include("testComponents.jl")      # unit test basic components
    include("testMCParticle.jl")      # one-to-many relation
    include("testSimTrackerHit.jl")   # one-to-one relation
    include("testParticleID.jl")      # vector members
    #---ROOT I/O----------------------
    include("testRootReader.jl")      # TTree and RNTuple reader
end
