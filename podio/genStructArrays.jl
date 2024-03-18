function StructArray{SimTrackerHit, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{SimTrackerHit}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_EDep)),
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_pathLength)),
        getproperty(evt, Symbol(bname, :_quality)),
        StructArray{Vector3d, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{Vector3f, Symbol(bname, :_momentum)}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_MCParticle") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{SimTrackerHit}(columns)
end

function StructArray{TrackerHitPlane, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{TrackerHitPlane}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_type)),
        getproperty(evt, Symbol(bname, :_quality)),
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_eDep)),
        getproperty(evt, Symbol(bname, :_eDepError)),
        StructArray{Vector2f, Symbol(bname, :_u)}(evt, collid, len),
        StructArray{Vector2f, Symbol(bname, :_v)}(evt, collid, len),
        getproperty(evt, Symbol(bname, :_du)),
        getproperty(evt, Symbol(bname, :_dv)),
        StructArray{Vector3d, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{SVector{6,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[6]")), 6, len);dims=1),
        StructArray{PVector{TrackerHitPlane,ObjectID,1}, Symbol(bname, :_rawHits)}(evt, collid, len),
    )
    return StructArray{TrackerHitPlane}(columns)
end

function StructArray{Track, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_type))
    len = length(firstmem)
    columns = (StructArray{ObjectID{Track}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_chi2)),
        getproperty(evt, Symbol(bname, :_ndf)),
        getproperty(evt, Symbol(bname, :_dEdx)),
        getproperty(evt, Symbol(bname, :_dEdxError)),
        getproperty(evt, Symbol(bname, :_radiusOfInnermostHit)),
        StructArray{PVector{Track,Int32,1}, Symbol(bname, :_subDetectorHitNumbers)}(evt, collid, len),
        StructArray{PVector{Track,TrackState,2}, Symbol(bname, :_trackStates)}(evt, collid, len),
        StructArray{PVector{Track,Quantity,3}, Symbol(bname, :_dxQuantities)}(evt, collid, len),
        StructArray{Relation{Track,TrackerHit,1}, Symbol(bname, :_trackerHits)}(evt, collid, len),
        StructArray{Relation{Track,Track,2}, Symbol(bname, :_tracks)}(evt, collid, len),
    )
    return StructArray{Track}(columns)
end

function StructArray{Vertex, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_primary))
    len = length(firstmem)
    columns = (StructArray{ObjectID{Vertex}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_chi2)),
        getproperty(evt, Symbol(bname, :_probability)),
        StructArray{Vector3f, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{SVector{6,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[6]")), 6, len);dims=1),
        getproperty(evt, Symbol(bname, :_algorithmType)),
        StructArray{PVector{Vertex,Float32,1}, Symbol(bname, :_parameters)}(evt, collid, len),
        StructArray{ObjectID{POD}, isnewpodio() ? Symbol(:_, bname, "_associatedParticle") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{Vertex}(columns)
end

function StructArray{RecIonizationCluster, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{RecIonizationCluster}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_significance)),
        getproperty(evt, Symbol(bname, :_type)),
        StructArray{Relation{RecIonizationCluster,TrackerPulse,1}, Symbol(bname, :_trackerPulse)}(evt, collid, len),
    )
    return StructArray{RecIonizationCluster}(columns)
end

function StructArray{RawCalorimeterHit, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{RawCalorimeterHit}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_amplitude)),
        getproperty(evt, Symbol(bname, :_timeStamp)),
    )
    return StructArray{RawCalorimeterHit}(columns)
end

function StructArray{TrackerHit, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{TrackerHit}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_type)),
        getproperty(evt, Symbol(bname, :_quality)),
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_eDep)),
        getproperty(evt, Symbol(bname, :_eDepError)),
        StructArray{Vector3d, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{SVector{6,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[6]")), 6, len);dims=1),
        StructArray{PVector{TrackerHit,ObjectID,1}, Symbol(bname, :_rawHits)}(evt, collid, len),
    )
    return StructArray{TrackerHit}(columns)
end

function StructArray{EventHeader, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_eventNumber))
    len = length(firstmem)
    columns = (StructArray{ObjectID{EventHeader}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_runNumber)),
        getproperty(evt, Symbol(bname, :_timeStamp)),
        getproperty(evt, Symbol(bname, :_weight)),
    )
    return StructArray{EventHeader}(columns)
end

function StructArray{MCRecoTrackParticleAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoTrackParticleAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{Track}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoTrackParticleAssociation}(columns)
end

