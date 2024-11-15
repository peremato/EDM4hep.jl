using Accessors     #  To create new immutable object just changing one property
using Corpuscles    #  PDG database
using StaticArrays  #  Needed for fix length arrays in datatypes

export register, relations, vmembers, Relation, PVector, ObjectID, collectionID, θ, ϕ
export @set

abstract type POD end # Abstract type to denote a POD from PODIO

include("../podio/genComponents.jl")

#---Vector3d
Base.convert(::SVector{3,Float64}, v::Vector3d) = SVector{3,Float64}(v...)
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
θ(v::Vector3d) = atan(√(v.x^2+v.y^2), v.z)
ϕ(v::Vector3d) = atan(v.y, v.x)
Base.zero(::Type{Vector3d}) = Vector3d()

#---Vector3f
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
θ(v::Vector3f) = atan(√(v.x^2+v.y^2), v.z)
ϕ(v::Vector3f) = atan(v.y, v.x)
Base.zero(::Type{Vector3f}) = Vector3f()

#---Vector2i
Base.show(io::IO, v::Vector2i) = print(io, "($(v.a), $(v.b))")
Base.:+(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a + v2.a, v1.b + v2.b)
Base.:-(v1::Vector2i, v2::Vector2i) = Vector3d(v1.a - v2.a, v1.b - v2.b)
Base.:*(v::Vector2i, a::Number) = Vector3d(a*v.a, a*v.b)
Base.:*(a::Number, v::Vector2i) = v * a
Base.zero(::Type{Vector2i}) = Vector2i()

#---Vector4f
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
Base.zero(::Type{Vector4f}) = Vector4f()

#---CovMatrix
_to_lower_tri(i,j) = i > j ? ((i-1)*i)÷2 + j : ((j-1)*j)÷2 + i
_show(io, m, T, N) = begin
    print(io, "$N×$N CovMatrix{$T}[")
    for i in 1:N
        for j in 1:i
            print(io, m[i,j])
            j < i && print(io, " ")
        end
        i < N && print(io, "; ")
    end
    print(io, "]")
end

#---CovMatrix2f
CovMatrix2f(a,b,c) = CovMatrix2f((a,b,c))   # 3 elements
Base.show(io::IO, m::CovMatrix2f) = _show(io, m, Float32, 2)
Base.zero(::Type{CovMatrix2f}) = CovMatrix2f()
Base.getindex(cov::CovMatrix2f, i::Int) = cov.values[i]
Base.getindex(cov::CovMatrix2f, i::Int, j::Int) = cov.values[_to_lower_tri(i,j)]
Base.setindex(cov::CovMatrix2f, v, i::Int) = CovMatrix2f(setindex(cov.values, v, i))
Base.setindex(cov::CovMatrix2f, v, i::Int, j::Int) = CovMatrix2f(setindex(cov.values, v, _to_lower_tri(i,j)))
Base.iterate(cov::CovMatrix2f, i=1) = i > 3 ? nothing : (cov[i], i+1)

#---CovMatrix3f
CovMatrix3f(a,b,c,d,e,f) = CovMatrix3f((a,b,c,d,e,f))   # 6 elements
Base.show(io::IO, m::CovMatrix3f) = _show(io, m, Float32, 3)
Base.zero(::Type{CovMatrix3f}) = CovMatrix3f()
Base.getindex(cov::CovMatrix3f, i::Int) = cov.values[i]
Base.getindex(cov::CovMatrix3f, i::Int, j::Int) = cov.values[_to_lower_tri(i,j)]
Base.setindex(cov::CovMatrix3f, v, i::Int) = CovMatrix3f(setindex(cov.values, v, i))
Base.setindex(cov::CovMatrix3f, v, i::Int, j::Int) = CovMatrix3f(setindex(cov.values, v, _to_lower_tri(i,j)))
Base.iterate(cov::CovMatrix3f, i=1) = i > 6 ? nothing : (cov[i], i+1)

