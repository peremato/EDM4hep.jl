export EDStore, getEDStore, initEDStore, assignEDStore, emptyEDStore

mutable struct EDStore{ED <: POD}
    objects::AbstractVector{ED}
    relations::Tuple    # a Tuple of ObjectID{ED} [Abstrcat] Vectors
    EDStore{ED}() where ED = new()
end

function initialize!(store::EDStore{ED}) where ED <: POD
    store.objects = ED[]
    store.relations = Tuple(ObjectID{ED}[] for i in 1:relations(ED))
end

function Base.empty!(store::EDStore{ED}) where ED <: POD
    store.objects isa Vector && empty!(store.objects)
    for i in 1:relations(ED)
        store.relations[i] isa Vector &&  empty!(store.relations[i])
    end
    store
end

#--- Global Event Data Store-----------------------------------------------------------------------
const _eventDataStore = Dict{DataType, EDStore}()
#                            Dict( MCParticle => EDStore{MCParticle}(),
#                              SimTrackerHit => EDStore{SimTrackerHit}(),
#                            )

function getEDStore(::Type{ED}) where ED
    global _eventDataStore
    haskey(_eventDataStore, ED) && return _eventDataStore[ED]
    _eventDataStore[ED] = EDStore{ED}()
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

function assignEDStore(container::AbstractArray{ED}) where ED
    getEDStore(ED).objects = container
end
function assignEDStore(relations::Tuple, ::Type{ED}) where ED
    getEDStore(ED).relations = relations
end

function EDStore_objects(::Type{ED}) where ED
    store = getEDStore(ED)
    if !isdefined(store, :objects)
        store.objects = ED[]
    end
    store.objects
end

function EDStore_relations(::Type{ED}, N::Int) where ED
    store = getEDStore(ED)
    if !isdefined(store, :relations)
        store.relations = Tuple(ObjectID{ED}[] for i in 1:relations(ED))
    end
    store.relations[N]
end
