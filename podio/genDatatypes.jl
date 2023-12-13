"""
struct ParticleID

    Description: ParticleID
    Author: F.Gaede, DESY
"""
struct ParticleID <: POD
    index::ObjectID{ParticleID}      # ObjectID of himself

    #---Data Members
    type::Int32                      # userdefined type
    PDG::Int32                       # PDG code of this id - ( 999999 ) if unknown.
    algorithmType::Int32             # type of the algorithm/module that created this hypothesis
    likelihood::Float32              # likelihood of this hypothesis - in a user defined normalization.
end

relations(::Type{ParticleID}) = 0
function ParticleID(;type=0, PDG=0, algorithmType=0, likelihood=0)
    ParticleID(-1, type, PDG, algorithmType, likelihood)
end

"""
struct TimeSeries

    Description: Calibrated Detector Data
    Author: Wenxing Fang, IHEP
"""
struct TimeSeries <: POD
    index::ObjectID{TimeSeries}      # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # cell id.
    time::Float32                    # begin time [ns].
    interval::Float32                # interval of each sampling [ns].
end

relations(::Type{TimeSeries}) = 0
function TimeSeries(;cellID=0, time=0, interval=0)
    TimeSeries(-1, cellID, time, interval)
end

"""
struct CalorimeterHit

    Description: Calorimeter hit
    Author: F.Gaede, DESY
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

relations(::Type{CalorimeterHit}) = 0
function CalorimeterHit(;cellID=0, energy=0, energyError=0, time=0, position=Vector3f(), type=0)
    CalorimeterHit(-1, cellID, energy, energyError, time, position, type)
end

"""
struct Cluster

    Description: Calorimeter Hit Cluster
    Author: F.Gaede, DESY
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

    #---OneToManyRelations
    clusters::Relation{Cluster,1}    # clusters that have been combined to this cluster.
    hits::Relation{CalorimeterHit,2} # hits that have been combined to this cluster.
    particleids::Relation{ParticleID,3}  # particle IDs (sorted by their likelihood)
end

relations(::Type{Cluster}) = 3
function Cluster(;type=0, energy=0, energyError=0, position=Vector3f(), positionError=zero(SVector{6,Float32}), iTheta=0, phi=0, directionError=Vector3f(), clusters=Relation{Cluster,1}(), hits=Relation{CalorimeterHit,2}(), particleids=Relation{ParticleID,3}())
    Cluster(-1, type, energy, energyError, position, positionError, iTheta, phi, directionError, clusters, hits, particleids)
end

"""
struct MCParticle

    Description: The Monte Carlo particle - based on the lcio::MCParticle.
    Author: F.Gaede, DESY
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
    momentum::Vector3f               # particle 3-momentum at the production vertex in [GeV]
    momentumAtEndpoint::Vector3f     # particle 3-momentum at the endpoint in [GeV]
    spin::Vector3f                   # spin (helicity) vector of the particle.
    colorFlow::Vector2i              # color flow as defined by the generator

    #---OneToManyRelations
    parents::Relation{MCParticle,1}  # The parents of this particle.
    daughters::Relation{MCParticle,2}  # The daughters this particle.
end

relations(::Type{MCParticle}) = 2
function MCParticle(;PDG=0, generatorStatus=0, simulatorStatus=0, charge=0, time=0, mass=0, vertex=Vector3d(), endpoint=Vector3d(), momentum=Vector3f(), momentumAtEndpoint=Vector3f(), spin=Vector3f(), colorFlow=Vector2i(), parents=Relation{MCParticle,1}(), daughters=Relation{MCParticle,2}())
    MCParticle(-1, PDG, generatorStatus, simulatorStatus, charge, time, mass, vertex, endpoint, momentum, momentumAtEndpoint, spin, colorFlow, parents, daughters)
end

"""
struct SimPrimaryIonizationCluster

    Description: Simulated Primary Ionization
    Author: Wenxing Fang, IHEP
