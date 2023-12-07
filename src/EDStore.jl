export EDStore, getEDStore, initEDStore

mutable struct EDStore{ED <: POD}
    objects::AbstractVector{ED}
    relations::AbstractVector{Index{ED}}
    EDStore{ED}() where ED = new()
end

function initialize(store::EDStore{ED}) where ED <: POD
    store.objects = ED[]
    store.relations = Index{ED}[]
end

const _eventDataStore = Dict( MCParticle => EDStore{MCParticle}(),
                              SimTrackerHit => EDStore{SimTrackerHit}(),
                            )

function initEDStore(::Type{ED}) where ED
    global _eventDataStore
    _eventDataStore[ED] |> initialize
end
function getEDStore(::Type{ED}) where ED
    _eventDataStore[ED]
end

function EDStore_objects(::Type{ED}) where ED
    global _eventDataStore
    _eventDataStore[ED].objects
end
function EDStore_relations(::Type{ED}) where ED
    global _eventDataStore
    _eventDataStore[ED].relations
end
