using Accessors
export Index, Relation, Vector3d, Vector3f, Vector2i, register

"""
    Vector3D with doubles
"""
struct Vector3d
    x::Float64
    y::Float64
    z::Float64
    Vector3d(x=0,y=0,z=0) = new(x,y,z)
end
Base.convert(::Type{Vector3d}, t::Tuple) = Vector3d(t...)
Base.show(io::IO, v::Vector3d) = print(io, "($(v.x),$(v.y),$(v.z))")
"""
    Vector3D with floats
"""
struct Vector3f
    x::Float32
    y::Float32
    z::Float32
    Vector3f(x=0,y=0,z=0) = new(x,y,z)
end
Base.convert(::Type{Vector3f}, t::Tuple) = Vector3f(t...)
Base.show(io::IO, v::Vector3f) = print(io, "($(v.x),$(v.y),$(v.z))")
"""
    Vector2D with Int32
"""
struct Vector2i
    a::Int32
    b::Int32
    Vector2i(a=0,b=0) = new(a,b)
end
Base.convert(::Type{Vector2i}, t::Tuple) = Vector2i(t...)
Base.show(io::IO, v::Vector2i) = print(io, "($(v.a),$(v.b))")

#---Index{ED}----------------------------------------------------------------------------------
abstract type POD end

struct Index{ED <: POD} <: Integer
    idx::Int64
end
Base.zero(::Type{Index{ED}}) where ED = Index{ED}(0)
Base.iszero(x::Index{ED}) where ED = x.idx == 0
Base.show(io::IO, x::Index{ED}) where ED = print(io, "#$(x.idx)")
Base.convert(::Type{Integer}, i::Index{ED}) where ED = i.idx
Base.convert(::Type{ED}, i::Index{ED}) where ED = iszero(i.idx) ? nothing : @inbounds EDStore_objects(i)[i.idx]
Base.convert(::Type{Index{ED}}, p::ED) where ED = iszero(p.index) ? register(p).index : return p.index
Base.:-(i::Index{ED}) where ED = Index{ED}(-i.idx)
function register(p::ED) where ED
    !iszero(p.index) && error("Registering an already registered MCParticle $p")
    last = lastindex(EDStore_objects(p))
    p = @set p.index = Index{ED}(last + 1)
    push!(EDStore_objects(p), p)
    return p
end
function update(p::ED) where ED
    EDStore_objects(p)[p.index.idx] = p
end

#---Relation{ED} for implementation of OneToManyRelation---------------------------------------
struct Relation{ED <: POD}
    first::Int64    # first index
    last::Int64     # last index
    Relation{ED}(first=1, last=1) where ED = new(first, last)
end
indexes(r::Relation{ED}) where ED = [p.idx for p in EDStore_relations(r)[r.first:r.last-1]]
function Base.show(io::IO, r::Relation{ED}) where ED
    idxs = indexes(r)
    print(io, isempty(idxs) ? "$ED#[]" : "$ED#$idxs")
end
Base.iterate(r::Relation{ED}, i=1) where ED = i > (r.last-r.first) ? nothing : (convert(ED, EDStore_relations(r)[r.first + i - 1]), i + 1)
Base.getindex(r::Relation{ED}, i) where ED = 0 < i <= (r.last - r.first) ? convert(ED, EDStore_relations(r)[r.first + i - 1]) : throw(BoundsError(r,i))
Base.size(r::Relation{ED}) where ED = (r.last-r.first,)
Base.length(r::Relation{ED}) where ED = r.last-r.first
Base.eltype(::Type{Relation{ED}}) where ED = ED

const InitAlloc = 8
function push(r::Relation{ED}, p::ED) where ED
    (;first, last) = r
    length = last-first
    tail = lastindex(EDStore_relations(r))
    append!(EDStore_relations(r), zeros(Index{ED}, length+1))      # add extended indices at the end
    EDStore_relations(r)[tail + 1:tail + length] = EDStore_relations(r)[first:last-1]  # copy indices
    EDStore_relations(r)[first:last-1] .= 0                        # reset unused indices
    first = tail + 1
    last  = first + length + 1
    EDStore_relations(r)[last-1] = p
    Relation{ED}(first, last)
end
