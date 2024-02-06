"""
HitLevelData
# Fields
- `cellID::UInt64`: cell id
- `N::UInt32`: number of reconstructed ionization cluster.
- `eDep::Float32`: reconstructed energy deposit [GeV].
- `pathLength::Float32`: track path length [mm].
"""
struct HitLevelData <: POD
    cellID::UInt64                   # cell id
    N::UInt32                        # number of reconstructed ionization cluster.
    eDep::Float32                    # reconstructed energy deposit [GeV].
    pathLength::Float32              # track path length [mm].
    HitLevelData(cellID=0, N=0, eDep=0, pathLength=0) = new(cellID, N, eDep, pathLength)
end

"""
Vector3d
# Fields
- `x::Float64`: 
- `y::Float64`: 
- `z::Float64`: 
"""
struct Vector3d <: POD
    x::Float64                       
    y::Float64                       
    z::Float64                       
    Vector3d(x=0, y=0, z=0) = new(x, y, z)
end

"""
Quantity
# Fields
- `type::Int16`: flag identifying how to interpret the quantity
- `value::Float32`: value of the quantity
- `error::Float32`: error on the value of the quantity
"""
struct Quantity <: POD
    type::Int16                      # flag identifying how to interpret the quantity
    value::Float32                   # value of the quantity
    error::Float32                   # error on the value of the quantity
    Quantity(type=0, value=0, error=0) = new(type, value, error)
end

"""
Vector3f
# Fields
- `x::Float32`: 
- `y::Float32`: 
- `z::Float32`: 
"""
struct Vector3f <: POD
    x::Float32                       
    y::Float32                       
    z::Float32                       
    Vector3f(x=0, y=0, z=0) = new(x, y, z)
end

"""
TrackState
# Fields
- `location::Int32`: for use with At{Other|IP|FirstHit|LastHit|Calorimeter|Vertex}|LastLocation
- `D0::Float32`: transverse impact parameter
- `phi::Float32`: azimuthal angle
- `omega::Float32`: is the signed curvature of the track in [1/mm].
- `Z0::Float32`: longitudinal impact parameter
- `tanLambda::Float32`: lambda is the dip angle of the track in r-z
- `time::Float32`: time of the track at this trackstate
- `referencePoint::Vector3f`: Reference point of the track parameters, e.g. the origin at the IP, or the position  of the first/last hits or the entry point into the calorimeter. [mm]
- `covMatrix::SVector{21,Float32}`: lower triangular covariance matrix of the track parameters.  the order of parameters is  d0, phi, omega, z0, tan(lambda), time. the array is a row-major flattening of the matrix.
"""
struct TrackState <: POD
    location::Int32                  # for use with At{Other|IP|FirstHit|LastHit|Calorimeter|Vertex}|LastLocation
    D0::Float32                      # transverse impact parameter
    phi::Float32                     # azimuthal angle
    omega::Float32                   # is the signed curvature of the track in [1/mm].
    Z0::Float32                      # longitudinal impact parameter
    tanLambda::Float32               # lambda is the dip angle of the track in r-z
    time::Float32                    # time of the track at this trackstate
    referencePoint::Vector3f         # Reference point of the track parameters, e.g. the origin at the IP, or the position  of the first/last hits or the entry point into the calorimeter. [mm]
    covMatrix::SVector{21,Float32}   # lower triangular covariance matrix of the track parameters.  the order of parameters is  d0, phi, omega, z0, tan(lambda), time. the array is a row-major flattening of the matrix.
    TrackState(location=0, D0=0, phi=0, omega=0, Z0=0, tanLambda=0, time=0, referencePoint=0, covMatrix=0) = new(location, D0, phi, omega, Z0, tanLambda, time, referencePoint, covMatrix)
end

"""
Hypothesis
# Fields
- `chi2::Float32`: chi2
- `expected::Float32`: expected value
- `sigma::Float32`: sigma value
"""
struct Hypothesis <: POD
    chi2::Float32                    # chi2
    expected::Float32                # expected value
    sigma::Float32                   # sigma value
    Hypothesis(chi2=0, expected=0, sigma=0) = new(chi2, expected, sigma)
end

"""
Vector2i
# Fields
- `a::Int32`: 
- `b::Int32`: 
"""
struct Vector2i <: POD
    a::Int32                         
    b::Int32                         
    Vector2i(a=0, b=0) = new(a, b)
end

"""
Generic vector for storing classical 4D coordinates in memory. Four momentum helper functions are in edm4hep::utils
# Fields
- `x::Float32`: 
- `y::Float32`: 
- `z::Float32`: 
- `t::Float32`: 
"""
struct Vector4f <: POD
    x::Float32                       
    y::Float32                       
    z::Float32                       
    t::Float32                       
    Vector4f(x=0, y=0, z=0, t=0) = new(x, y, z, t)
end

"""
Vector2f
# Fields
- `a::Float32`: 
- `b::Float32`: 
"""
struct Vector2f <: POD
    a::Float32                       
    b::Float32                       
    Vector2f(a=0, b=0) = new(a, b)
end

export HitLevelData, Vector3d, Quantity, Vector3f, TrackState, Hypothesis, Vector2i, Vector4f, Vector2f