function StructArray{TrackerPulse, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{TrackerPulse}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_charge)),
        getproperty(evt, Symbol(bname, :_quality)),
        StructArray{SVector{3,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[3]")), 3, len);dims=1),
        StructArray{ObjectID{TimeSeries}, isnewpodio() ? Symbol(:_, bname, "_timeSeries") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{TrackerPulse}(columns)
end

function StructArray{MCRecoParticleAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoParticleAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{ReconstructedParticle}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoParticleAssociation}(columns)
end

function StructArray{MCRecoCaloAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoCaloAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{CalorimeterHit}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{SimCalorimeterHit}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoCaloAssociation}(columns)
end

function StructArray{RawTimeSeries, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{RawTimeSeries}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_quality)),
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_charge)),
        getproperty(evt, Symbol(bname, :_interval)),
        StructArray{PVector{RawTimeSeries,Int32,1}, Symbol(bname, :_adcCounts)}(evt, collid, len),
    )
    return StructArray{RawTimeSeries}(columns)
end

function StructArray{CaloHitContribution, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_PDG))
    len = length(firstmem)
    columns = (StructArray{ObjectID{CaloHitContribution}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_energy)),
        getproperty(evt, Symbol(bname, :_time)),
        StructArray{Vector3f, Symbol(bname, :_stepPosition)}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_particle") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{CaloHitContribution}(columns)
end

function StructArray{MCRecoTrackerHitPlaneAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoTrackerHitPlaneAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{TrackerHitPlane}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{SimTrackerHit}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoTrackerHitPlaneAssociation}(columns)
end

function StructArray{MCRecoCaloParticleAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoCaloParticleAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{CalorimeterHit}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoCaloParticleAssociation}(columns)
end

function StructArray{MCParticle, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_PDG))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCParticle}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_generatorStatus)),
        getproperty(evt, Symbol(bname, :_simulatorStatus)),
        getproperty(evt, Symbol(bname, :_charge)),
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_mass)),
        StructArray{Vector3d, Symbol(bname, :_vertex)}(evt, collid, len),
        StructArray{Vector3d, Symbol(bname, :_endpoint)}(evt, collid, len),
        StructArray{Vector3d, Symbol(bname, :_momentum)}(evt, collid, len),
        StructArray{Vector3d, Symbol(bname, :_momentumAtEndpoint)}(evt, collid, len),
        StructArray{Vector3f, Symbol(bname, :_spin)}(evt, collid, len),
        StructArray{Vector2i, Symbol(bname, :_colorFlow)}(evt, collid, len),
        StructArray{Relation{MCParticle,MCParticle,1}, Symbol(bname, :_parents)}(evt, collid, len),
        StructArray{Relation{MCParticle,MCParticle,2}, Symbol(bname, :_daughters)}(evt, collid, len),
    )
    return StructArray{MCParticle}(columns)
end

function StructArray{ReconstructedParticle, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_type))
    len = length(firstmem)
    columns = (StructArray{ObjectID{ReconstructedParticle}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_energy)),
        StructArray{Vector3f, Symbol(bname, :_momentum)}(evt, collid, len),
        StructArray{Vector3f, Symbol(bname, :_referencePoint)}(evt, collid, len),
        getproperty(evt, Symbol(bname, :_charge)),
        getproperty(evt, Symbol(bname, :_mass)),
        getproperty(evt, Symbol(bname, :_goodnessOfPID)),
        StructArray{SVector{10,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[10]")), 10, len);dims=1),
        StructArray{Relation{ReconstructedParticle,Cluster,1}, Symbol(bname, :_clusters)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,Track,2}, Symbol(bname, :_tracks)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,ReconstructedParticle,3}, Symbol(bname, :_particles)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,ParticleID,4}, Symbol(bname, :_particleIDs)}(evt, collid, len),
        StructArray{ObjectID{Vertex}, isnewpodio() ? Symbol(:_, bname, "_startVertex") : Symbol(bname, "#4")}(evt, collid, len),
        StructArray{ObjectID{ParticleID}, isnewpodio() ? Symbol(:_, bname, "_particleIDUsed") : Symbol(bname, "#5")}(evt, collid, len),
    )
    return StructArray{ReconstructedParticle}(columns)
end

function StructArray{SimPrimaryIonizationCluster, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{SimPrimaryIonizationCluster}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_time)),
        StructArray{Vector3d, Symbol(bname, :_position)}(evt, collid, len),
        getproperty(evt, Symbol(bname, :_type)),
        StructArray{PVector{SimPrimaryIonizationCluster,UInt64,1}, Symbol(bname, :_electronCellID)}(evt, collid, len),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,2}, Symbol(bname, :_electronTime)}(evt, collid, len),
        StructArray{PVector{SimPrimaryIonizationCluster,Vector3d,3}, Symbol(bname, :_electronPosition)}(evt, collid, len),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,4}, Symbol(bname, :_pulseTime)}(evt, collid, len),
        StructArray{PVector{SimPrimaryIonizationCluster,Float32,5}, Symbol(bname, :_pulseAmplitude)}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_MCParticle") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{SimPrimaryIonizationCluster}(columns)
end

