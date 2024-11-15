using StructArrays

export EDCollection, EDStore, EDCollection_objects, EDCollection_relations, EDCollection_pvectors, getEDCollection, hasEDCollection, initEDCollection, emptyEDStore

"""
    EDCollection{ED} where ED <: POD
"""
struct EDCollection{ED <: POD}
    objects::StructArray{ED}
    relations::Tuple    # a Tuple of ObjectID{ED} [Abstract] Vectors
    vmembers::Tuple     # a Tuple of T [Abstract] Vectors
    EDCollection{ED}() where ED = new(StructArray(ED[]), 
                                      Tuple(ObjectID{eltype(R)}[] for R in relations(ED)), 
                                      Tuple(eltype(R)[] for R in vmembers(ED)))
    EDCollection{ED}(objects::StructArray{ED}, relations::Tuple, vmembers::Tuple) where ED = new(objects, relations, vmembers)
end
Base.iterate(coll::EDCollection) = iterate(coll.objects)
Base.iterate(coll::EDCollection, state) = iterate(coll.objects, state)
Base.getindex(coll::EDCollection, i::Int) = coll.objects[i]
Base.length(coll::EDCollection) = length(coll.objects)
Base.lastindex(coll::EDCollection) = lastindex(coll.objects)
function Base.push!(coll::EDCollection, obj)
    !iszero(obj.index) && error("Already registered object $obj")
    last = length(coll.objects)
    obj = @set obj.index=last
    push!(coll.objects, obj)
end
function Base.getproperty(coll::EDCollection, name::Symbol)
    if name == :objects
        return getfield(coll, :objects)
    elseif name == :relations
        return getfield(coll, :relations)
    elseif name == :vmembers
        return getfield(coll, :vmembers)
    else
        getproperty(coll.objects, name)
    end
end
EDCollection(sa::StructArray{ED}, r::Tuple, v::Tuple) where ED = EDCollection{ED}(sa, r, v)


function Base.empty!(store::EDCollection{ED}) where ED <: POD
    empty!(store.objects)
    for (i,R) in enumerate(relations(ED))
        store.relations[i] isa Vector &&  empty!(store.relations[i])
    end
    for (i,R) in enumerate(vmembers(ED))
        store.vmembers[i] isa Vector &&  empty!(store.vmembers[i])
    end
    store
end

#--- Global Event Data Store-----------------------------------------------------------------------
const _eventDataStore = Dict{UInt32, EDCollection}()
EDStore() = _eventDataStore

"""
    getEDCollection(::Type{ED}, collid::UInt32=0x00000000)

Get the store corresponding to the `collid`. If it is not specified then obtain a `collid` from the data type `ED`.
"""
function getEDCollection(::Type{ED}, collid::UInt32=0x00000000) where ED
    collid == 0 && (collid = collectionID(ED))
    haskey(EDStore(), collid) && return EDStore()[collid]
    EDStore()[collid] = EDCollection{ED}()
end

"""
    hasEDCollection(collid::UInt32)

Find out if the store with `collid` is there.
"""
function hasEDCollection(collid::UInt32)
    collid == 0 || haskey(EDStore(), collid)
end

"""
    initEDCollection(::Type{ED}) where ED
Initialize the store corresponding to type `ED`.
"""
function initEDCollection(::Type{ED}) where ED
    getEDCollection(ED) |> empty!
end

"""
    emptyEDStore()
Empty the whole store.
"""
function emptyEDStore()
    for coll in Base.values(EDStore())
        coll |> empty!
    end
end

function EDCollection_objects(::Type{ED}, collid::UInt32=0x00000000) where ED
    store = getEDCollection(ED, collid)
    store.objects
end

function EDCollection_relations(::Type{ED}, N::Int, collid::UInt32=0x00000000) where ED
    store = getEDCollection(ED, collid)
    store.relations[N]
end

function EDCollection_pvectors(::Type{ED}, N::Int, collid::UInt32=0x00000000) where ED
    store = getEDCollection(ED, collid)
    store.vmembers[N]
end

