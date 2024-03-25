function StructArray{SimTrackerHit}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{SimTrackerHit}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.EDep,
        sa.time,
        sa.pathLength,
        sa.quality,
        StructArray{Vector3d}(StructArrays.components(sa.position)),
        StructArray{Vector3f}(StructArrays.components(sa.momentum)),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_MCParticle)))),
    )
    return StructArray{SimTrackerHit}(columns)
end

function StructArray{TrackerHitPlane}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{TrackerHitPlane}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.type,
        sa.quality,
        sa.time,
        sa.eDep,
        sa.eDepError,
        StructArray{Vector2f}(StructArrays.components(sa.u)),
        StructArray{Vector2f}(StructArrays.components(sa.v)),
        sa.du,
        sa.dv,
        StructArray{Vector3d}(StructArrays.components(sa.position)),
        sa.covMatrix,
        StructArray{PVector{TrackerHitPlane,ObjectID,1}}((sa.rawHits_begin, sa.rawHits_end, fcollid)),
    )
    return StructArray{TrackerHitPlane}(columns)
end

function StructArray{Track}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.type)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{Track}}((collect(0:len-1),fcollid)),
        sa.type,
        sa.chi2,
        sa.ndf,
        sa.dEdx,
        sa.dEdxError,
        sa.radiusOfInnermostHit,
        StructArray{PVector{Track,Int32,1}}((sa.subDetectorHitNumbers_begin, sa.subDetectorHitNumbers_end, fcollid)),
        StructArray{PVector{Track,TrackState,2}}((sa.trackStates_begin, sa.trackStates_end, fcollid)),
        StructArray{PVector{Track,Quantity,3}}((sa.dxQuantities_begin, sa.dxQuantities_end, fcollid)),
        StructArray{Relation{Track,TrackerHit,1}}((sa.trackerHits_begin, sa.trackerHits_end, fcollid)),
        StructArray{Relation{Track,Track,2}}((sa.tracks_begin, sa.tracks_end, fcollid)),
    )
    return StructArray{Track}(columns)
end

function StructArray{Vertex}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.primary)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{Vertex}}((collect(0:len-1),fcollid)),
        sa.primary,
        sa.chi2,
        sa.probability,
        StructArray{Vector3f}(StructArrays.components(sa.position)),
        sa.covMatrix,
        sa.algorithmType,
        StructArray{PVector{Vertex,Float32,1}}((sa.parameters_begin, sa.parameters_end, fcollid)),
        StructArray{ObjectID{POD}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_associatedParticle)))),
    )
    return StructArray{Vertex}(columns)
end

function StructArray{RecIonizationCluster}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{RecIonizationCluster}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.significance,
        sa.type,
        StructArray{Relation{RecIonizationCluster,TrackerPulse,1}}((sa.trackerPulse_begin, sa.trackerPulse_end, fcollid)),
    )
    return StructArray{RecIonizationCluster}(columns)
end

function StructArray{RawCalorimeterHit}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{RawCalorimeterHit}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.amplitude,
        sa.timeStamp,
    )
    return StructArray{RawCalorimeterHit}(columns)
end

function StructArray{TrackerHit}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{TrackerHit}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.type,
        sa.quality,
        sa.time,
        sa.eDep,
        sa.eDepError,
        StructArray{Vector3d}(StructArrays.components(sa.position)),
        sa.covMatrix,
        StructArray{PVector{TrackerHit,ObjectID,1}}((sa.rawHits_begin, sa.rawHits_end, fcollid)),
    )
    return StructArray{TrackerHit}(columns)
end

function StructArray{EventHeader}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.eventNumber)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{EventHeader}}((collect(0:len-1),fcollid)),
        sa.eventNumber,
        sa.runNumber,
        sa.timeStamp,
        sa.weight,
    )
    return StructArray{EventHeader}(columns)
end

function StructArray{MCRecoTrackParticleAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoTrackParticleAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{Track}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoTrackParticleAssociation}(columns)
end

function StructArray{TrackerPulse}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{TrackerPulse}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.time,
        sa.charge,
        sa.quality,
        sa.covMatrix,
        StructArray{ObjectID{TimeSeries}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_timeSeries)))),
    )
    return StructArray{TrackerPulse}(columns)
end

