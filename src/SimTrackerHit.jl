"""
    edm4hep::SimTrackerHit
    Description: "Simulated tracker hit"
    Author: "F.Gaede, DESY"
"""
struct SimTrackerHit <: POD
    index::Index{SimTrackerHit}
    # Members:
    cellID::UInt64                  # ID of the sensor that created this hit
    EDep::Float32                   # energy deposited in the hit [GeV].
    time::Float32                   # proper time of the hit in the lab frame in [ns].
    pathLength::Float32             # path length of the particle in the sensitive material that resulted in this hit.
    quality::Int32                  # quality bit flag.
    position::Vector3d              # the hit position in [mm].
    momentum::Vector3f              # the 3-momentum of the particle at the hits position in [GeV]
    # OneToOneRelations:
    mcparticleidx::Index{MCParticle}   # MCParticle that caused the hit.
end

function SimTrackerHit(;cellID=0, EDep=0, time=0, pathLength=0, quality=0, position=Vector3d(), momentum=Vector3f(), mcparticle=0)
    SimTrackerHit(0, cellID, EDep, time, pathLength, quality, position, momentum, mcparticle)
end

#---Event Data Store (defining the containers for objects and relations)-----------------------


#---Utility functions for SimTrackerHit----------------------------------------------------------
function Base.getproperty(obj::SimTrackerHit, sym::Symbol)
    if sym == :mcparticle
        idx = getfield(obj, :mcparticleidx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end

#---Exports for SimTrackerHit--------------------------------------------------------------------
export SimTrackerHit

