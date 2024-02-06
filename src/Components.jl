using Accessors     #  To create new inmutable object just changing one property
using Corpuscles    #  PDG database
using StaticArrays  #  Needed for fix lenght arrays in datatypes

export register, relations, vmembers, Relation, PVector, ObjectID, collectionID

abstract type POD end # Abstract type to denote a POD from PODIO

include("../podio/genComponents.jl")

#---Vector3d
Base.convert(::Type{Vector3d}, t::Tuple) = Vector3d(t...)
Base.show(io::IO, v::Vector3d) = print(io, "($(v.x), $(v.y), $(v.z))")
Base.:+(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vector3d, v2::Vector3d) = Vector3d(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:*(v::Vector3d, a::Number) = Vector3d(a*v.x, a*v.y, a*v.z)
Base.:*(a::Number, v::Vector3d) = v * a
function Base.isapprox(v1::Vector3d, v2::Vector3d; atol::Real=0, rtol::Real=Base.rtoldefault(Float64,Float64,atol), nans::Bool=false)
    isapprox(v1.x, v2.x; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.y, v2.y; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.z, v2.z; atol=atol, rtol=rtol, nans=nans)
end
Base.iterate(v::Vector3d, i=1) = i > 3 ? nothing : (getproperty(v, propertynames(v)[i]), i+1)
Base.length(v::Vector3d) = 3

#---Vector3f
Base.convert(::Type{Vector3f}, t::Tuple) = Vector3f(t...)
Base.show(io::IO, v::Vector3f) = print(io, "($(v.x), $(v.y), $(v.z))")
Base.:+(v1::Vector3f, v2::Vector3f) = Vector3f(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:-(v1::Vector3f, v2::Vector3f) = Vector3f(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.:*(v::Vector3f, a::Number) = Vector3f(a*v.x, a*v.y, a*v.z)
Base.:*(a::Number, v::Vector3f) = v * a
function Base.isapprox(v1::Vector3f, v2::Vector3f; atol::Real=0, rtol::Real=Base.rtoldefault(Float32,Float32,atol), nans::Bool=false)
    isapprox(v1.x, v2.x; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.y, v2.y; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.z, v2.z; atol=atol, rtol=rtol, nans=nans)
end
Base.iterate(v::Vector3f, i=1) = i > 3 ? nothing : (getproperty(v, propertynames(v)[i]), i+1)
Base.length(v::Vector3f) = 3

#---Vector2i
Base.convert(::Type{Vector2i}, t::Tuple) = Vector2i(t...)
Base.show(io::IO, v::Vector2i) = print(io, "($(v.a), $(v.b))")
Base.:+(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a + v2.a, v1.b + v2.b)
Base.:-(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a - v2.a, v1.b - v2.b)
Base.:*(v::Vector2i, a::Number) = Vector3d(a*v.a, a*v.b)
Base.:*(a::Number, v::Vector2i) = v * a

#---Vector4f
Base.convert(::Type{Vector4f}, t::Tuple) = Vector4f(t...)
Base.show(io::IO, v::Vector4f) = print(io, "($(v.x), $(v.y), $(v.z), $(v.t))")
Base.:+(v1::Vector4f, v2::Vector4f) = Vector4f(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.t + v2.t)
Base.:-(v1::Vector4f, v2::Vector4f) = Vector4f(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.t - v2.t)
Base.:*(v::Vector4f, a::Number) = Vector4f(a*v.x, a*v.y, a*v.z, a*v.t)
Base.:*(a::Number, v::Vector4f) = v * a
function Base.isapprox(v1::Vector4f, v2::Vector4f; atol::Real=0, rtol::Real=Base.rtoldefault(Float32,Float32,atol), nans::Bool=false)
    isapprox(v1.x, v2.x; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.y, v2.y; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.z, v2.z; atol=atol, rtol=rtol, nans=nans) &&
    isapprox(v1.t, v2.t; atol=atol, rtol=rtol, nans=nans)
end

#--------------------------------------------------------------------------------------------------
#---ObjectID{ED}-----------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
struct ObjectID{ED <: POD} <: POD
    index::Int32
    collectionID::UInt32
end

Base.zero(::Type{ObjectID{ED}}) where ED = ObjectID{ED}(-1,0)
Base.iszero(x::ObjectID{ED}) where ED = x.index == -1
Base.show(io::IO, x::ObjectID{ED}) where ED = print(io, "#$(x.index+1)")
Base.convert(::Type{Integer}, i::ObjectID{ED}) where ED = i.index+1
Base.convert(::Type{ED}, i::ObjectID{ED}) where ED = iszero(i.index+1) ? nothing : @inbounds EDStore_objects(ED, i.collectionID)[i.index+1]
Base.convert(::Type{ObjectID{ED}}, p::ED) where ED = iszero(p.index) ? register(p).index : return p.index
Base.convert(::Type{ObjectID{ED}}, i::Integer) where ED = ObjectID{ED}(i,0)
Base.eltype(::Type{ObjectID{ED}}) where ED = ED
Base.:-(i::ObjectID{ED}) where ED = ObjectID{ED}(-i.index)
function register(p::ED) where ED
    collid = collectionID(ED)
    store::Vector{ED} = EDStore_objects(ED, collid)
    !iszero(p.index) && error("Registering an already registered MCParticle $p")
    last = lastindex(store)
    p = @set p.index = ObjectID{ED}(last, collid)
    push!(store, p)
    return p
end
function update(p::ED) where ED
    iszero(p.index) && (p = register(p))  # need to register if not done
    EDStore_objects(ED)[p.index.index+1] = p
end
function collectionID(::Type{ED}) where ED
    hash(ED) % UInt32  # Use the hash of the Type
end
hex(x::UInt32) = "0x$(string(x,base=16,pad=8))"
hex(x::UInt16) = "0x$(string(x,base=16,pad=4))"
hex(x::UInt64) = "0x$(string(x,base=16,pad=16))"

#--------------------------------------------------------------------------------------------------
#---Relation{ED} for implementation of OneToManyRelation-------------------------------------------
#--------------------------------------------------------------------------------------------------
struct Relation{ED<:POD,TD<:POD,N}
    first::UInt32    # first index (starts with 0)
    last::UInt32     # last index (starts with 0)
    collid::UInt32   # Collection ID of the data object (when is read) or 0 if newly created
    Relation{ED,TD,N}(first=0, last=0, collid=0) where {ED,TD,N} = new(first, last, collid)
end
indices(r::Relation{ED,TD,N}) where {ED,TD,N} = [p.index+1 for p in EDStore_relations(ED,N,r.collid)[r.first+1:r.last]]
function Base.show(io::IO, r::Relation{ED,TD}) where {ED,TD}
    try
        idxs = indices(r)
        print(io, isempty(idxs) ? "$TD#[]" : "$TD#$idxs")
    catch
        print(io, "$TD(first=$(r.first), last=$(r.last))")
    end
end
function Base.iterate(r::Relation{ED,TD,N}, i=1) where {ED,TD,N}
    if i > (r.last-r.first)
        return nothing
    else
        rel = EDStore_relations(ED,N,r.collid)   # Normally, the relations have been read and should not fail
        oid = rel[r.first + i]
        if !hasEDStore(oid.collectionID)
            @warn "Cannot iterate on this relation because the collection with ID $(hex(oid.collectionID)) has not been loaded!"
            return nothing
        else
            obj = convert(TD, oid)
            return (obj, i + 1)
        end
    end
end
Base.getindex(r::Relation{ED,TD,N}, i) where {ED,TD,N} = 0 < i <= (r.last - r.first) ? convert(TD, EDStore_relations(ED,N,r.collid)[r.first + i]) : throw(BoundsError(r,i))
Base.size(r::Relation) = (r.last-r.first,)
Base.length(r::Relation) = r.last-r.first
Base.eltype(::Type{Relation{ED,TD,N}}) where {ED,TD,N} = TD
function relations(::Type{ED}) where ED
    (ft for ft in fieldtypes(ED) if ft <: Relation)
end
function vmembers(::Type{ED}) where ED
    (ft for ft in fieldtypes(ED) if ft <: PVector)
end

function push(r::Relation{ED,TD,N}, p::TD) where {ED,TD,N}
    (;first, last, collid) = r
    relations = EDStore_relations(ED, N, collid)
    length = last-first
    tail = lastindex(relations)
    append!(relations, zeros(ObjectID{TD}, length+1))            # add extended indices at the end
    relations[tail + 1:tail + length] = relations[first+1:last]  # copy indices
    relations[first + 1:last] .= zeros(ObjectID{TD},length)      # reset unused indices
    first = tail
    last  = first + length + 1
    relations[last] = p
    Relation{ED,TD,N}(first, last, collid)
end

function pop(r::Relation{ED,TD,N}) where {ED,TD,N}
    (;first, last, collid) = r
    (last - first <= 0) && throw(ArgumentError("relation must be non-empty"))
    relations = EDStore_relations(ED, N, collid)
    relations[last] = zero(ObjectID{TD})
    return Relation{ED,TD,N}(first, last-1, collid)
end

#--------------------------------------------------------------------------------------------------
#---PVector{ED,N} for implementation of VectorMembers----------------------------------------------
#--------------------------------------------------------------------------------------------------
struct PVector{ED<:POD,T, N} <: AbstractVector{T}
    first::UInt32    # first index (starts with 0)
    last::UInt32     # last index (starts with 0)
    collid::UInt32   # Collection ID of the data object (when is read) or 0 if newly created
    PVector{ED,T,N}(first=0, last=0, collid=0) where {ED,T,N} = new(first, last, collid)
end
values(v::PVector{ED,T,N}) where {ED,T,N} = EDStore_pvectors(ED,N,v.collid)[v.first+1:v.last]
Base.show(io::IO, v::PVector{ED}) where ED = show(io, values(v))

function Base.iterate(v::PVector{ED,T, N}, i=1) where {ED,T,N}
    if i > (v.last-v.first)
        return nothing
    else
        val = EDStore_pvectors(ED,N,v.collid)   # Normally, the pvectors have been read and should not fail
        obj = val[v.first + i]
        return (obj, i + 1)
    end
end
Base.getindex(v::PVector{ED,T, N}, i) where {ED,T, N} = 0 < i <= (v.last - v.first) ? EDStore_pvectors(ED,N,v.collid)[v.first + i] : throw(BoundsError(v,i))
Base.size(v::PVector{ED,T,N}) where {ED,T,N} = (v.last-v.first,)
Base.length(v::PVector{ED,T,N}) where {ED,T,N} = v.last-v.first
Base.eltype(::Type{PVector{ED,T,N}}) where {ED,T,N} = T
function Base.convert(::Type{PVector{ED,T,N}}, v::AbstractVector{T}) where {ED,T,N}
    pvectors = EDStore_pvectors(ED,N)
    tail = lastindex(pvectors)
    len  = length(v)
    append!(pvectors, v)
    PVector{ED,T,N}(tail, tail + len)
end
