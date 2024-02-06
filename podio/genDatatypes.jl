"""
ParticleID
- Author: F.Gaede, DESY
# Fields
- `type::Int32`: userdefined type
- `PDG::Int32`: PDG code of this id - ( 999999 ) if unknown.
- `algorithmType::Int32`: type of the algorithm/module that created this hypothesis
- `likelihood::Float32`: likelihood of this hypothesis - in a user defined normalization.
- `parameters::PVector{Float32}`: parameters associated with this hypothesis. Check/set collection parameters ParameterNames_PIDAlgorithmTypeName for decoding the indices.
"""
struct ParticleID <: POD
    index::ObjectID{ParticleID}      # ObjectID of himself
    #---Data Members
    type::Int32                      # userdefined type
    PDG::Int32                       # PDG code of this id - ( 999999 ) if unknown.
    algorithmType::Int32             # type of the algorithm/module that created this hypothesis
    likelihood::Float32              # likelihood of this hypothesis - in a user defined normalization.
    #---VectorMembers
    parameters::PVector{ParticleID,Float32,1}  # parameters associated with this hypothesis. Check/set collection parameters ParameterNames_PIDAlgorithmTypeName for decoding the indices.
end

function ParticleID(;type=0, PDG=0, algorithmType=0, likelihood=0, parameters=PVector{ParticleID,Float32,1}())
    ParticleID(-1, type, PDG, algorithmType, likelihood, parameters)
end