#---CovMatrix4f
CovMatrix4f(a,b,c,d,e,f,g,h,i,j) = CovMatrix4f((a,b,c,d,e,f,g,h,i,j))   # 10 elements
Base.show(io::IO, m::CovMatrix4f) = _show(io, m, Float32, 4)
Base.zero(::Type{CovMatrix4f}) = CovMatrix4f()
Base.getindex(cov::CovMatrix4f, i::Int) = cov.values[i]
Base.getindex(cov::CovMatrix4f, i::Int, j::Int) = cov.values[_to_lower_tri(i,j)]
Base.setindex(cov::CovMatrix4f, v, i::Int) = CovMatrix4f(setindex(cov.values, v, i))
Base.setindex(cov::CovMatrix4f, v, i::Int, j::Int) = CovMatrix4f(setindex(cov.values, v, _to_lower_tri(i,j)))
Base.iterate(cov::CovMatrix4f, i=1) = i > 10 ? nothing : (cov[i], i+1)

#--------------------------------------------------------------------------------------------------
#---ObjectID{ED}-----------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
struct ObjectID{ED <: POD} <: POD
    index::Int32
    collectionID::UInt32    # in some cases (reading from files) the collection ID is -2
end
ObjectID(idx, collid) = ObjectID{POD}(idx,collid)
Base.zero(::Type{ObjectID{ED}}) where ED = ObjectID{ED}(-1,0)
Base.iszero(x::ObjectID{ED}) where ED = x.index < 0
Base.show(io::IO, x::ObjectID{ED}) where ED = print(io, "#$(iszero(x) ? 0 : x.index+1)")
Base.convert(::Type{Integer}, i::ObjectID{ED}) where ED = i.index+1
Base.convert(::Type{ED}, i::ObjectID{ED}) where ED = iszero(i) ? nothing : @inbounds EDCollection_objects(ED, i.collectionID)[i.index+1]
function Base.convert(::Type{ObjectID{EI}}, p::ED) where {EI, ED<:EI}
    iszero(p.index) && (p = register(p))
    ObjectID{EI}(p.index.index, p.index.collectionID)
end
Base.convert(::Type{ObjectID{ED}}, i::Integer) where ED = ObjectID{ED}(i,0)
Base.eltype(::Type{ObjectID{ED}}) where ED = ED
Base.to_index(oid::ObjectID) = oid.index+1
Base.checkindex(::Type{Bool}, inds::Base.OneTo{Int64}, i::ObjectID) = first(inds) <= i.index+1 <= last(inds)
Base.:-(i::ObjectID{ED}) where ED = ObjectID{ED}(-i.index)
function Base.getproperty(oid::ObjectID{ED}, sym::Symbol) where ED
    if sym == :object
        convert(ED, oid)
    else # fallback to getfield
        return getfield(oid, sym)
    end
end
Base.propertynames(oid::ObjectID) = tuple(fieldnames(ObjectID)...,:object)
function register(p::ED) where ED
    collid = collectionID(ED)
    store = EDCollection_objects(ED, collid)
    !iszero(p.index) && error("Registering an already registered MCParticle $p")
    last = lastindex(store)
    p = @set p.index = ObjectID{ED}(last, collid)
    push!(store, p)
    return p
end
function update(p::ED) where ED
    iszero(p.index) && (p = register(p))  # need to register if not done
    EDCollection_objects(ED)[p.index.index+1] = p
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
indices(r::Relation{ED,TD,N}) where {ED,TD,N} = [p.index+1 for p in EDCollection_relations(ED,N,r.collid)[r.first+1:r.last]]
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
        rel = EDCollection_relations(ED,N,r.collid)   # Normally, the relations have been read and should not fail
        oid = rel[r.first + i]
        if !hasEDCollection(oid.collectionID)
            @warn "Cannot iterate on this relation because the collection with ID $(hex(oid.collectionID)) has not been loaded!"
            return nothing
        else
            obj = convert(TD, oid)
            return (obj, i + 1)
        end
    end
