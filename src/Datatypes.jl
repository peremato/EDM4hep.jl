
include("../podio/genDatatypes.jl")

#--------------------------------------------------------------------------------------------------
#----Utility functions for MCParticle--------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
export add_daughter, add_parent, set_parameters

function add_daughter(p::MCParticle, d::MCParticle)
    iszero(p.index) && (p = register(p))
    iszero(d.index) && (d = register(d))
    p = @set p.daughters = push(p.daughters, d) # this creates a new MCParticle
    d = @set d.parents = push(d.parents, p)     # this creates a new MCParticle
    update(d)
    update(p)
    (p,d)
end

function add_parent(d::MCParticle, p::MCParticle)
    iszero(d.index) && (d = register(d))
    iszero(p.index) && (p = register(p))
    d = @set d.parents = push(d.parents, p)     # this creates a new MCParticle
    p = @set p.daughters = push(p.daughters, d) # this creates a new MCParticle
    update(p)
    update(d)
    (d, p)
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
#----Utility functions for ParticleID--------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

function set_parameters(o::ParticleID, v::AbstractVector{Float32})
    iszero(o.index) && (o = register(o))
    o = @set o.parameters = v
    update(o)
end
