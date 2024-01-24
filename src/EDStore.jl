export EDStore, getEDStore, initEDStore, assignEDStore, emptyEDStore

mutable struct EDStore{ED <: POD}
    objects::AbstractVector{ED}
    relations::Tuple    # a Tuple of ObjectID{ED} [Abstrcat] Vectors
    EDStore{ED}() where ED = new()
end

function initialize!(store::EDStore{ED}) where ED <: POD
    store.objects = ED[]
    store.relations = Tuple(ObjectID{eltype(R)}[] for R in relations(ED))
end

function Base.empty!(store::EDStore{ED}) where ED <: POD
    store.objects isa Vector && empty!(store.objects)
    for (i,R) in enumerate(relations(ED))
        store.relations[i] isa Vector &&  empty!(store.relations[i])
    end
    store
end

#--- Global Event Data Store-----------------------------------------------------------------------
const _eventDataStore = Dict{UInt32, EDStore}()

function getEDStore(::Type{ED}, collid::UInt32=0x00000000) where ED
    global _eventDataStore
    if collid == 0
        collid = collectionID(ED)
    end
    haskey(_eventDataStore, collid) && return _eventDataStore[collid]
    _eventDataStore[collid] = EDStore{ED}()
end

function hasEDStore(collid::UInt32)
    global _eventDataStore
    collid == 0 || haskey(_eventDataStore, collid)
end

function initEDStore(::Type{ED}) where ED
    getEDStore(ED) |> initialize!
end

function emptyEDStore()
    global _eventDataStore
    for container in values(_eventDataStore)
        container |> empty!
    end
end

function assignEDStore(container::AbstractArray{ED}, collid::UInt32) where ED
    getEDStore(ED, collid).objects = container
end
function assignEDStore(relations::Tuple, ::Type{ED}, collid::UInt32) where ED
    getEDStore(ED, collid).relations = relations
end

function EDStore_objects(::Type{ED}, collid::UInt32=0x00000000) where ED
    store = getEDStore(ED, collid)
    if !isdefined(store, :objects)
        store.objects = ED[]
    end
    store.objects
end

function EDStore_relations(::Type{ED}, N::Int, collid::UInt32=0x00000000) where ED
    store = getEDStore(ED, collid)
    if !isdefined(store, :relations)
        store.relations = Tuple(ObjectID{eltype(R)}[] for R in relations(ED))
    end
    store.relations[N]
end