"""
struct SimPrimaryIonizationCluster <: POD
    index::ObjectID{SimPrimaryIonizationCluster}  # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # cell id.
    time::Float32                    # the primary ionization's time in the lab frame [ns].
    position::Vector3d               # the primary ionization's position [mm].
    type::Int16                      # type.

    #---OneToOneRelations
    mcparticle_idx::ObjectID{MCParticle}  # the particle that caused the ionizing collisions.
end

relations(::Type{SimPrimaryIonizationCluster}) = 0
function SimPrimaryIonizationCluster(;cellID=0, time=0, position=Vector3d(), type=0, mcparticle=0)
    SimPrimaryIonizationCluster(-1, cellID, time, position, type, mcparticle)
end

"""
struct MCRecoClusterParticleAssociation

    Description: Association between a Cluster and a MCParticle
    Author: Placido Fernandez Declara
"""
struct MCRecoClusterParticleAssociation <: POD
    index::ObjectID{MCRecoClusterParticleAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{Cluster}       # reference to the cluster
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

relations(::Type{MCRecoClusterParticleAssociation}) = 0
function MCRecoClusterParticleAssociation(;weight=0, rec=0, sim=0)
    MCRecoClusterParticleAssociation(-1, weight, rec, sim)
end

"""
struct MCRecoCaloParticleAssociation

    Description: Association between a CalorimeterHit and a MCParticle
    Author: Placido Fernandez Declara
"""
struct MCRecoCaloParticleAssociation <: POD
    index::ObjectID{MCRecoCaloParticleAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{CalorimeterHit}  # reference to the reconstructed hit
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

relations(::Type{MCRecoCaloParticleAssociation}) = 0
function MCRecoCaloParticleAssociation(;weight=0, rec=0, sim=0)
    MCRecoCaloParticleAssociation(-1, weight, rec, sim)
end

"""
struct CaloHitContribution

    Description: Monte Carlo contribution to SimCalorimeterHit
    Author: F.Gaede, DESY
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

relations(::Type{CaloHitContribution}) = 0
function CaloHitContribution(;PDG=0, energy=0, time=0, stepPosition=Vector3f(), particle=0)
    CaloHitContribution(-1, PDG, energy, time, stepPosition, particle)
end

"""
struct SimCalorimeterHit

    Description: Simulated calorimeter hit
    Author: F.Gaede, DESY
"""
struct SimCalorimeterHit <: POD
    index::ObjectID{SimCalorimeterHit}  # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # ID of the sensor that created this hit
    energy::Float32                  # energy of the hit in [GeV].
    position::Vector3f               # position of the hit in world coordinates in [mm].

    #---OneToManyRelations
    contributions::Relation{CaloHitContribution,1}  # Monte Carlo step contribution - parallel to particle
end

relations(::Type{SimCalorimeterHit}) = 1
function SimCalorimeterHit(;cellID=0, energy=0, position=Vector3f(), contributions=Relation{CaloHitContribution,1}())
    SimCalorimeterHit(-1, cellID, energy, position, contributions)
end

"""
struct RawTimeSeries

    Description: Raw data of a detector readout
    Author: F.Gaede, DESY
"""
struct RawTimeSeries <: POD
    index::ObjectID{RawTimeSeries}   # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # detector specific cell id.
    quality::Int32                   # quality flag for the hit.
    time::Float32                    # time of the hit [ns].
    charge::Float32                  # integrated charge of the hit [fC].
    interval::Float32                # interval of each sampling [ns].
end

relations(::Type{RawTimeSeries}) = 0
function RawTimeSeries(;cellID=0, quality=0, time=0, charge=0, interval=0)
    RawTimeSeries(-1, cellID, quality, time, charge, interval)
end

