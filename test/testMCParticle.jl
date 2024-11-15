@testset "MCParticle" begin

    # place the following generator event to the MCParticle collection
    #     name status pdg_id  parent Px       Py    Pz       Energy      Mass
    #  1  !p+!    3   2212    0,0    0.000    0.000 7000.000 7000.000    0.938
    #  2  !p+!    3   2212    0,0    0.000    0.000-7000.000 7000.000    0.938
    # =========================================================================
    #  3  !d!     3      1    1,1    0.750   -1.569   32.191   32.238    0.000
    #  4  !u~!    3     -2    2,2   -3.047  -19.000  -54.629   57.920    0.000
    #  5  !W-!    3    -24    1,2    1.517   -20.68  -20.605   85.925   80.799
    #  6  !gamma! 1     22    1,2   -3.813    0.113   -1.833    4.233    0.000
    #  7  !d!     1      1    5,5   -2.445   28.816    6.082   29.552    0.010
    #  8  !u~!    1     -2    5,5    3.962  -49.498  -26.687   56.373    0.006

    p1 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, 7000.0), generatorStatus=3)
    @test p1.index.index == -1 # unregistered
    @test isbits(p1)
    p1 = register(p1)
    @test p1.index.index == 0
    @test p1.index.collectionID == collectionID(MCParticle)
    @test p1.name == "p+"
    @test p1.energy ≈ sqrt(sum(p1.momentum .^2) + p1.mass^2)

    p2 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, -7000.0), generatorStatus=3)
    @test p2.index.index == -1 # unregistered
    @test p2.momentum.z == -7000.0
    @test p2.mass == 0.938

    p3 = MCParticle(PDG=1, mass=0.0, momentum=(0.750, -1.569, 32.191), generatorStatus=3)
    p3, p1 = add_parent(p3, p1)

    @test p3.index.index >= 0  # both registered
    @test p1.index.index >= 0  # both registered
    @test length(p3.parents) == 1
    @test p3.parents[1] == p1
    @test length(p1.daughters) == 1
    @test p1.daughters[1] == p3

    p4 = MCParticle(PDG=-2, mass=0.0, momentum=(-3.047, -19.000, -54.629), generatorStatus=3)
    p4, p2 = add_parent(p4, p2)
    @test p4.index.index >= 0  # both registered
    @test p2.index.index >= 0  # both registered
    @test length(p4.parents) == 1
    @test p4.parents[1] == p2
    @test length(p2.daughters) == 1
    @test p2.daughters[1] == p4

    p5 = MCParticle(PDG=-24, mass=80.799, momentum=(1.517, -20.68, -20.605), generatorStatus=3)
    p5, p1 = add_parent(p5, p1)
    p5, p2 = add_parent(p5, p2)
    @test length(p5.parents) == 2
    @test length(p1.daughters) == 2
    @test length(p2.daughters) == 2
    @test p5.parents[1] == p1 
    @test p5.parents[2] == p2

    p6 = MCParticle(PDG=22, mass=0.0, momentum=(-3.813, 0.113, -1.833), generatorStatus=1)
    p6, p1 = add_parent(p6, p1)
    p6, p2 = add_parent(p6, p2)

    p7 = MCParticle(PDG=1, mass=0.0, momentum=(-2.445, 28.816, 6.082), generatorStatus=1)
    p7, p5 = add_parent(p7, p5)
    @test length(p7.parents) == 1
    @test p7.parents[1] == p5

    p8 = MCParticle(PDG=-2, mass=0.0, momentum=(3.962, -49.498, -26.687), generatorStatus=1)
    #p8, p5 = add_parent(p8, p5)
    p5, p8 = add_daughter(p5,p8) # should be equivalent to add_parent(p8, p5)
    @test length(p8.parents) == 1
    @test p8.parents[1] == p5
    @test length(p5.daughters) == 2
    @test p5.daughters[1] == p7
    @test p5.daughters[2] == p8

    @test length(getEDCollection(MCParticle)) == 8

    # Iterate over particles, daughters and parents
    for p in getEDCollection(MCParticle)
        for d in p.daughters  # each particle with daughters must be in the parents of each daughter 
            @test p in d.parents
        end
        for m in p.parents
            @test p in m.daughters  # each particle with parents must be in the daughters of each parent 
        end
    end

    # init and empty store
    emptyEDStore()
    p1 = MCParticle() |> register
    p2 = MCParticle() |> register
    @test p1.index.index == 0
    @test p2.index.index == 1

    getEDCollection(MCParticle) |> empty!
    p1 = MCParticle() |> register
    p2 = MCParticle() |> register
    @test p1.index.index == 0
    @test p2.index.index == 1

end