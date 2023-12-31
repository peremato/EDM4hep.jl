"""
    Vector3d
"""
struct Vector3d
    x::Float64                       
    y::Float64                       
    z::Float64                       
    Vector3d(x=0, y=0, z=0) = new(x, y, z)
end

"""
    Quantity
"""
struct Quantity
    type::Int16                      # flag identifying how to interpret the quantity
    value::Float32                   # value of the quantity
    error::Float32                   # error on the value of the quantity
    Quantity(type=0, value=0, error=0) = new(type, value, error)
end

"""
    Vector3f
"""
struct Vector3f
    x::Float32                       
    y::Float32                       
    z::Float32                       
    Vector3f(x=0, y=0, z=0) = new(x, y, z)
end

"""
    TrackState
"""
struct TrackState
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
"""
struct Hypothesis
    chi2::Float32                    # chi2
    expected::Float32                # expected value
    sigma::Float32                   # sigma value
    Hypothesis(chi2=0, expected=0, sigma=0) = new(chi2, expected, sigma)
end

"""
    Vector2i
"""
struct Vector2i
    a::Int32                         
    b::Int32                         
    Vector2i(a=0, b=0) = new(a, b)
end

"""
    HitLevelData
"""
struct HitLevelData
    cellID::UInt64                   # cell id
    N::UInt32                        # number of reconstructed ionization cluster.
    eDep::Float32                    # reconstructed energy deposit [GeV].
    pathLength::Float32              # track path length [mm].
    HitLevelData(cellID=0, N=0, eDep=0, pathLength=0) = new(cellID, N, eDep, pathLength)
end

"""
    Vector2f
"""
struct Vector2f
    a::Float32                       
    b::Float32                       
    Vector2f(a=0, b=0) = new(a, b)
end

export Vector3d, Quantity, Vector3f, TrackState, Hypothesis, Vector2i, HitLevelData, Vector2f