"""
struct MCRecoCaloAssociation

    Description: Association between a CaloHit and the corresponding simulated CaloHit
    Author: C. Bernet, B. Hegner
"""
struct MCRecoCaloAssociation <: POD
    index::ObjectID{MCRecoCaloAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{CalorimeterHit}  # reference to the reconstructed hit
    sim_idx::ObjectID{SimCalorimeterHit}  # reference to the simulated hit
end

relations(::Type{MCRecoCaloAssociation}) = 0
function MCRecoCaloAssociation(;weight=0, rec=0, sim=0)
    MCRecoCaloAssociation(-1, weight, rec, sim)
end

"""
struct TrackerPulse

    Description: Reconstructed Tracker Pulse
    Author: Wenxing Fang, IHEP
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
    timeseries_idx::ObjectID{TimeSeries}  # Optionally, the timeSeries that has been used to create the pulse can be stored with the pulse.
end

relations(::Type{TrackerPulse}) = 0
function TrackerPulse(;cellID=0, time=0, charge=0, quality=0, covMatrix=zero(SVector{3,Float32}), timeseries=0)
    TrackerPulse(-1, cellID, time, charge, quality, covMatrix, timeseries)
end

"""
struct EventHeader

    Description: Event Header. Additional parameters are assumed to go into the metadata tree.
    Author: F.Gaede
"""
struct EventHeader <: POD
    index::ObjectID{EventHeader}     # ObjectID of himself

    #---Data Members
    eventNumber::Int32               # event number
    runNumber::Int32                 # run number
    timeStamp::UInt64                # time stamp
    weight::Float32                  # event weight
end

relations(::Type{EventHeader}) = 0
function EventHeader(;eventNumber=0, runNumber=0, timeStamp=0, weight=0)
    EventHeader(-1, eventNumber, runNumber, timeStamp, weight)
end

"""
struct TrackerHit

    Description: Tracker hit
    Author: F.Gaede, DESY
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
end

relations(::Type{TrackerHit}) = 0
function TrackerHit(;cellID=0, type=0, quality=0, time=0, eDep=0, eDepError=0, position=Vector3d(), covMatrix=zero(SVector{6,Float32}))
    TrackerHit(-1, cellID, type, quality, time, eDep, eDepError, position, covMatrix)
end

"""
struct RawCalorimeterHit

    Description: Raw calorimeter hit
    Author: F.Gaede, DESY
"""
struct RawCalorimeterHit <: POD
    index::ObjectID{RawCalorimeterHit}  # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # detector specific (geometrical) cell id.
    amplitude::Int32                 # amplitude of the hit in ADC counts.
    timeStamp::Int32                 # time stamp for the hit.
end

relations(::Type{RawCalorimeterHit}) = 0
function RawCalorimeterHit(;cellID=0, amplitude=0, timeStamp=0)
    RawCalorimeterHit(-1, cellID, amplitude, timeStamp)
end

"""
struct RecIonizationCluster

    Description: Reconstructed Ionization Cluster
    Author: Wenxing Fang, IHEP
"""
struct RecIonizationCluster <: POD
    index::ObjectID{RecIonizationCluster}  # ObjectID of himself

    #---Data Members
    cellID::UInt64                   # cell id.
    significance::Float32            # significance.
    type::Int16                      # type.

    #---OneToManyRelations
    trackerpulse::Relation{TrackerPulse,1}  # the TrackerPulse used to create the ionization cluster.
end

relations(::Type{RecIonizationCluster}) = 1
function RecIonizationCluster(;cellID=0, significance=0, type=0, trackerpulse=Relation{TrackerPulse,1}())
    RecIonizationCluster(-1, cellID, significance, type, trackerpulse)
end

"""
struct Vertex

    Description: Vertex
    Author: F.Gaede, DESY
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
end

relations(::Type{Vertex}) = 0
function Vertex(;primary=0, chi2=0, probability=0, position=Vector3f(), covMatrix=zero(SVector{6,Float32}), algorithmType=0)
    Vertex(-1, primary, chi2, probability, position, covMatrix, algorithmType)
end

"""
struct Track

    Description: Reconstructed track
    Author: F.Gaede, DESY
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

    #---OneToManyRelations
    trackerhits::Relation{TrackerHit,1}  # hits that have been used to create this track
    tracks::Relation{Track,2}        # tracks (segments) that have been combined to create this track
end

relations(::Type{Track}) = 2
function Track(;type=0, chi2=0, ndf=0, dEdx=0, dEdxError=0, radiusOfInnermostHit=0, trackerhits=Relation{TrackerHit,1}(), tracks=Relation{Track,2}())
    Track(-1, type, chi2, ndf, dEdx, dEdxError, radiusOfInnermostHit, trackerhits, tracks)
end

"""
struct MCRecoTrackParticleAssociation

    Description: Association between a Track and a MCParticle
    Author: Placido Fernandez Declara
"""
struct MCRecoTrackParticleAssociation <: POD
    index::ObjectID{MCRecoTrackParticleAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{Track}         # reference to the track
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

relations(::Type{MCRecoTrackParticleAssociation}) = 0
function MCRecoTrackParticleAssociation(;weight=0, rec=0, sim=0)
    MCRecoTrackParticleAssociation(-1, weight, rec, sim)
end

"""
struct ReconstructedParticle

    Description: Reconstructed Particle
    Author: F.Gaede, DESY
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
    startvertex_idx::ObjectID{Vertex}  # start vertex associated to this particle
    particleidused_idx::ObjectID{ParticleID}  # particle Id used for the kinematics of this particle

    #---OneToManyRelations
    clusters::Relation{Cluster,1}    # clusters that have been used for this particle.
    tracks::Relation{Track,2}        # tracks that have been used for this particle.
    particles::Relation{ReconstructedParticle,3}  # reconstructed particles that have been combined to this particle.
    particleids::Relation{ParticleID,4}  # particle Ids (not sorted by their likelihood)
end

relations(::Type{ReconstructedParticle}) = 4
function ReconstructedParticle(;type=0, energy=0, momentum=Vector3f(), referencePoint=Vector3f(), charge=0, mass=0, goodnessOfPID=0, covMatrix=zero(SVector{10,Float32}), startvertex=0, particleidused=0, clusters=Relation{Cluster,1}(), tracks=Relation{Track,2}(), particles=Relation{ReconstructedParticle,3}(), particleids=Relation{ParticleID,4}())
    ReconstructedParticle(-1, type, energy, momentum, referencePoint, charge, mass, goodnessOfPID, covMatrix, startvertex, particleidused, clusters, tracks, particles, particleids)
end

"""
struct MCRecoParticleAssociation

    Description: Used to keep track of the correspondence between MC and reconstructed particles
    Author: C. Bernet, B. Hegner
"""
struct MCRecoParticleAssociation <: POD
    index::ObjectID{MCRecoParticleAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{ReconstructedParticle}  # reference to the reconstructed particle
    sim_idx::ObjectID{MCParticle}    # reference to the Monte-Carlo particle
end

relations(::Type{MCRecoParticleAssociation}) = 0
function MCRecoParticleAssociation(;weight=0, rec=0, sim=0)
    MCRecoParticleAssociation(-1, weight, rec, sim)
end

"""
struct RecoParticleVertexAssociation

    Description: Association between a Reconstructed Particle and a Vertex
    Author: Placido Fernandez Declara
"""
struct RecoParticleVertexAssociation <: POD
    index::ObjectID{RecoParticleVertexAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{ReconstructedParticle}  # reference to the reconstructed particle
    vertex_idx::ObjectID{Vertex}     # reference to the vertex
end

relations(::Type{RecoParticleVertexAssociation}) = 0
function RecoParticleVertexAssociation(;weight=0, rec=0, vertex=0)
    RecoParticleVertexAssociation(-1, weight, rec, vertex)
end

"""
struct RecDqdx

    Description: dN/dx or dE/dx info of Track.
    Author: Wenxing Fang, IHEP
"""
struct RecDqdx <: POD
    index::ObjectID{RecDqdx}         # ObjectID of himself

    #---Data Members
    dQdx::Quantity                   # the reconstructed dEdx or dNdx and its error
    particleType::Int16              # particle type, e(0),mu(1),pi(2),K(3),p(4).
    type::Int16                      # type.
    hypotheses::SVector{5,Hypothesis}  # 5 particle hypothesis

    #---OneToOneRelations
    track_idx::ObjectID{Track}       # the corresponding track.
end

relations(::Type{RecDqdx}) = 0
function RecDqdx(;dQdx=Quantity(), particleType=0, type=0, hypotheses=zero(SVector{5,Hypothesis}), track=0)
    RecDqdx(-1, dQdx, particleType, type, hypotheses, track)
end

"""
struct TrackerHitPlane

    Description: Tracker hit plane
    Author: Placido Fernandez Declara, CERN
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
end

relations(::Type{TrackerHitPlane}) = 0
function TrackerHitPlane(;cellID=0, type=0, quality=0, time=0, eDep=0, eDepError=0, u=Vector2f(), v=Vector2f(), du=0, dv=0, position=Vector3d(), covMatrix=zero(SVector{6,Float32}))
    TrackerHitPlane(-1, cellID, type, quality, time, eDep, eDepError, u, v, du, dv, position, covMatrix)
end

"""
struct SimTrackerHit

    Description: Simulated tracker hit
    Author: F.Gaede, DESY
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

relations(::Type{SimTrackerHit}) = 0
function SimTrackerHit(;cellID=0, EDep=0, time=0, pathLength=0, quality=0, position=Vector3d(), momentum=Vector3f(), mcparticle=0)
    SimTrackerHit(-1, cellID, EDep, time, pathLength, quality, position, momentum, mcparticle)
end

"""
struct MCRecoTrackerHitPlaneAssociation

    Description: Association between a TrackerHitPlane and the corresponding simulated TrackerHit
    Author: Placido Fernandez Declara
"""
struct MCRecoTrackerHitPlaneAssociation <: POD
    index::ObjectID{MCRecoTrackerHitPlaneAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{TrackerHitPlane}  # reference to the reconstructed hit
    sim_idx::ObjectID{SimTrackerHit} # reference to the simulated hit
end

relations(::Type{MCRecoTrackerHitPlaneAssociation}) = 0
function MCRecoTrackerHitPlaneAssociation(;weight=0, rec=0, sim=0)
    MCRecoTrackerHitPlaneAssociation(-1, weight, rec, sim)
end

"""
struct MCRecoTrackerAssociation

    Description: Association between a TrackerHit and the corresponding simulated TrackerHit
    Author: C. Bernet, B. Hegner
"""
struct MCRecoTrackerAssociation <: POD
    index::ObjectID{MCRecoTrackerAssociation}  # ObjectID of himself

    #---Data Members
    weight::Float32                  # weight of this association

    #---OneToOneRelations
    rec_idx::ObjectID{TrackerHit}    # reference to the reconstructed hit
    sim_idx::ObjectID{SimTrackerHit} # reference to the simulated hit
end

relations(::Type{MCRecoTrackerAssociation}) = 0
function MCRecoTrackerAssociation(;weight=0, rec=0, sim=0)
    MCRecoTrackerAssociation(-1, weight, rec, sim)
end

export ParticleID, TimeSeries, CalorimeterHit, Cluster, MCParticle, SimPrimaryIonizationCluster, MCRecoClusterParticleAssociation, MCRecoCaloParticleAssociation, CaloHitContribution, SimCalorimeterHit, RawTimeSeries, MCRecoCaloAssociation, TrackerPulse, EventHeader, TrackerHit, RawCalorimeterHit, RecIonizationCluster, Vertex, Track, MCRecoTrackParticleAssociation, ReconstructedParticle, MCRecoParticleAssociation, RecoParticleVertexAssociation, RecDqdx, TrackerHitPlane, SimTrackerHit, MCRecoTrackerHitPlaneAssociation, MCRecoTrackerAssociation