end
Base.getindex(r::Relation{ED,TD,N}, i) where {ED,TD,N} = 0 < i <= (r.last - r.first) ? convert(TD, EDCollection_relations(ED,N,r.collid)[r.first + i]) : throw(BoundsError(r,i))
Base.size(r::Relation) = (r.last-r.first,)
Base.length(r::Relation) = r.last-r.first
Base.eltype(::Type{Relation{ED,TD,N}}) where {ED,TD,N} = TD
Base.zero(::Type{Relation{ED,TD,N}}) where {ED,TD,N} = Relation{ED,TD,N}(0,0,0)
function relations(::Type{ED}) where ED
    (ft for ft in fieldtypes(ED) if ft <: Relation)
end
function vmembers(::Type{ED}) where ED
    (ft for ft in fieldtypes(ED) if ft <: PVector)
end

function push(r::Relation{ED,TD,N}, p) where {ED,TD,N}
    (;first, last, collid) = r
    relations = EDCollection_relations(ED, N, collid)
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
    relations = EDCollection_relations(ED, N, collid)
    relations[last] = zero(ObjectID{TD})
    return Relation{ED,TD,N}(first, last-1, collid)
end

#--------------------------------------------------------------------------------------------------
#---PVector{ED,N} for implementation of VectorMembers--------------[POD Vector]--------------------
#--------------------------------------------------------------------------------------------------
struct PVector{ED<:POD,T, N} <: AbstractVector{T}
    first::UInt32    # first index (starts with 0)
    last::UInt32     # last index (starts with 0)
    collid::UInt32   # Collection ID of the data object (when is read) or 0 if newly created
    PVector{ED,T,N}(first=0, last=0, collid=0) where {ED,T,N} = new(first, last, collid)
end
values(v::PVector{ED,T,N}) where {ED,T,N} = EDCollection_pvectors(ED,N,v.collid)[v.first+1:v.last]
Base.show(io::IO, v::PVector{ED}) where ED = show(io, values(v))

function Base.iterate(v::PVector{ED,T, N}, i=1) where {ED,T,N}
    if i > (v.last-v.first)
        return nothing
    else
        val = EDCollection_pvectors(ED,N,v.collid)   # Normally, the pvectors have been read and should not fail
        obj = val[v.first + i]
        return (obj, i + 1)
    end
end
Base.getindex(v::PVector{ED,T, N}, i) where {ED,T, N} = 0 < i <= (v.last - v.first) ? EDCollection_pvectors(ED,N,v.collid)[v.first + i] : throw(BoundsError(v,i))
Base.size(v::PVector{ED,T,N}) where {ED,T,N} = (v.last-v.first,)
Base.length(v::PVector{ED,T,N}) where {ED,T,N} = v.last-v.first
Base.eltype(::Type{PVector{ED,T,N}}) where {ED,T,N} = T
function Base.convert(::Type{PVector{ED,T,N}}, v::AbstractVector{T}) where {ED,T,N}
    pvectors = EDCollection_pvectors(ED,N)
    tail = lastindex(pvectors)
    len  = length(v)
    append!(pvectors, v)
    PVector{ED,T,N}(tail, tail + len)
end

#--------------------------------------------------------------------------------------------------
#---Link{FROM, TO} for implementation of Links-----------------------------------------------------
#--------------------------------------------------------------------------------------------------
struct Link{FROM<:POD,TO<:POD} <: POD
    index::ObjectID{Link{FROM,TO}}   # ObjectID of himself
    #---Data Members
    weight::Float32                  #  weight of this link 
    #---OneToOneRelations
    from_idx::ObjectID{FROM}  #  reference to the reconstructed hit 
    to_idx::ObjectID{TO}      #  reference to the Monte-Carlo particle 
end
Base.show(io::IO, l::Link{FROM,TO}) where {FROM,TO} = print(io, "Link{$FROM,$TO}(weight=$(l.weight), from=$(l.from_idx), to=$(l.to_idx))")
function Link{FROM,TO}(;weight=0, from=-1, to=-1) where {FROM,TO}
    Link{FROM,TO}(-1, weight, from, to)
end
function Base.getproperty(obj::Link{FROM,TO}, sym::Symbol) where {FROM,TO}
    if sym == :from
        idx = getfield(obj, :from_idx)
        return iszero(idx) ? nothing : convert(FROM, idx)
    elseif sym == :to
        idx = getfield(obj, :to_idx)
        return iszero(idx) ? nothing : convert(TO, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