function StructArray{MCRecoParticleAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoParticleAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{ReconstructedParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoParticleAssociation}(columns)
end

function StructArray{MCRecoCaloAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoCaloAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{CalorimeterHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{SimCalorimeterHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoCaloAssociation}(columns)
end

function StructArray{RawTimeSeries}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{RawTimeSeries}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.quality,
        sa.time,
        sa.charge,
        sa.interval,
        StructArray{PVector{RawTimeSeries,Int32,1}}((sa.adcCounts_begin, sa.adcCounts_end, fcollid)),
    )
    return StructArray{RawTimeSeries}(columns)
end

function StructArray{CaloHitContribution}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.PDG)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{CaloHitContribution}}((collect(0:len-1),fcollid)),
        sa.PDG,
        sa.energy,
        sa.time,
        StructArray{Vector3f}(StructArrays.components(sa.stepPosition)),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_particle)))),
    )
    return StructArray{CaloHitContribution}(columns)
end

function StructArray{MCRecoTrackerHitPlaneAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoTrackerHitPlaneAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{TrackerHitPlane}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{SimTrackerHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoTrackerHitPlaneAssociation}(columns)
end

function StructArray{MCRecoCaloParticleAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoCaloParticleAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{CalorimeterHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoCaloParticleAssociation}(columns)
end

function StructArray{MCParticle}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.PDG)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCParticle}}((collect(0:len-1),fcollid)),
        sa.PDG,
        sa.generatorStatus,
        sa.simulatorStatus,
        sa.charge,
        sa.time,
        sa.mass,
        StructArray{Vector3d}(StructArrays.components(sa.vertex)),
        StructArray{Vector3d}(StructArrays.components(sa.endpoint)),
        StructArray{Vector3d}(StructArrays.components(sa.momentum)),
        StructArray{Vector3d}(StructArrays.components(sa.momentumAtEndpoint)),
        StructArray{Vector3f}(StructArrays.components(sa.spin)),
        StructArray{Vector2i}(StructArrays.components(sa.colorFlow)),
        StructArray{Relation{MCParticle,MCParticle,1}}((sa.parents_begin, sa.parents_end, fcollid)),
        StructArray{Relation{MCParticle,MCParticle,2}}((sa.daughters_begin, sa.daughters_end, fcollid)),
    )
    return StructArray{MCParticle}(columns)
end

function StructArray{ReconstructedParticle}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.type)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{ReconstructedParticle}}((collect(0:len-1),fcollid)),
        sa.type,
        sa.energy,
        StructArray{Vector3f}(StructArrays.components(sa.momentum)),
        StructArray{Vector3f}(StructArrays.components(sa.referencePoint)),
        sa.charge,
        sa.mass,
        sa.goodnessOfPID,
        sa.covMatrix,
        StructArray{Relation{ReconstructedParticle,Cluster,1}}((sa.clusters_begin, sa.clusters_end, fcollid)),
        StructArray{Relation{ReconstructedParticle,Track,2}}((sa.tracks_begin, sa.tracks_end, fcollid)),
        StructArray{Relation{ReconstructedParticle,ReconstructedParticle,3}}((sa.particles_begin, sa.particles_end, fcollid)),
        StructArray{Relation{ReconstructedParticle,ParticleID,4}}((sa.particleIDs_begin, sa.particleIDs_end, fcollid)),
        StructArray{ObjectID{Vertex}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_startVertex)))),
        StructArray{ObjectID{ParticleID}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_particleIDUsed)))),
    )
    return StructArray{ReconstructedParticle}(columns)
end

function StructArray{SimPrimaryIonizationCluster}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{SimPrimaryIonizationCluster}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.time,
        StructArray{Vector3d}(StructArrays.components(sa.position)),
        sa.type,
        StructArray{PVector{SimPrimaryIonizationCluster,UInt64,1}}((sa.electronCellID_begin, sa.electronCellID_end, fcollid)),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,2}}((sa.electronTime_begin, sa.electronTime_end, fcollid)),
        StructArray{PVector{SimPrimaryIonizationCluster,Vector3d,3}}((sa.electronPosition_begin, sa.electronPosition_end, fcollid)),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,4}}((sa.pulseTime_begin, sa.pulseTime_end, fcollid)),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,5}}((sa.pulseAmplitude_begin, sa.pulseAmplitude_end, fcollid)),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_MCParticle)))),
    )
    return StructArray{SimPrimaryIonizationCluster}(columns)
