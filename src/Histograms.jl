module Histograms
    using FHist
    using EDM4hep
    using EDM4hep.SystemOfUnits

    export H1D, H2D, H3D

    const Hist1DType = typeof(Hist1D(binedges=range(0,1,10)))
    const Hist2DType = typeof(Hist2D(binedges=(range(0,1,10),range(0,1,10))))
    const Hist3DType = typeof(Hist3D(binedges=(range(0,1,10),range(0,1,10),range(0,1,10))))

    _getvalue(unit::Symbol) = getfield(EDM4hep.SystemOfUnits, unit)
    _getvalue(units::Tuple{Symbol,Symbol}) = (getfield(EDM4hep.SystemOfUnits, units[1]), getfield(EDM4hep.SystemOfUnits, units[2]))
    _getvalue(units::Tuple{Symbol,Symbol,Symbol}) = (getfield(EDM4hep.SystemOfUnits, units[1]), getfield(EDM4hep.SystemOfUnits, units[2]), getfield(EDM4hep.SystemOfUnits, units[3]))

    """
    H1D(title::String, nbins::Int, min::Float, max::Float, unit::Symbol)
        Create a 1-dimensional histogram carrying the title and units.
    """
    struct H1D
        title::String
        hist::Hist1DType
        usym::Symbol
        uval::Float64
        H1D(title, nbins, min, max; unit=:nounit) = new(title, Hist1D(Float64; binedges=range(min,max,nbins+1), overflow=false), unit, _getvalue(unit))
    end
    
    Base.push!(h::H1D, v, w=1) = atomic_push!(h.hist, v/h.uval, w)
    Base.merge!(h1::H1D, h2::H1D) = merge!(h1.hist, h2.hist)
    Base.empty!(h1::H1D) = empty!(h1.hist)

    """
    H2D(title::String, xbins::Int, xmin::Float, xmax::Float, ybins::Int, ymin::Float, ymax::Float, unit::Tuple{Symbol,Symbol})
        Create a 2-dimensional histogram carrying the title and units.
    """
    struct H2D
        title::String
        hist::Hist2DType
        unit::Tuple{Symbol,Symbol}
        uval::Tuple{Float64,Float64}
        H2D(title, xbins, xmin, xmax, ybins, ymin, ymax; units=(:nounit, :nounit)) = new(title, Hist2D(Float64;binedges=(range(xmin,xmax,xbins+1), range(ymin,ymax, ybins+1)), overflow=true), units, _getvalue(units))
    end

    Base.push!(h::H2D, u, v, w=1) = atomic_push!(h.hist, u/h.uval[1], v/h.uval[2], w)
    Base.merge!(h1::H2D, h2::H2D) = merge!(h1.hist, h2.hist) 
    Base.empty!(h1::H2D) = empty!(h1.hist)

    """
    H3D(title::String, xbins::Int, xmin::Float, xmax::Float, ybins::Int, ymin::Float, ymax::Float, zbins::Int, zmin::Float, zmax::Float, unit::Tuple{Symbol,Symbol,Symbol})
        Create a 2-dimensional histogram carrying the title and units.
    """
    struct H3D
        title::String
        hist::Hist3DType
        unit::Tuple{Symbol,Symbol,Symbol}
        uval::Tuple{Float64,Float64,Float64}
        H3D(title, xbins, xmin, xmax, ybins, ymin, ymax, zbins, zmin, zmax; units=(:nounit, :nounit, :nounit)) = 
            new(title, Hist3D(Float64;binedges=(range(xmin,xmax,xbins+1), range(ymin,ymax, ybins+1), range(zmin,zmax, zbins+1)), overflow=true), units, _getvalue(units))
    end

    Base.push!(h::H3D, x, y, z, w=1) = atomic_push!(h.hist, x/h.uval[1], y/h.uval[2], z/h.uval[3], w)
    Base.merge!(h1::H3D, h2::H3D) = merge!(h1.hist, h2.hist) 
    Base.empty!(h1::H3D) = empty!(h1.hist)

end