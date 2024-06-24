include("../podio/genInterfaces.jl")
include("../podio/genDatatypes.jl")

#--------------------------------------------------------------------------------------------------
#----Utility functions for MCParticle--------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
export add_daughter, add_parent, set_parameters

function add_daughter(p::MCParticle, d::MCParticle)
    iszero(d.index) && (d = register(d))
    p = pushToDaughters(p, d)
    d = pushToParents(d, p)
    p,d
end

function add_parent(d::MCParticle, p::MCParticle)
    iszero(p.index) && (p = register(p))
    d = pushToParents(d, p)
    p = pushToDaughters(p, d)
    d,p
end

function Base.getproperty(obj::MCParticle, sym::Symbol)
    if sym == :energy
        m = obj.momentum
        sqrt(m.x^2 + m.y^2 + m.z^2 + obj.mass^2)
    elseif sym == :name
        pdg = getfield(obj,:PDG)
        try
            Particle(pdg).name
        catch
            "PDG[$pdg]"
        end
    else # fallback to getfield
        return getfield(obj, sym)
    end
end

#--------------------------------------------------------------------------------------------------
#----Utility functions for ReconstructedParticle---------------------------------------------------
#--------------------------------------------------------------------------------------------------
export pₜ
pₜ( o::ReconstructedParticle) = √(o.momentum.x^2 + o.momentum.y^2)