end

function StructArray{SimCalorimeterHit}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{SimCalorimeterHit}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.energy,
        StructArray{Vector3f}(StructArrays.components(sa.position)),
        StructArray{Relation{SimCalorimeterHit,CaloHitContribution,1}}((sa.contributions_begin, sa.contributions_end, fcollid)),
    )
    return StructArray{SimCalorimeterHit}(columns)
end

function StructArray{Cluster}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.type)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{Cluster}}((collect(0:len-1),fcollid)),
        sa.type,
        sa.energy,
        sa.energyError,
        StructArray{Vector3f}(StructArrays.components(sa.position)),
        sa.positionError,
        sa.iTheta,
        sa.phi,
        StructArray{Vector3f}(StructArrays.components(sa.directionError)),
        StructArray{PVector{Cluster,Float32,1}}((sa.shapeParameters_begin, sa.shapeParameters_end, fcollid)),
        StructArray{PVector{Cluster,Float32,2}}((sa.subdetectorEnergies_begin, sa.subdetectorEnergies_end, fcollid)),
        StructArray{Relation{Cluster,Cluster,1}}((sa.clusters_begin, sa.clusters_end, fcollid)),
        StructArray{Relation{Cluster,CalorimeterHit,2}}((sa.hits_begin, sa.hits_end, fcollid)),
        StructArray{Relation{Cluster,ParticleID,3}}((sa.particleIDs_begin, sa.particleIDs_end, fcollid)),
    )
    return StructArray{Cluster}(columns)
end

function StructArray{RecoParticleVertexAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{RecoParticleVertexAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{ReconstructedParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{Vertex}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_vertex)))),
    )
    return StructArray{RecoParticleVertexAssociation}(columns)
end

function StructArray{RecDqdx}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.dQdx)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{RecDqdx}}((collect(0:len-1),fcollid)),
        sa.dQdx,
        sa.particleType,
        sa.type,
        sa.hypotheses,
        StructArray{PVector{RecDqdx,HitLevelData,1}}((sa.hitData_begin, sa.hitData_end, fcollid)),
        StructArray{ObjectID{Track}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_track)))),
    )
    return StructArray{RecDqdx}(columns)
end

function StructArray{CalorimeterHit}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{CalorimeterHit}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.energy,
        sa.energyError,
        sa.time,
        StructArray{Vector3f}(StructArrays.components(sa.position)),
        sa.type,
    )
    return StructArray{CalorimeterHit}(columns)
end

function StructArray{TimeSeries}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.cellID)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{TimeSeries}}((collect(0:len-1),fcollid)),
        sa.cellID,
        sa.time,
        sa.interval,
        StructArray{PVector{TimeSeries,Float32,1}}((sa.amplitude_begin, sa.amplitude_end, fcollid)),
    )
    return StructArray{TimeSeries}(columns)
end

function StructArray{MCRecoTrackerAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoTrackerAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{TrackerHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{SimTrackerHit}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoTrackerAssociation}(columns)
end

function StructArray{ParticleID}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.type)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{ParticleID}}((collect(0:len-1),fcollid)),
        sa.type,
        sa.PDG,
        sa.algorithmType,
        sa.likelihood,
        StructArray{PVector{ParticleID,Float32,1}}((sa.parameters_begin, sa.parameters_end, fcollid)),
    )
    return StructArray{ParticleID}(columns)
end

function StructArray{MCRecoClusterParticleAssociation}(evt::UnROOT.LazyEvent, branch::Symbol, collid = UInt32(0))
    sa = getproperty(evt, branch)
    len = length(sa.weight)
    fcollid = fill(collid,len)
    columns = (StructArray{ObjectID{MCRecoClusterParticleAssociation}}((collect(0:len-1),fcollid)),
        sa.weight,
        StructArray{ObjectID{Cluster}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_rec)))),
        StructArray{ObjectID{MCParticle}}(StructArrays.components(getproperty(evt, Symbol(:_, branch, :_sim)))),
    )
    return StructArray{MCRecoClusterParticleAssociation}(columns)
end