function StructArray{SimCalorimeterHit, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{SimCalorimeterHit}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_energy)),
        StructArray{Vector3f, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{Relation{SimCalorimeterHit,CaloHitContribution,1}, Symbol(bname, :_contributions)}(evt, collid, len),
    )
    return StructArray{SimCalorimeterHit}(columns)
end

function StructArray{Cluster, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_type))
    len = length(firstmem)
    columns = (StructArray{ObjectID{Cluster}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_energy)),
        getproperty(evt, Symbol(bname, :_energyError)),
        StructArray{Vector3f, Symbol(bname, :_position)}(evt, collid, len),
        StructArray{SVector{6,Float32}}(reshape(getproperty(evt, Symbol(bname, "_positionError[6]")), 6, len);dims=1),
        getproperty(evt, Symbol(bname, :_iTheta)),
        getproperty(evt, Symbol(bname, :_phi)),
        StructArray{Vector3f, Symbol(bname, :_directionError)}(evt, collid, len),
        StructArray{PVector{Cluster,Float32,1}, Symbol(bname, :_shapeParameters)}(evt, collid, len),
        StructArray{PVector{Cluster,Float32,2}, Symbol(bname, :_subdetectorEnergies)}(evt, collid, len),
        StructArray{Relation{Cluster,Cluster,1}, Symbol(bname, :_clusters)}(evt, collid, len),
        StructArray{Relation{Cluster,CalorimeterHit,2}, Symbol(bname, :_hits)}(evt, collid, len),
        StructArray{Relation{Cluster,ParticleID,3}, Symbol(bname, :_particleIDs)}(evt, collid, len),
    )
    return StructArray{Cluster}(columns)
end

function StructArray{RecoParticleVertexAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{RecoParticleVertexAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{ReconstructedParticle}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{Vertex}, isnewpodio() ? Symbol(:_, bname, "_vertex") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{RecoParticleVertexAssociation}(columns)
end

function StructArray{RecDqdx, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_dQdx))
    len = length(firstmem)
    columns = (StructArray{ObjectID{RecDqdx}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_particleType)),
        getproperty(evt, Symbol(bname, :_type)),
        StructArray{SVector{5,Hypothesis}}(reshape(getproperty(evt, Symbol(bname, "_hypotheses[5]")), 5, len);dims=1),
        StructArray{PVector{RecDqdx,HitLevelData,1}, Symbol(bname, :_hitData)}(evt, collid, len),
        StructArray{ObjectID{Track}, isnewpodio() ? Symbol(:_, bname, "_track") : Symbol(bname, "#0")}(evt, collid, len),
    )
    return StructArray{RecDqdx}(columns)
end

function StructArray{CalorimeterHit, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{CalorimeterHit}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_energy)),
        getproperty(evt, Symbol(bname, :_energyError)),
        getproperty(evt, Symbol(bname, :_time)),
        StructArray{Vector3f, Symbol(bname, :_position)}(evt, collid, len),
        getproperty(evt, Symbol(bname, :_type)),
    )
    return StructArray{CalorimeterHit}(columns)
end

function StructArray{TimeSeries, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_cellID))
    len = length(firstmem)
    columns = (StructArray{ObjectID{TimeSeries}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_time)),
        getproperty(evt, Symbol(bname, :_interval)),
        StructArray{PVector{TimeSeries,Float32,1}, Symbol(bname, :_amplitude)}(evt, collid, len),
    )
    return StructArray{TimeSeries}(columns)
end

function StructArray{MCRecoTrackerAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoTrackerAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{TrackerHit}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{SimTrackerHit}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoTrackerAssociation}(columns)
end

function StructArray{ParticleID, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_type))
    len = length(firstmem)
    columns = (StructArray{ObjectID{ParticleID}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        getproperty(evt, Symbol(bname, :_PDG)),
        getproperty(evt, Symbol(bname, :_algorithmType)),
        getproperty(evt, Symbol(bname, :_likelihood)),
        StructArray{PVector{ParticleID,Float32,1}, Symbol(bname, :_parameters)}(evt, collid, len),
    )
    return StructArray{ParticleID}(columns)
end

function StructArray{MCRecoClusterParticleAssociation, bname}(evt::UnROOT.LazyEvent, collid = UInt32(0), len = -1) where bname
    firstmem = getproperty(evt, Symbol(bname, :_weight))
    len = length(firstmem)
    columns = (StructArray{ObjectID{MCRecoClusterParticleAssociation}}((collect(0:len-1),fill(collid,len))),
        firstmem,
        StructArray{ObjectID{Cluster}, isnewpodio() ? Symbol(:_, bname, "_rec") : Symbol(bname, "#0")}(evt, collid, len),
        StructArray{ObjectID{MCParticle}, isnewpodio() ? Symbol(:_, bname, "_sim") : Symbol(bname, "#1")}(evt, collid, len),
    )
    return StructArray{MCRecoClusterParticleAssociation}(columns)
end

