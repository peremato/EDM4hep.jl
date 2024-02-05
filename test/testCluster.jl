# struct Cluster <: POD
#     index::ObjectID{Cluster}         # ObjectID of himself
#     #---Data Members
#     type::Int32                      # flagword that defines the type of cluster. Bits 16-31 are used internally.
#     energy::Float32                  # energy of the cluster [GeV]
#     energyError::Float32             # error on the energy
#     position::Vector3f               # position of the cluster [mm]
#     positionError::SVector{6,Float32}  # covariance matrix of the position (6 Parameters)
#     iTheta::Float32                  # intrinsic direction of cluster at position  Theta. Not to be confused with direction cluster is seen from IP.
#     phi::Float32                     # intrinsic direction of cluster at position - Phi. Not to be confused with direction cluster is seen from IP.
#     directionError::Vector3f         # covariance matrix of the direction (3 Parameters) [mm^2]
#     #---VectorMembers
#     shapeParameters::PVector{Cluster,Float32,1}  # shape parameters - check/set collection parameter ClusterShapeParameters for size and names of parameters.
#     subdetectorEnergies::PVector{Cluster,Float32,2}  # energy observed in a particular subdetector. Check/set collection parameter ClusterSubdetectorNames for decoding the indices of the array.
#     #---OneToManyRelations
#     clusters::Relation{Cluster,Cluster,1}  # clusters that have been combined to this cluster.
#     hits::Relation{Cluster,CalorimeterHit,2}  # hits that have been combined to this cluster.
#     particleIDs::Relation{Cluster,ParticleID,3}  # particle IDs (sorted by their likelihood)
# end

@testset "Cluster" begin
    emptyEDStore()

    h1 = CalorimeterHit(cellID=0x1) |> register
    h2 = CalorimeterHit(cellID=0x2) |> register
    pid1 = ParticleID(type=1) |> register
    pid2 = ParticleID(type=2) |> register
    c1 = Cluster(type=1, positionError=(1,2,3,4,5,6), directionError=(1,2,3)) |> register

    @test c1.type == 1
    @test c1.positionError[1] == 1.0
    @test c1.positionError[6] == 6.0

    @test_throws ArgumentError popFromHits(c1)

    c1 = pushToHits(c1, h1)
    c1 = pushToHits(c1, h2)

    @test length(c1.hits) == 2
    c1 = popFromHits(c1)
    @test length(c1.hits) == 1
    c1 = popFromHits(c1)
    @test length(c1.hits) == 0

    c1 = pushToHits(c1, h1)
    c1 = pushToHits(c1, h2)
    
    c1 = pushToParticleIDs(c1, pid1)
    c1 = pushToParticleIDs(c1, pid2)
    @test length(c1.particleIDs) == 2
    @test c1.particleIDs[1].type == 1
    @test c1.particleIDs[2].type == 2

    c1 = pushToClusters(c1, Cluster(type=2))
    c1 = pushToClusters(c1, Cluster(type=3))
    @test length(c1.clusters) == 2
    @test c1.clusters[1].type == 2
    @test c1.clusters[2].type == 3

    @test c1.hits[1].cellID == 0x1
    @test c1.hits[2].cellID == 0x2


    c1 = setShapeParameters(c1, [1.0f0,2.0f0,3.0f0])
    c1 = setSubdetectorEnergies(c1, [10.0f0,20.0f0,30.0f0])
    @test length(c1.shapeParameters) == 3
    @test length(c1.subdetectorEnergies) == 3
    @test c1.shapeParameters == [1.0f0,2.0f0,3.0f0]
    @test c1.subdetectorEnergies == [10.0f0,20.0f0,30.0f0]

    @test length(getEDStore(Cluster).objects) == 3
    @test length(getEDStore(CalorimeterHit).objects) == 2
    @test length(getEDStore(ParticleID).objects) == 2

end