"    setParameters(object::ParticleID, v::AbstractVector{Float32})"
function setParameters(o::ParticleID, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.parameters = v
    update(o)
end
"""
Calibrated Detector Data
- Author: Wenxing Fang, IHEP
# Fields
- `cellID::UInt64`: cell id.
- `time::Float32`: begin time [ns].
- `interval::Float32`: interval of each sampling [ns].
- `amplitude::PVector{Float32}`: calibrated detector data.
"""
struct TimeSeries <: POD
    index::ObjectID{TimeSeries}      # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # cell id.
    time::Float32                    # begin time [ns].
    interval::Float32                # interval of each sampling [ns].
    #---VectorMembers
    amplitude::PVector{TimeSeries,Float32,1}  # calibrated detector data.
end

function TimeSeries(;cellID=0, time=0, interval=0, amplitude=PVector{TimeSeries,Float32,1}())
    TimeSeries(-1, cellID, time, interval, amplitude)
end

"    setAmplitude(object::TimeSeries, v::AbstractVector{Float32})"
function setAmplitude(o::TimeSeries, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.amplitude = v
    update(o)
end
"""
Calorimeter hit
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: detector specific (geometrical) cell id.
- `energy::Float32`: energy of the hit in [GeV].
- `energyError::Float32`: error of the hit energy in [GeV].
- `time::Float32`: time of the hit in [ns].
- `position::Vector3f`: position of the hit in world coordinates in [mm].
- `type::Int32`: type of hit. Mapping of integer types to names via collection parameters "CalorimeterHitTypeNames" and "CalorimeterHitTypeValues".
"""
struct CalorimeterHit <: POD
    index::ObjectID{CalorimeterHit}  # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # detector specific (geometrical) cell id.
    energy::Float32                  # energy of the hit in [GeV].
    energyError::Float32             # error of the hit energy in [GeV].
    time::Float32                    # time of the hit in [ns].
    position::Vector3f               # position of the hit in world coordinates in [mm].
    type::Int32                      # type of hit. Mapping of integer types to names via collection parameters "CalorimeterHitTypeNames" and "CalorimeterHitTypeValues".
end

function CalorimeterHit(;cellID=0, energy=0, energyError=0, time=0, position=Vector3f(), type=0)
    CalorimeterHit(-1, cellID, energy, energyError, time, position, type)
end

"""
Calorimeter Hit Cluster
- Author: F.Gaede, DESY
# Fields
- `type::Int32`: flagword that defines the type of cluster. Bits 16-31 are used internally.
- `energy::Float32`: energy of the cluster [GeV]
- `energyError::Float32`: error on the energy
- `position::Vector3f`: position of the cluster [mm]
- `positionError::SVector{6,Float32}`: covariance matrix of the position (6 Parameters)
- `iTheta::Float32`: intrinsic direction of cluster at position  Theta. Not to be confused with direction cluster is seen from IP.
- `phi::Float32`: intrinsic direction of cluster at position - Phi. Not to be confused with direction cluster is seen from IP.
- `directionError::Vector3f`: covariance matrix of the direction (3 Parameters) [mm^2]
- `shapeParameters::PVector{Float32}`: shape parameters - check/set collection parameter ClusterShapeParameters for size and names of parameters.
- `subdetectorEnergies::PVector{Float32}`: energy observed in a particular subdetector. Check/set collection parameter ClusterSubdetectorNames for decoding the indices of the array.
# Relations
- `clusters::Cluster`: clusters that have been combined to this cluster.
- `hits::CalorimeterHit`: hits that have been combined to this cluster.
- `particleIDs::ParticleID`: particle IDs (sorted by their likelihood)
"""
struct Cluster <: POD
    index::ObjectID{Cluster}         # ObjectID of himself
    #---Data Members
    type::Int32                      # flagword that defines the type of cluster. Bits 16-31 are used internally.
    energy::Float32                  # energy of the cluster [GeV]
    energyError::Float32             # error on the energy
    position::Vector3f               # position of the cluster [mm]
    positionError::SVector{6,Float32}  # covariance matrix of the position (6 Parameters)
    iTheta::Float32                  # intrinsic direction of cluster at position  Theta. Not to be confused with direction cluster is seen from IP.
    phi::Float32                     # intrinsic direction of cluster at position - Phi. Not to be confused with direction cluster is seen from IP.
    directionError::Vector3f         # covariance matrix of the direction (3 Parameters) [mm^2]
    #---VectorMembers
    shapeParameters::PVector{Cluster,Float32,1}  # shape parameters - check/set collection parameter ClusterShapeParameters for size and names of parameters.
    subdetectorEnergies::PVector{Cluster,Float32,2}  # energy observed in a particular subdetector. Check/set collection parameter ClusterSubdetectorNames for decoding the indices of the array.
    #---OneToManyRelations
    clusters::Relation{Cluster,Cluster,1}  # clusters that have been combined to this cluster.
    hits::Relation{Cluster,CalorimeterHit,2}  # hits that have been combined to this cluster.
    particleIDs::Relation{Cluster,ParticleID,3}  # particle IDs (sorted by their likelihood)
end

function Cluster(;type=0, energy=0, energyError=0, position=Vector3f(), positionError=zero(SVector{6,Float32}), iTheta=0, phi=0, directionError=Vector3f(), shapeParameters=PVector{Cluster,Float32,1}(), subdetectorEnergies=PVector{Cluster,Float32,2}(), clusters=Relation{Cluster,Cluster,1}(), hits=Relation{Cluster,CalorimeterHit,2}(), particleIDs=Relation{Cluster,ParticleID,3}())
    Cluster(-1, type, energy, energyError, position, positionError, iTheta, phi, directionError, shapeParameters, subdetectorEnergies, clusters, hits, particleIDs)
end

"    pushToClusters(object::Cluster, refobj::Cluster)"
function pushToClusters(c::Cluster, o::Cluster)
    iszero(c.index) && (c = register(c))
    c = @set c.clusters = push(c.clusters, o)
    update(c)
end
"    popFromClusters(object::Cluster)"
function popFromClusters(c::Cluster)
    iszero(c.index) && (c = register(c))
    c = @set c.clusters = pop(c.clusters)
    update(c)
end
"    pushToHits(object::Cluster, refobj::CalorimeterHit)"
function pushToHits(c::Cluster, o::CalorimeterHit)
    iszero(c.index) && (c = register(c))
    c = @set c.hits = push(c.hits, o)
    update(c)
end
"    popFromHits(object::Cluster)"
function popFromHits(c::Cluster)
    iszero(c.index) && (c = register(c))
    c = @set c.hits = pop(c.hits)
    update(c)
end
"    pushToParticleIDs(object::Cluster, refobj::ParticleID)"
function pushToParticleIDs(c::Cluster, o::ParticleID)
    iszero(c.index) && (c = register(c))
    c = @set c.particleIDs = push(c.particleIDs, o)
    update(c)
end
"    popFromParticleIDs(object::Cluster)"
function popFromParticleIDs(c::Cluster)
    iszero(c.index) && (c = register(c))
    c = @set c.particleIDs = pop(c.particleIDs)
    update(c)
end
"    setShapeParameters(object::Cluster, v::AbstractVector{Float32})"
function setShapeParameters(o::Cluster, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.shapeParameters = v
    update(o)
end
"    setSubdetectorEnergies(object::Cluster, v::AbstractVector{Float32})"
function setSubdetectorEnergies(o::Cluster, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.subdetectorEnergies = v
    update(o)
end
"""
The Monte Carlo particle - based on the lcio::MCParticle.
- Author: F.Gaede, DESY
# Fields
- `PDG::Int32`: PDG code of the particle
- `generatorStatus::Int32`: status of the particle as defined by the generator
- `simulatorStatus::Int32`: status of the particle from the simulation program - use BIT constants below
- `charge::Float32`: particle charge
- `time::Float32`: creation time of the particle in [ns] wrt. the event, e.g. for preassigned decays or decays in flight from the simulator.
- `mass::Float64`: mass of the particle in [GeV]
- `vertex::Vector3d`: production vertex of the particle in [mm].
- `endpoint::Vector3d`: endpoint of the particle in [mm]
- `momentum::Vector3d`: particle 3-momentum at the production vertex in [GeV]
- `momentumAtEndpoint::Vector3d`: particle 3-momentum at the endpoint in [GeV]
- `spin::Vector3f`: spin (helicity) vector of the particle.
- `colorFlow::Vector2i`: color flow as defined by the generator
# Relations
- `parents::MCParticle`: The parents of this particle.
- `daughters::MCParticle`: The daughters this particle.
"""
struct MCParticle <: POD
    index::ObjectID{MCParticle}      # ObjectID of himself
    #---Data Members
    PDG::Int32                       # PDG code of the particle
    generatorStatus::Int32           # status of the particle as defined by the generator
    simulatorStatus::Int32           # status of the particle from the simulation program - use BIT constants below
    charge::Float32                  # particle charge
    time::Float32                    # creation time of the particle in [ns] wrt. the event, e.g. for preassigned decays or decays in flight from the simulator.
    mass::Float64                    # mass of the particle in [GeV]
    vertex::Vector3d                 # production vertex of the particle in [mm].
    endpoint::Vector3d               # endpoint of the particle in [mm]
    momentum::Vector3d               # particle 3-momentum at the production vertex in [GeV]
    momentumAtEndpoint::Vector3d     # particle 3-momentum at the endpoint in [GeV]
    spin::Vector3f                   # spin (helicity) vector of the particle.
    colorFlow::Vector2i              # color flow as defined by the generator
    #---OneToManyRelations
    parents::Relation{MCParticle,MCParticle,1}  # The parents of this particle.
    daughters::Relation{MCParticle,MCParticle,2}  # The daughters this particle.
end

function MCParticle(;PDG=0, generatorStatus=0, simulatorStatus=0, charge=0, time=0, mass=0, vertex=Vector3d(), endpoint=Vector3d(), momentum=Vector3d(), momentumAtEndpoint=Vector3d(), spin=Vector3f(), colorFlow=Vector2i(), parents=Relation{MCParticle,MCParticle,1}(), daughters=Relation{MCParticle,MCParticle,2}())
    MCParticle(-1, PDG, generatorStatus, simulatorStatus, charge, time, mass, vertex, endpoint, momentum, momentumAtEndpoint, spin, colorFlow, parents, daughters)
end

"    pushToParents(object::MCParticle, refobj::MCParticle)"
function pushToParents(c::MCParticle, o::MCParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.parents = push(c.parents, o)
    update(c)
end
"    popFromParents(object::MCParticle)"
function popFromParents(c::MCParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.parents = pop(c.parents)
    update(c)
end
"    pushToDaughters(object::MCParticle, refobj::MCParticle)"
function pushToDaughters(c::MCParticle, o::MCParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.daughters = push(c.daughters, o)
    update(c)
end
"    popFromDaughters(object::MCParticle)"
function popFromDaughters(c::MCParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.daughters = pop(c.daughters)
    update(c)
end
"""
Simulated Primary Ionization
- Author: Wenxing Fang, IHEP
# Fields
- `cellID::UInt64`: cell id.
- `time::Float32`: the primary ionization's time in the lab frame [ns].
- `position::Vector3d`: the primary ionization's position [mm].
- `type::Int16`: type.
- `electronCellID::PVector{UInt64}`: cell id.
- `electronTime::PVector{Float32}`: the time in the lab frame [ns].
- `electronPosition::PVector{Vector3d}`: the position in the lab frame [mm].
- `pulseTime::PVector{Float32}`: the pulse's time in the lab frame [ns].
- `pulseAmplitude::PVector{Float32}`: the pulse's amplitude [fC].
# Relations
- `mcparticle::MCParticle`: the particle that caused the ionizing collisions.
"""
struct SimPrimaryIonizationCluster <: POD
    index::ObjectID{SimPrimaryIonizationCluster}  # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # cell id.
    time::Float32                    # the primary ionization's time in the lab frame [ns].
    position::Vector3d               # the primary ionization's position [mm].
    type::Int16                      # type.
    #---VectorMembers
    electronCellID::PVector{SimPrimaryIonizationCluster,UInt64,1}  # cell id.
    electronTime::PVector{SimPrimaryIonizationCluster,Float32,2}  # the time in the lab frame [ns].
    electronPosition::PVector{SimPrimaryIonizationCluster,Vector3d,3}  # the position in the lab frame [mm].
    pulseTime::PVector{SimPrimaryIonizationCluster,Float32,4}  # the pulse's time in the lab frame [ns].
    pulseAmplitude::PVector{SimPrimaryIonizationCluster,Float32,5}  # the pulse's amplitude [fC].
    #---OneToOneRelations
    mcparticle_idx::ObjectID{MCParticle}  # the particle that caused the ionizing collisions.
end

function SimPrimaryIonizationCluster(;cellID=0, time=0, position=Vector3d(), type=0, electronCellID=PVector{SimPrimaryIonizationCluster,UInt64,1}(), electronTime=PVector{SimPrimaryIonizationCluster,Float32,2}(), electronPosition=PVector{SimPrimaryIonizationCluster,Vector3d,3}(), pulseTime=PVector{SimPrimaryIonizationCluster,Float32,4}(), pulseAmplitude=PVector{SimPrimaryIonizationCluster,Float32,5}(), mcparticle=-1)
    SimPrimaryIonizationCluster(-1, cellID, time, position, type, electronCellID, electronTime, electronPosition, pulseTime, pulseAmplitude, mcparticle)
end

function Base.getproperty(obj::SimPrimaryIonizationCluster, sym::Symbol)
    if sym == :mcparticle
        idx = getfield(obj, :mcparticle_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"    setElectronCellID(object::SimPrimaryIonizationCluster, v::AbstractVector{UInt64})"
function setElectronCellID(o::SimPrimaryIonizationCluster, v::AbstractVector{UInt64})
    iszero(o.index) && (o = register(o))
    o = @set o.electronCellID = v
    update(o)
end
"    setElectronTime(object::SimPrimaryIonizationCluster, v::AbstractVector{Float32})"
function setElectronTime(o::SimPrimaryIonizationCluster, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.electronTime = v
    update(o)
end
"    setElectronPosition(object::SimPrimaryIonizationCluster, v::AbstractVector{Vector3d})"
function setElectronPosition(o::SimPrimaryIonizationCluster, v::AbstractVector{Vector3d})
    iszero(o.index) && (o = register(o))
    o = @set o.electronPosition = v
    update(o)
end
"    setPulseTime(object::SimPrimaryIonizationCluster, v::AbstractVector{Float32})"
function setPulseTime(o::SimPrimaryIonizationCluster, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.pulseTime = v
    update(o)
end
"    setPulseAmplitude(object::SimPrimaryIonizationCluster, v::AbstractVector{Float32})"
function setPulseAmplitude(o::SimPrimaryIonizationCluster, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.pulseAmplitude = v
    update(o)
end
"""
Association between a Cluster and a MCParticle
- Author: Placido Fernandez Declara
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::Cluster`: reference to the cluster
- `sim::MCParticle`: reference to the Monte-Carlo particle
"""
struct MCRecoClusterParticleAssociation <: POD
    index::ObjectID{MCRecoClusterParticleAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{Cluster}       # reference to the cluster
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

function MCRecoClusterParticleAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoClusterParticleAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoClusterParticleAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(Cluster, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Association between a CalorimeterHit and a MCParticle
- Author: Placido Fernandez Declara
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::CalorimeterHit`: reference to the reconstructed hit
- `sim::MCParticle`: reference to the Monte-Carlo particle
"""
struct MCRecoCaloParticleAssociation <: POD
    index::ObjectID{MCRecoCaloParticleAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{CalorimeterHit}  # reference to the reconstructed hit
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

function MCRecoCaloParticleAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoCaloParticleAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoCaloParticleAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(CalorimeterHit, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Monte Carlo contribution to SimCalorimeterHit
- Author: F.Gaede, DESY
# Fields
- `PDG::Int32`: PDG code of the shower particle that caused this contribution.
- `energy::Float32`: energy in [GeV] of the this contribution
- `time::Float32`: time in [ns] of this contribution
- `stepPosition::Vector3f`: position of this energy deposition (step) [mm]
# Relations
- `particle::MCParticle`: primary MCParticle that caused the shower responsible for this contribution to the hit.
"""
struct CaloHitContribution <: POD
    index::ObjectID{CaloHitContribution}  # ObjectID of himself
    #---Data Members
    PDG::Int32                       # PDG code of the shower particle that caused this contribution.
    energy::Float32                  # energy in [GeV] of the this contribution
    time::Float32                    # time in [ns] of this contribution
    stepPosition::Vector3f           # position of this energy deposition (step) [mm]
    #---OneToOneRelations
    particle_idx::ObjectID{MCParticle}  # primary MCParticle that caused the shower responsible for this contribution to the hit.
end

function CaloHitContribution(;PDG=0, energy=0, time=0, stepPosition=Vector3f(), particle=-1)
    CaloHitContribution(-1, PDG, energy, time, stepPosition, particle)
end

function Base.getproperty(obj::CaloHitContribution, sym::Symbol)
    if sym == :particle
        idx = getfield(obj, :particle_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Simulated calorimeter hit
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: ID of the sensor that created this hit
- `energy::Float32`: energy of the hit in [GeV].
- `position::Vector3f`: position of the hit in world coordinates in [mm].
# Relations
- `contributions::CaloHitContribution`: Monte Carlo step contribution - parallel to particle
"""
struct SimCalorimeterHit <: POD
    index::ObjectID{SimCalorimeterHit}  # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # ID of the sensor that created this hit
    energy::Float32                  # energy of the hit in [GeV].
    position::Vector3f               # position of the hit in world coordinates in [mm].
    #---OneToManyRelations
    contributions::Relation{SimCalorimeterHit,CaloHitContribution,1}  # Monte Carlo step contribution - parallel to particle
end

function SimCalorimeterHit(;cellID=0, energy=0, position=Vector3f(), contributions=Relation{SimCalorimeterHit,CaloHitContribution,1}())
    SimCalorimeterHit(-1, cellID, energy, position, contributions)
end

"    pushToContributions(object::SimCalorimeterHit, refobj::CaloHitContribution)"
function pushToContributions(c::SimCalorimeterHit, o::CaloHitContribution)
    iszero(c.index) && (c = register(c))
    c = @set c.contributions = push(c.contributions, o)
    update(c)
end
"    popFromContributions(object::SimCalorimeterHit)"
function popFromContributions(c::SimCalorimeterHit)
    iszero(c.index) && (c = register(c))
    c = @set c.contributions = pop(c.contributions)
    update(c)
end
"""
Raw data of a detector readout
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: detector specific cell id.
- `quality::Int32`: quality flag for the hit.
- `time::Float32`: time of the hit [ns].
- `charge::Float32`: integrated charge of the hit [fC].
- `interval::Float32`: interval of each sampling [ns].
- `adcCounts::PVector{Int32}`: raw data (32-bit) word at i.
"""
struct RawTimeSeries <: POD
    index::ObjectID{RawTimeSeries}   # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # detector specific cell id.
    quality::Int32                   # quality flag for the hit.
    time::Float32                    # time of the hit [ns].
    charge::Float32                  # integrated charge of the hit [fC].
    interval::Float32                # interval of each sampling [ns].
    #---VectorMembers
    adcCounts::PVector{RawTimeSeries,Int32,1}  # raw data (32-bit) word at i.
end

function RawTimeSeries(;cellID=0, quality=0, time=0, charge=0, interval=0, adcCounts=PVector{RawTimeSeries,Int32,1}())
    RawTimeSeries(-1, cellID, quality, time, charge, interval, adcCounts)
end

"    setAdcCounts(object::RawTimeSeries, v::AbstractVector{Int32})"
function setAdcCounts(o::RawTimeSeries, v::AbstractVector{Int32})
    iszero(o.index) && (o = register(o))
    o = @set o.adcCounts = v
    update(o)
end
"""
Association between a CaloHit and the corresponding simulated CaloHit
- Author: C. Bernet, B. Hegner
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::CalorimeterHit`: reference to the reconstructed hit
- `sim::SimCalorimeterHit`: reference to the simulated hit
"""
struct MCRecoCaloAssociation <: POD
    index::ObjectID{MCRecoCaloAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{CalorimeterHit}  # reference to the reconstructed hit
    sim_idx::ObjectID{SimCalorimeterHit}  # reference to the simulated hit
end

function MCRecoCaloAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoCaloAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoCaloAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(CalorimeterHit, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(SimCalorimeterHit, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Reconstructed Tracker Pulse
- Author: Wenxing Fang, IHEP
# Fields
- `cellID::UInt64`: cell id.
- `time::Float32`: time [ns].
- `charge::Float32`: charge [fC].
- `quality::Int16`: quality.
- `covMatrix::SVector{3,Float32}`: lower triangle covariance matrix of the charge(c) and time(t) measurements.
# Relations
- `timeSeries::TimeSeries`: Optionally, the timeSeries that has been used to create the pulse can be stored with the pulse.
"""
struct TrackerPulse <: POD
    index::ObjectID{TrackerPulse}    # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # cell id.
    time::Float32                    # time [ns].
    charge::Float32                  # charge [fC].
    quality::Int16                   # quality.
    covMatrix::SVector{3,Float32}    # lower triangle covariance matrix of the charge(c) and time(t) measurements.
    #---OneToOneRelations
    timeSeries_idx::ObjectID{TimeSeries}  # Optionally, the timeSeries that has been used to create the pulse can be stored with the pulse.
end

function TrackerPulse(;cellID=0, time=0, charge=0, quality=0, covMatrix=zero(SVector{3,Float32}), timeSeries=-1)
    TrackerPulse(-1, cellID, time, charge, quality, covMatrix, timeSeries)
end

function Base.getproperty(obj::TrackerPulse, sym::Symbol)
    if sym == :timeSeries
        idx = getfield(obj, :timeSeries_idx)
        return iszero(idx) ? nothing : convert(TimeSeries, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Event Header. Additional parameters are assumed to go into the metadata tree.
- Author: F.Gaede
# Fields
- `eventNumber::Int32`: event number
- `runNumber::Int32`: run number
- `timeStamp::UInt64`: time stamp
- `weight::Float32`: event weight
"""
struct EventHeader <: POD
    index::ObjectID{EventHeader}     # ObjectID of himself
    #---Data Members
    eventNumber::Int32               # event number
    runNumber::Int32                 # run number
    timeStamp::UInt64                # time stamp
    weight::Float32                  # event weight
end

function EventHeader(;eventNumber=0, runNumber=0, timeStamp=0, weight=0)
    EventHeader(-1, eventNumber, runNumber, timeStamp, weight)
end

"""
Tracker hit
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: ID of the sensor that created this hit
- `type::Int32`: type of raw data hit, either one of edm4hep::RawTimeSeries, edm4hep::SIMTRACKERHIT - see collection parameters "TrackerHitTypeNames" and "TrackerHitTypeValues".
- `quality::Int32`: quality bit flag of the hit.
- `time::Float32`: time of the hit [ns].
- `eDep::Float32`: energy deposited on the hit [GeV].
- `eDepError::Float32`: error measured on EDep [GeV].
- `position::Vector3d`: hit position in [mm].
- `covMatrix::SVector{6,Float32}`: covariance of the position (x,y,z), stored as lower triangle matrix. i.e. cov(x,x) , cov(y,x) , cov(y,y) , cov(z,x) , cov(z,y) , cov(z,z)
- `rawHits::PVector{ObjectID}`: raw data hits. Check getType to get actual data type.
"""
struct TrackerHit <: POD
    index::ObjectID{TrackerHit}      # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # ID of the sensor that created this hit
    type::Int32                      # type of raw data hit, either one of edm4hep::RawTimeSeries, edm4hep::SIMTRACKERHIT - see collection parameters "TrackerHitTypeNames" and "TrackerHitTypeValues".
    quality::Int32                   # quality bit flag of the hit.
    time::Float32                    # time of the hit [ns].
    eDep::Float32                    # energy deposited on the hit [GeV].
    eDepError::Float32               # error measured on EDep [GeV].
    position::Vector3d               # hit position in [mm].
    covMatrix::SVector{6,Float32}    # covariance of the position (x,y,z), stored as lower triangle matrix. i.e. cov(x,x) , cov(y,x) , cov(y,y) , cov(z,x) , cov(z,y) , cov(z,z)
    #---VectorMembers
    rawHits::PVector{TrackerHit,ObjectID,1}  # raw data hits. Check getType to get actual data type.
end

function TrackerHit(;cellID=0, type=0, quality=0, time=0, eDep=0, eDepError=0, position=Vector3d(), covMatrix=zero(SVector{6,Float32}), rawHits=PVector{TrackerHit,ObjectID,1}())
    TrackerHit(-1, cellID, type, quality, time, eDep, eDepError, position, covMatrix, rawHits)
end

"    setRawHits(object::TrackerHit, v::AbstractVector{ObjectID})"
function setRawHits(o::TrackerHit, v::AbstractVector{ObjectID})
    iszero(o.index) && (o = register(o))
    o = @set o.rawHits = v
    update(o)
end
"""
Raw calorimeter hit
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: detector specific (geometrical) cell id.
- `amplitude::Int32`: amplitude of the hit in ADC counts.
- `timeStamp::Int32`: time stamp for the hit.
"""
struct RawCalorimeterHit <: POD
    index::ObjectID{RawCalorimeterHit}  # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # detector specific (geometrical) cell id.
    amplitude::Int32                 # amplitude of the hit in ADC counts.
    timeStamp::Int32                 # time stamp for the hit.
end

function RawCalorimeterHit(;cellID=0, amplitude=0, timeStamp=0)
    RawCalorimeterHit(-1, cellID, amplitude, timeStamp)
end

"""
Reconstructed Ionization Cluster
- Author: Wenxing Fang, IHEP
# Fields
- `cellID::UInt64`: cell id.
- `significance::Float32`: significance.
- `type::Int16`: type.
# Relations
- `trackerPulse::TrackerPulse`: the TrackerPulse used to create the ionization cluster.
"""
struct RecIonizationCluster <: POD
    index::ObjectID{RecIonizationCluster}  # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # cell id.
    significance::Float32            # significance.
    type::Int16                      # type.
    #---OneToManyRelations
    trackerPulse::Relation{RecIonizationCluster,TrackerPulse,1}  # the TrackerPulse used to create the ionization cluster.
end

function RecIonizationCluster(;cellID=0, significance=0, type=0, trackerPulse=Relation{RecIonizationCluster,TrackerPulse,1}())
    RecIonizationCluster(-1, cellID, significance, type, trackerPulse)
end

"    pushToTrackerPulse(object::RecIonizationCluster, refobj::TrackerPulse)"
function pushToTrackerPulse(c::RecIonizationCluster, o::TrackerPulse)
    iszero(c.index) && (c = register(c))
    c = @set c.trackerPulse = push(c.trackerPulse, o)
    update(c)
end
"    popFromTrackerPulse(object::RecIonizationCluster)"
function popFromTrackerPulse(c::RecIonizationCluster)
    iszero(c.index) && (c = register(c))
    c = @set c.trackerPulse = pop(c.trackerPulse)
    update(c)
end
"""
Vertex
- Author: F.Gaede, DESY
# Fields
- `primary::Int32`: boolean flag, if vertex is the primary vertex of the event
- `chi2::Float32`: chi-squared of the vertex fit
- `probability::Float32`: probability of the vertex fit
- `position::Vector3f`: [mm] position of the vertex.
- `covMatrix::SVector{6,Float32}`: covariance matrix of the position (stored as lower triangle matrix, i.e. cov(xx),cov(y,x),cov(z,x),cov(y,y),... )
- `algorithmType::Int32`: type code for the algorithm that has been used to create the vertex - check/set the collection parameters AlgorithmName and AlgorithmType.
- `parameters::PVector{Float32}`: additional parameters related to this vertex - check/set the collection parameter "VertexParameterNames" for the parameters meaning.
# Relations
- `associatedParticle::POD`: reconstructed particle associated to this vertex.
"""
struct Vertex <: POD
    index::ObjectID{Vertex}          # ObjectID of himself
    #---Data Members
    primary::Int32                   # boolean flag, if vertex is the primary vertex of the event
    chi2::Float32                    # chi-squared of the vertex fit
    probability::Float32             # probability of the vertex fit
    position::Vector3f               # [mm] position of the vertex.
    covMatrix::SVector{6,Float32}    # covariance matrix of the position (stored as lower triangle matrix, i.e. cov(xx),cov(y,x),cov(z,x),cov(y,y),... )
    algorithmType::Int32             # type code for the algorithm that has been used to create the vertex - check/set the collection parameters AlgorithmName and AlgorithmType.
    #---VectorMembers
    parameters::PVector{Vertex,Float32,1}  # additional parameters related to this vertex - check/set the collection parameter "VertexParameterNames" for the parameters meaning.
    #---OneToOneRelations
    associatedParticle_idx::ObjectID{POD}  # reconstructed particle associated to this vertex.
end

function Vertex(;primary=0, chi2=0, probability=0, position=Vector3f(), covMatrix=zero(SVector{6,Float32}), algorithmType=0, parameters=PVector{Vertex,Float32,1}(), associatedParticle=-1)
    Vertex(-1, primary, chi2, probability, position, covMatrix, algorithmType, parameters, associatedParticle)
end

function Base.getproperty(obj::Vertex, sym::Symbol)
    if sym == :associatedParticle
        idx = getfield(obj, :associatedParticle_idx)
        return iszero(idx) ? nothing : convert(POD, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"    setParameters(object::Vertex, v::AbstractVector{Float32})"
function setParameters(o::Vertex, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.parameters = v
    update(o)
end
"""
Reconstructed track
- Author: F.Gaede, DESY
# Fields
- `type::Int32`: flagword that defines the type of track.Bits 16-31 are used internally
- `chi2::Float32`: Chi^2 of the track fit
- `ndf::Int32`: number of degrees of freedom of the track fit
- `dEdx::Float32`: dEdx of the track.
- `dEdxError::Float32`: error of dEdx.
- `radiusOfInnermostHit::Float32`: radius of the innermost hit that has been used in the track fit
- `subdetectorHitNumbers::PVector{Int32}`: number of hits in particular subdetectors.Check/set collection variable TrackSubdetectorNames for decoding the indices
- `trackStates::PVector{TrackState}`: track states
- `dxQuantities::PVector{Quantity}`: different measurements of dx quantities
# Relations
- `trackerHits::TrackerHit`: hits that have been used to create this track
- `tracks::Track`: tracks (segments) that have been combined to create this track
"""
struct Track <: POD
    index::ObjectID{Track}           # ObjectID of himself
    #---Data Members
    type::Int32                      # flagword that defines the type of track.Bits 16-31 are used internally
    chi2::Float32                    # Chi^2 of the track fit
    ndf::Int32                       # number of degrees of freedom of the track fit
    dEdx::Float32                    # dEdx of the track.
    dEdxError::Float32               # error of dEdx.
    radiusOfInnermostHit::Float32    # radius of the innermost hit that has been used in the track fit
    #---VectorMembers
    subdetectorHitNumbers::PVector{Track,Int32,1}  # number of hits in particular subdetectors.Check/set collection variable TrackSubdetectorNames for decoding the indices
    trackStates::PVector{Track,TrackState,2}  # track states
    dxQuantities::PVector{Track,Quantity,3}  # different measurements of dx quantities
    #---OneToManyRelations
    trackerHits::Relation{Track,TrackerHit,1}  # hits that have been used to create this track
    tracks::Relation{Track,Track,2}  # tracks (segments) that have been combined to create this track
end

function Track(;type=0, chi2=0, ndf=0, dEdx=0, dEdxError=0, radiusOfInnermostHit=0, subdetectorHitNumbers=PVector{Track,Int32,1}(), trackStates=PVector{Track,TrackState,2}(), dxQuantities=PVector{Track,Quantity,3}(), trackerHits=Relation{Track,TrackerHit,1}(), tracks=Relation{Track,Track,2}())
    Track(-1, type, chi2, ndf, dEdx, dEdxError, radiusOfInnermostHit, subdetectorHitNumbers, trackStates, dxQuantities, trackerHits, tracks)
end

"    pushToTrackerHits(object::Track, refobj::TrackerHit)"
function pushToTrackerHits(c::Track, o::TrackerHit)
    iszero(c.index) && (c = register(c))
    c = @set c.trackerHits = push(c.trackerHits, o)
    update(c)
end
"    popFromTrackerHits(object::Track)"
function popFromTrackerHits(c::Track)
    iszero(c.index) && (c = register(c))
    c = @set c.trackerHits = pop(c.trackerHits)
    update(c)
end
"    pushToTracks(object::Track, refobj::Track)"
function pushToTracks(c::Track, o::Track)
    iszero(c.index) && (c = register(c))
    c = @set c.tracks = push(c.tracks, o)
    update(c)
end
"    popFromTracks(object::Track)"
function popFromTracks(c::Track)
    iszero(c.index) && (c = register(c))
    c = @set c.tracks = pop(c.tracks)
    update(c)
end
"    setSubdetectorHitNumbers(object::Track, v::AbstractVector{Int32})"
function setSubdetectorHitNumbers(o::Track, v::AbstractVector{Int32})
    iszero(o.index) && (o = register(o))
    o = @set o.subdetectorHitNumbers = v
    update(o)
end
"    setTrackStates(object::Track, v::AbstractVector{TrackState})"
function setTrackStates(o::Track, v::AbstractVector{TrackState})
    iszero(o.index) && (o = register(o))
    o = @set o.trackStates = v
    update(o)
end
"    setDxQuantities(object::Track, v::AbstractVector{Quantity})"
function setDxQuantities(o::Track, v::AbstractVector{Quantity})
    iszero(o.index) && (o = register(o))
    o = @set o.dxQuantities = v
    update(o)
end
"""
Association between a Track and a MCParticle
- Author: Placido Fernandez Declara
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::Track`: reference to the track
- `sim::MCParticle`: reference to the Monte-Carlo particle
"""
struct MCRecoTrackParticleAssociation <: POD
    index::ObjectID{MCRecoTrackParticleAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{Track}         # reference to the track
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

function MCRecoTrackParticleAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoTrackParticleAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoTrackParticleAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(Track, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Reconstructed Particle
- Author: F.Gaede, DESY
# Fields
- `type::Int32`: type of reconstructed particle. Check/set collection parameters ReconstructedParticleTypeNames and ReconstructedParticleTypeValues.
- `energy::Float32`: [GeV] energy of the reconstructed particle. Four momentum state is not kept consistent internally.
- `momentum::Vector3f`: [GeV] particle momentum. Four momentum state is not kept consistent internally.
- `referencePoint::Vector3f`: [mm] reference, i.e. where the particle has been measured
- `charge::Float32`: charge of the reconstructed particle.
- `mass::Float32`: [GeV] mass of the reconstructed particle, set independently from four vector. Four momentum state is not kept consistent internally.
- `goodnessOfPID::Float32`: overall goodness of the PID on a scale of [0;1]
- `covMatrix::SVector{10,Float32}`: cvariance matrix of the reconstructed particle 4vector (10 parameters). Stored as lower triangle matrix of the four momentum (px,py,pz,E), i.e. cov(px,px), cov(py,##
# Relations
- `startVertex::Vertex`: start vertex associated to this particle
- `particleIDUsed::ParticleID`: particle Id used for the kinematics of this particle
- `clusters::Cluster`: clusters that have been used for this particle.
- `tracks::Track`: tracks that have been used for this particle.
- `particles::ReconstructedParticle`: reconstructed particles that have been combined to this particle.
- `particleIDs::ParticleID`: particle Ids (not sorted by their likelihood)
"""
struct ReconstructedParticle <: POD
    index::ObjectID{ReconstructedParticle}  # ObjectID of himself
    #---Data Members
    type::Int32                      # type of reconstructed particle. Check/set collection parameters ReconstructedParticleTypeNames and ReconstructedParticleTypeValues.
    energy::Float32                  # [GeV] energy of the reconstructed particle. Four momentum state is not kept consistent internally.
    momentum::Vector3f               # [GeV] particle momentum. Four momentum state is not kept consistent internally.
    referencePoint::Vector3f         # [mm] reference, i.e. where the particle has been measured
    charge::Float32                  # charge of the reconstructed particle.
    mass::Float32                    # [GeV] mass of the reconstructed particle, set independently from four vector. Four momentum state is not kept consistent internally.
    goodnessOfPID::Float32           # overall goodness of the PID on a scale of [0;1]
    covMatrix::SVector{10,Float32}   # cvariance matrix of the reconstructed particle 4vector (10 parameters). Stored as lower triangle matrix of the four momentum (px,py,pz,E), i.e. cov(px,px), cov(py,##
    #---OneToOneRelations
    startVertex_idx::ObjectID{Vertex}  # start vertex associated to this particle
    particleIDUsed_idx::ObjectID{ParticleID}  # particle Id used for the kinematics of this particle
    #---OneToManyRelations
    clusters::Relation{ReconstructedParticle,Cluster,1}  # clusters that have been used for this particle.
    tracks::Relation{ReconstructedParticle,Track,2}  # tracks that have been used for this particle.
    particles::Relation{ReconstructedParticle,ReconstructedParticle,3}  # reconstructed particles that have been combined to this particle.
    particleIDs::Relation{ReconstructedParticle,ParticleID,4}  # particle Ids (not sorted by their likelihood)
end

function ReconstructedParticle(;type=0, energy=0, momentum=Vector3f(), referencePoint=Vector3f(), charge=0, mass=0, goodnessOfPID=0, covMatrix=zero(SVector{10,Float32}), startVertex=-1, particleIDUsed=-1, clusters=Relation{ReconstructedParticle,Cluster,1}(), tracks=Relation{ReconstructedParticle,Track,2}(), particles=Relation{ReconstructedParticle,ReconstructedParticle,3}(), particleIDs=Relation{ReconstructedParticle,ParticleID,4}())
    ReconstructedParticle(-1, type, energy, momentum, referencePoint, charge, mass, goodnessOfPID, covMatrix, startVertex, particleIDUsed, clusters, tracks, particles, particleIDs)
end

function Base.getproperty(obj::ReconstructedParticle, sym::Symbol)
    if sym == :startVertex
        idx = getfield(obj, :startVertex_idx)
        return iszero(idx) ? nothing : convert(Vertex, idx)
    elseif sym == :particleIDUsed
        idx = getfield(obj, :particleIDUsed_idx)
        return iszero(idx) ? nothing : convert(ParticleID, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"    pushToClusters(object::ReconstructedParticle, refobj::Cluster)"
function pushToClusters(c::ReconstructedParticle, o::Cluster)
    iszero(c.index) && (c = register(c))
    c = @set c.clusters = push(c.clusters, o)
    update(c)
end
"    popFromClusters(object::ReconstructedParticle)"
function popFromClusters(c::ReconstructedParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.clusters = pop(c.clusters)
    update(c)
end
"    pushToTracks(object::ReconstructedParticle, refobj::Track)"
function pushToTracks(c::ReconstructedParticle, o::Track)
    iszero(c.index) && (c = register(c))
    c = @set c.tracks = push(c.tracks, o)
    update(c)
end
"    popFromTracks(object::ReconstructedParticle)"
function popFromTracks(c::ReconstructedParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.tracks = pop(c.tracks)
    update(c)
end
"    pushToParticles(object::ReconstructedParticle, refobj::ReconstructedParticle)"
function pushToParticles(c::ReconstructedParticle, o::ReconstructedParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.particles = push(c.particles, o)
    update(c)
end
"    popFromParticles(object::ReconstructedParticle)"
function popFromParticles(c::ReconstructedParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.particles = pop(c.particles)
    update(c)
end
"    pushToParticleIDs(object::ReconstructedParticle, refobj::ParticleID)"
function pushToParticleIDs(c::ReconstructedParticle, o::ParticleID)
    iszero(c.index) && (c = register(c))
    c = @set c.particleIDs = push(c.particleIDs, o)
    update(c)
end
"    popFromParticleIDs(object::ReconstructedParticle)"
function popFromParticleIDs(c::ReconstructedParticle)
    iszero(c.index) && (c = register(c))
    c = @set c.particleIDs = pop(c.particleIDs)
    update(c)
end
"""
Used to keep track of the correspondence between MC and reconstructed particles
- Author: C. Bernet, B. Hegner
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::ReconstructedParticle`: reference to the reconstructed particle
- `sim::MCParticle`: reference to the Monte-Carlo particle
"""
struct MCRecoParticleAssociation <: POD
    index::ObjectID{MCRecoParticleAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{ReconstructedParticle}  # reference to the reconstructed particle
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

function MCRecoParticleAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoParticleAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoParticleAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(ReconstructedParticle, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Association between a Reconstructed Particle and a Vertex
- Author: Placido Fernandez Declara
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::ReconstructedParticle`: reference to the reconstructed particle
- `vertex::Vertex`: reference to the vertex
"""
struct RecoParticleVertexAssociation <: POD
    index::ObjectID{RecoParticleVertexAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{ReconstructedParticle}  # reference to the reconstructed particle
    vertex_idx::ObjectID{Vertex}     # reference to the vertex
end

function RecoParticleVertexAssociation(;weight=0, rec=-1, vertex=-1)
    RecoParticleVertexAssociation(-1, weight, rec, vertex)
end

function Base.getproperty(obj::RecoParticleVertexAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(ReconstructedParticle, idx)
    elseif sym == :vertex
        idx = getfield(obj, :vertex_idx)
        return iszero(idx) ? nothing : convert(Vertex, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
dN/dx or dE/dx info of Track.
- Author: Wenxing Fang, IHEP
# Fields
- `dQdx::Quantity`: the reconstructed dEdx or dNdx and its error
- `particleType::Int16`: particle type, e(0),mu(1),pi(2),K(3),p(4).
- `type::Int16`: type.
- `hypotheses::SVector{5,Hypothesis}`: 5 particle hypothesis
- `hitData::PVector{HitLevelData}`: hit level data
# Relations
- `track::Track`: the corresponding track.
"""
struct RecDqdx <: POD
    index::ObjectID{RecDqdx}         # ObjectID of himself
    #---Data Members
    dQdx::Quantity                   # the reconstructed dEdx or dNdx and its error
    particleType::Int16              # particle type, e(0),mu(1),pi(2),K(3),p(4).
    type::Int16                      # type.
    hypotheses::SVector{5,Hypothesis}  # 5 particle hypothesis
    #---VectorMembers
    hitData::PVector{RecDqdx,HitLevelData,1}  # hit level data
    #---OneToOneRelations
    track_idx::ObjectID{Track}       # the corresponding track.
end

function RecDqdx(;dQdx=Quantity(), particleType=0, type=0, hypotheses=zero(SVector{5,Hypothesis}), hitData=PVector{RecDqdx,HitLevelData,1}(), track=-1)
    RecDqdx(-1, dQdx, particleType, type, hypotheses, hitData, track)
end

function Base.getproperty(obj::RecDqdx, sym::Symbol)
    if sym == :track
        idx = getfield(obj, :track_idx)
        return iszero(idx) ? nothing : convert(Track, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"    setHitData(object::RecDqdx, v::AbstractVector{HitLevelData})"
function setHitData(o::RecDqdx, v::AbstractVector{HitLevelData})
    iszero(o.index) && (o = register(o))
    o = @set o.hitData = v
    update(o)
end
"""
Tracker hit plane
- Author: Placido Fernandez Declara, CERN
# Fields
- `cellID::UInt64`: ID of the sensor that created this hit
- `type::Int32`: type of raw data hit, either one of edm4hep::RawTimeSeries, edm4hep::SIMTRACKERHIT - see collection parameters "TrackerHitTypeNames" and "TrackerHitTypeValues".
- `quality::Int32`: quality bit flag of the hit.
- `time::Float32`: time of the hit [ns].
- `eDep::Float32`: energy deposited on the hit [GeV].
- `eDepError::Float32`: error measured on EDep [GeV].
- `u::Vector2f`: measurement direction vector, u lies in the x-y plane
- `v::Vector2f`: measurement direction vector, v is along z
- `du::Float32`: measurement error along the direction
- `dv::Float32`: measurement error along the direction
- `position::Vector3d`: hit position in [mm].
- `covMatrix::SVector{6,Float32}`: covariance of the position (x,y,z), stored as lower triangle matrix. i.e. cov(x,x) , cov(y,x) , cov(y,y) , cov(z,x) , cov(z,y) , cov(z,z)
- `rawHits::PVector{ObjectID}`: raw data hits. Check getType to get actual data type.
"""
struct TrackerHitPlane <: POD
    index::ObjectID{TrackerHitPlane} # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # ID of the sensor that created this hit
    type::Int32                      # type of raw data hit, either one of edm4hep::RawTimeSeries, edm4hep::SIMTRACKERHIT - see collection parameters "TrackerHitTypeNames" and "TrackerHitTypeValues".
    quality::Int32                   # quality bit flag of the hit.
    time::Float32                    # time of the hit [ns].
    eDep::Float32                    # energy deposited on the hit [GeV].
    eDepError::Float32               # error measured on EDep [GeV].
    u::Vector2f                      # measurement direction vector, u lies in the x-y plane
    v::Vector2f                      # measurement direction vector, v is along z
    du::Float32                      # measurement error along the direction
    dv::Float32                      # measurement error along the direction
    position::Vector3d               # hit position in [mm].
    covMatrix::SVector{6,Float32}    # covariance of the position (x,y,z), stored as lower triangle matrix. i.e. cov(x,x) , cov(y,x) , cov(y,y) , cov(z,x) , cov(z,y) , cov(z,z)
    #---VectorMembers
    rawHits::PVector{TrackerHitPlane,ObjectID,1}  # raw data hits. Check getType to get actual data type.
end

function TrackerHitPlane(;cellID=0, type=0, quality=0, time=0, eDep=0, eDepError=0, u=Vector2f(), v=Vector2f(), du=0, dv=0, position=Vector3d(), covMatrix=zero(SVector{6,Float32}), rawHits=PVector{TrackerHitPlane,ObjectID,1}())
    TrackerHitPlane(-1, cellID, type, quality, time, eDep, eDepError, u, v, du, dv, position, covMatrix, rawHits)
end

"    setRawHits(object::TrackerHitPlane, v::AbstractVector{ObjectID})"
function setRawHits(o::TrackerHitPlane, v::AbstractVector{ObjectID})
    iszero(o.index) && (o = register(o))
    o = @set o.rawHits = v
    update(o)
end
"""
Simulated tracker hit
- Author: F.Gaede, DESY
# Fields
- `cellID::UInt64`: ID of the sensor that created this hit
- `EDep::Float32`: energy deposited in the hit [GeV].
- `time::Float32`: proper time of the hit in the lab frame in [ns].
- `pathLength::Float32`: path length of the particle in the sensitive material that resulted in this hit.
- `quality::Int32`: quality bit flag.
- `position::Vector3d`: the hit position in [mm].
- `momentum::Vector3f`: the 3-momentum of the particle at the hits position in [GeV]
# Relations
- `mcparticle::MCParticle`: MCParticle that caused the hit.
"""
struct SimTrackerHit <: POD
    index::ObjectID{SimTrackerHit}   # ObjectID of himself
    #---Data Members
    cellID::UInt64                   # ID of the sensor that created this hit
    EDep::Float32                    # energy deposited in the hit [GeV].
    time::Float32                    # proper time of the hit in the lab frame in [ns].
    pathLength::Float32              # path length of the particle in the sensitive material that resulted in this hit.
    quality::Int32                   # quality bit flag.
    position::Vector3d               # the hit position in [mm].
    momentum::Vector3f               # the 3-momentum of the particle at the hits position in [GeV]
    #---OneToOneRelations
    mcparticle_idx::ObjectID{MCParticle}  # MCParticle that caused the hit.
end

function SimTrackerHit(;cellID=0, EDep=0, time=0, pathLength=0, quality=0, position=Vector3d(), momentum=Vector3f(), mcparticle=-1)
    SimTrackerHit(-1, cellID, EDep, time, pathLength, quality, position, momentum, mcparticle)
end

function Base.getproperty(obj::SimTrackerHit, sym::Symbol)
    if sym == :mcparticle
        idx = getfield(obj, :mcparticle_idx)
        return iszero(idx) ? nothing : convert(MCParticle, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Association between a TrackerHitPlane and the corresponding simulated TrackerHit
- Author: Placido Fernandez Declara
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::TrackerHitPlane`: reference to the reconstructed hit
- `sim::SimTrackerHit`: reference to the simulated hit
"""
struct MCRecoTrackerHitPlaneAssociation <: POD
    index::ObjectID{MCRecoTrackerHitPlaneAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{TrackerHitPlane}  # reference to the reconstructed hit
    sim_idx::ObjectID{SimTrackerHit} # reference to the simulated hit
end

function MCRecoTrackerHitPlaneAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoTrackerHitPlaneAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoTrackerHitPlaneAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(TrackerHitPlane, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(SimTrackerHit, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
"""
Association between a TrackerHit and the corresponding simulated TrackerHit
- Author: C. Bernet, B. Hegner
# Fields
- `weight::Float32`: weight of this association
# Relations
- `rec::TrackerHit`: reference to the reconstructed hit
- `sim::SimTrackerHit`: reference to the simulated hit
"""
struct MCRecoTrackerAssociation <: POD
    index::ObjectID{MCRecoTrackerAssociation}  # ObjectID of himself
    #---Data Members
    weight::Float32                  # weight of this association
    #---OneToOneRelations
    rec_idx::ObjectID{TrackerHit}    # reference to the reconstructed hit
    sim_idx::ObjectID{SimTrackerHit} # reference to the simulated hit
end

function MCRecoTrackerAssociation(;weight=0, rec=-1, sim=-1)
    MCRecoTrackerAssociation(-1, weight, rec, sim)
end

function Base.getproperty(obj::MCRecoTrackerAssociation, sym::Symbol)
    if sym == :rec
        idx = getfield(obj, :rec_idx)
        return iszero(idx) ? nothing : convert(TrackerHit, idx)
    elseif sym == :sim
        idx = getfield(obj, :sim_idx)
        return iszero(idx) ? nothing : convert(SimTrackerHit, idx)
    else # fallback to getfield
        return getfield(obj, sym)
    end
end
export setParameters, ParticleID, setAmplitude, TimeSeries, CalorimeterHit, pushToClusters, popFromClusters, pushToHits, popFromHits, pushToParticleIDs, popFromParticleIDs, setShapeParameters, setSubdetectorEnergies, Cluster, pushToParents, popFromParents, pushToDaughters, popFromDaughters, MCParticle, setElectronCellID, setElectronTime, setElectronPosition, setPulseTime, setPulseAmplitude, SimPrimaryIonizationCluster, MCRecoClusterParticleAssociation, MCRecoCaloParticleAssociation, CaloHitContribution, pushToContributions, popFromContributions, SimCalorimeterHit, setAdcCounts, RawTimeSeries, MCRecoCaloAssociation, TrackerPulse, EventHeader, setRawHits, TrackerHit, RawCalorimeterHit, pushToTrackerPulse, popFromTrackerPulse, RecIonizationCluster, Vertex, pushToTrackerHits, popFromTrackerHits, pushToTracks, popFromTracks, setSubdetectorHitNumbers, setTrackStates, setDxQuantities, Track, MCRecoTrackParticleAssociation, pushToParticles, popFromParticles, ReconstructedParticle, MCRecoParticleAssociation, RecoParticleVertexAssociation, setHitData, RecDqdx, TrackerHitPlane, SimTrackerHit, MCRecoTrackerHitPlaneAssociation, MCRecoTrackerAssociation
