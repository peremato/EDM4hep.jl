using Accessors

@testset "CovMatrix" begin
    # Test the CovMatrix3f default constructor
    cov = CovMatrix3f()
    @test cov[1,1] == 0.0f0
    # Test that accessing an out-of-bounds index throws an error
    @test_throws BoundsError cov[4,2]

    # Test setindex() of CovMatrix3f
    cov = @set cov[3] = 3.14f0
    @test cov[3] == 3.14f0
    cov = @set cov[3,2] = 2.14f0
    @test cov[3,2] == 2.14f0
    @test cov[2,3] == 2.14f0
    @test cov[5] == 2.14f0 
    @test cov.values[3] == 3.14f0

    # Test the CovMatrix3f constructor with values
    cov = CovMatrix3f(1.0f0, 2.0f0, 3.0f0, 4.0f0, 5.0f0, 6.0f0)
    i = 1.0f0
    for c in cov
        @test c == i
        i += 1.0f0   
    end
    @test cov[1,1] == 1.0f0
    @test cov[2,2] == 3.0f0
    @test cov[3,3] == 6.0f0


    # Test embedded in a TrackerHit3D
    hit = TrackerHit3D(covMatrix=CovMatrix3f(1.0f0, 2.0f0, 3.0f0, 4.0f0, 5.0f0, 6.0f0))

    @test hit.covMatrix[1,1] == 1.0f0
    @test hit.covMatrix[2,2] == 3.0f0
    @test hit.covMatrix[3,3] == 6.0f0

    # Set CovMatrix3f in TrackerHit3D (create a new TrackerHit3D with the new CovMatrix3f)
    hit = @set hit.covMatrix[3,1] = 3.14f0
    @test hit.covMatrix[3,1] == 3.14f0
    @test hit.covMatrix[1,3] == 3.14f0
    @test hit.covMatrix[4] == 3.14f0
    @test hit.covMatrix[1,1] == 1.0f0
    @test hit.covMatrix[2,2] == 3.0f0
    @test hit.covMatrix[3,3] == 6.0f0

end
