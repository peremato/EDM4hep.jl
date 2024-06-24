"""
Tracker hit interface class
- Author: Thomas Madlener, DESY
# Fields
- `cellID::UInt64`:  ID of the sensor that created this hit 
- `type::Int32`:  type of the raw data hit 
- `quality::Int32`:  quality bit flag of the hit 
- `time::Float32`:  time of the hit [ns]
- `eDep::Float32`:  energy deposited on the hit [GeV]
- `eDepError::Float32`:  error measured on eDep [GeV]
- `position::Vector3d`:  hit position [mm]
"""
abstract type TrackerHit <: POD
end

export TrackerHit
