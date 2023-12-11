export EDStore, getEDStore, initEDStore, assignEDStore, emptyEDStore

mutable struct EDStore{ED <: POD}
    objects::AbstractVector{ED}
    relations::AbstractVector{ObjectID{ED}}
    EDStore{ED}() where ED = new()
end

function initialize!(store::EDStore{ED}) where ED <: POD
    store.objects = ED[]
    store.relations = ObjectID{ED}[]
    store
end
function Base.empty!(store::EDStore{ED}) where ED <: POD
    store.objects isa Vector && empty!(store.objects)
    store.relations isa Vector &&  empty!(store.relations)
    store
end

#--- Global Event Data Store-----------------------------------------------------------------------
const _eventDataStore = Dict( MCParticle => EDStore{MCParticle}(),
                              SimTrackerHit => EDStore{SimTrackerHit}(),
                            )

function initEDStore(::Type{ED}) where ED
    global _eventDataStore
    !haskey(_eventDataStore, ED) && (_eventDataStore[ED] = EDStore{ED}())
    _eventDataStore[ED] |> initialize!
end

function emptyEDStore()
    global _eventDataStore
    for container in values(_eventDataStore)
        container |> empty!
    end
end

function getEDStore(::Type{ED}) where ED
    _eventDataStore[ED]
end

function assignEDStore(container::AbstractArray{ED}) where ED
    _eventDataStore[ED].objects = container
end

function EDStore_objects(::Type{ED}) where ED
    global _eventDataStore
    _eventDataStore[ED].objects
end

function EDStore_relations(::Type{ED}) where ED
    global _eventDataStore
    _eventDataStore[ED].relations
end
