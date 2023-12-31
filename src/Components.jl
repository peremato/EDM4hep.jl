using Accessors     #  To create new inmutable object just changing one property
using Corpuscles    #  PDG database
using StaticArrays  #  Needed for fix lenght arrays in datatypes

export register, relations, Relation, ObjectID

include("../podio/genComponents.jl")

#---Vector3d
Base.convert(::Type{Vector3d}, t::Tuple) = Vector3d(t...)
Base.show(io::IO, v::Vector3d) = print(io, "($(v.x),$(v.y),$(v.z))")
Base.:+(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:*(v::Vector3d, a::Number) = Vector3d(a*v.x, a*v.y, b*v.z)

#---Vector3f
Base.convert(::Type{Vector3f}, t::Tuple) = Vector3f(t...)
Base.show(io::IO, v::Vector3f) = print(io, "($(v.x),$(v.y),$(v.z))")
Base.:+(v1::Vector3f, v2::Vector3f) = Vector3f(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vector3f, v2::Vector3f) = Vector3f(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:*(v::Vector3f, a::Number) = Vector3f(a*v.x, a*v.y, b*v.z)

#---Vector2i
Base.convert(::Type{Vector2i}, t::Tuple) = Vector2i(t...)
Base.show(io::IO, v::Vector2i) = print(io, "($(v.a),$(v.b))")
Base.:+(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a + v2.a, v1.b + v2.b)
Base.:-(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a - v2.a, v1.b - v2.b)
Base.:*(v::Vector2i, a::Int32) = Vector3d(a*v.a, a*v.b)

#--------------------------------------------------------------------------------------------------
#---ObjectID{ED}-----------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
abstract type POD end

struct ObjectID{ED <: POD} <: POD
    index::Int32
    collectionID::UInt32
end

Base.zero(::Type{ObjectID{ED}}) where ED = ObjectID{ED}(-1,0)
Base.iszero(x::ObjectID{ED}) where ED = x.index == -1
Base.show(io::IO, x::ObjectID{ED}) where ED = print(io, "#$(x.index+1)")
Base.convert(::Type{Integer}, i::ObjectID{ED}) where ED = i.index+1
Base.convert(::Type{ED}, i::ObjectID{ED}) where ED = iszero(i.index+1) ? nothing : @inbounds EDStore_objects(ED)[i.index+1]
Base.convert(::Type{ObjectID{ED}}, p::ED) where ED = iszero(p.index) ? register(p).index : return p.index
Base.convert(::Type{ObjectID{ED}}, i::Integer) where ED = ObjectID{ED}(i,0)
Base.eltype(::Type{ObjectID{ED}}) where ED = ED
Base.:-(i::ObjectID{ED}) where ED = ObjectID{ED}(-i.index)
function register(p::ED) where ED
    store::Vector{ED} = EDStore_objects(ED)
    !iszero(p.index) && error("Registering an already registered MCParticle $p")
    last = lastindex(store)
    p = @set p.index = ObjectID{ED}(last, 0)
    push!(store, p)
    return p
end
function update(p::ED) where ED
    EDStore_objects(ED)[p.index.index+1] = p
end

#--------------------------------------------------------------------------------------------------
#---Relation{ED} for implementation of OneToManyRelation-------------------------------------------
#--------------------------------------------------------------------------------------------------
struct Relation{ED<:POD,N}
    first::UInt32    # first index (starts with 0)
    last::UInt32     # last index (starts with 0)
    Relation{ED,N}(first=0, last=0) where {ED,N} = new(first, last)
end
indices(r::Relation{ED,N}) where {ED,N} = [p.index+1 for p in EDStore_relations(ED,N)[r.first+1:r.last]]
function Base.show(io::IO, r::Relation{ED}) where ED
    try
        idxs = indices(r)
        print(io, isempty(idxs) ? "$ED#[]" : "$ED#$idxs")
    catch
        print(io, "$ED(first=$(r.first), last=$(r.last))")
    end
end
Base.iterate(r::Relation{ED,N}, i=1) where {ED,N} = i > (r.last-r.first) ? nothing : (convert(ED, EDStore_relations(ED,N)[r.first + i]), i + 1)
Base.getindex(r::Relation{ED,N}, i) where {ED,N} = 0 < i <= (r.last - r.first) ? convert(ED, EDStore_relations(ED,N)[r.first + i - 1]) : throw(BoundsError(r,i))
Base.size(r::Relation{ED}) where ED = (r.last-r.first,)
Base.length(r::Relation{ED}) where ED = r.last-r.first
Base.eltype(::Type{Relation{ED}}) where ED = ED

const InitAlloc = 4
function push(r::Relation{ED,N}, p::ED) where {ED,N}
    relations = EDStore_relations(ED,N)
    (;first, last) = r
    length = last-first
    tail = lastindex(relations)
    append!(relations, zeros(ObjectID{ED}, length+1))      # add extended indices at the end
    relations[tail + 1:tail + length] = relations[first+1:last]  # copy indices
    relations[first + 1:last] .= zeros(ObjectID{ED},length)                  # reset unused indices
    first = tail
    last  = first + length + 1
    relations[last] = p
    Relation{ED,N}(first, last)
end
