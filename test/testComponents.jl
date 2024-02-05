@testset "Components" begin
    v3f = Vector3f(1,2,3)
    @test v3f.x == 1.0f0
    @test v3f.y == 2.0f0
    @test v3f.z == 3.0f0

    @test v3f == Vector3f(1.,2.,3.)
    @test 2v3f == v3f + 2v3f - v3f
    @test 2v3f ≈ Vector3f(2,4,6)
    @test sum(v3f) ≈ 6
    v3f1::Vector3f = (1.0f0, 2.0f0, 3.0f0)
    @test v3f == v3f1

    v3d = Vector3d(10,20,30)
    @test v3d.x == 10.
    @test v3d.y == 20.
    @test v3d.z == 30.
    @test 2v3d == v3d + 2v3d - v3d
    @test 2v3d ≈ Vector3d(20,40,60)  

    v4f = Vector4f(2,4,6,8)
    @test v4f.x == 2.
    @test v4f.y == 4.
    @test v4f.z == 6.
    @test v4f.t == 8.
    @test 2v4f == v4f + 2v4f - v4f
    @test 2v4f ≈ v4f + v4f

    v2i = Vector2i(1,2)
    @test v2i.a == 1
    @test v2i.b == 2
    @test 2v2i == v2i + v2i

    oid = ObjectID{Vertex}(10,0x12345678)
    @test oid.index == 10
    @test oid.collectionID == 0x12345678
    @test eltype(oid) == Vertex

    zid = zero(ObjectID{Vertex})
    @test zid.index == -1
    @test zid.collectionID == 0
end
