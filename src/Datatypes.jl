using StructArrays

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

function Base.getproperty(obj::StructArray{MCParticle}, sym::Symbol)
    sym === :energy && return getproperty.(obj, :energy)
    sym === :name && return getproperty.(obj, :name)
    StructArrays.component(obj, sym)
end

#--------------------------------------------------------------------------------------------------
#----Utility functions for ReconstructedParticle---------------------------------------------------
#--------------------------------------------------------------------------------------------------
export pₜ, theta
pₜ( o::ReconstructedParticle) = √(o.momentum.x^2 + o.momentum.y^2)
θ(p::ReconstructedParticle) = atan(√(p.momentum.x^2+p.momentum.y^2), p.momentum.z)
ϕ(p::ReconstructedParticle) = atan(p.momentum.y, p.momentum.x)