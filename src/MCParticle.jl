"""
    Description: "The Monte Carlo particle - based on the lcio::MCParticle."
    Author: "F.Gaede, DESY"
"""
struct MCParticle <: POD
    index::Index{MCParticle}
    #  Members
    PDG::Int32                         # PDG code of the particle
    generatorStatus::Int32             # status of the particle as defined by the generator
    simulatorStatus::Int32             # status of the particle from the simulation program - use BIT constants below
    charge::Float32                    # particle charge
    time::Float32                      # creation time of the particle in [ns] wrt. the event, e.g. for preassigned decays or decays in flight from the simulator.
    mass::Float64                      # mass of the particle in [GeV]
    vertex::Vector3d                   # production vertex of the particle in [mm].
    endpoint::Vector3d                 # endpoint of the particle in [mm]
    momentum::Vector3f                 # particle 3-momentum at the production vertex in [GeV]
    momentumAtEndpoint::Vector3f       # particle 3-momentum at the endpoint in [GeV]
    spin::Vector3f                     # spin (helicity) vector of the particle.
    colorFlow::Vector2i                # color flow as defined by the generator
    # OneToManyRelations
    parents::Relation{MCParticle}      #  The parents of this particle
    daughters::Relation{MCParticle}    #  The daughters this particle
end

function MCParticle(;PDG=0, generatorStatus=0, simulatorStatus=0, charge=0, time=0, mass=0,
                    vertex=Vector3d(), endpoint=Vector3d(), momentum=Vector3f(), momentumAtEndpoint=Vector3f(),
                    spin=Vector3f(), colorFlow=Vector2i(), parents=Relation{MCParticle}(), daughters=Relation{MCParticle}())
    MCParticle(0, PDG,generatorStatus, simulatorStatus, charge, time, mass, vertex, endpoint, momentum, momentumAtEndpoint, spin, colorFlow, 
            parents, daughters)
end

#---Event Data Store (defining the containers for objects and relations)-----------------------
const mcparticle_objects = MCParticle[]
const mcparticle_relations = Index{MCParticle}[]

function EDStore_objects(::MCParticle)
    global mcparticle_objects
    mcparticle_objects
end
function EDStore_objects(::Index{MCParticle})
    global mcparticle_objects
    mcparticle_objects
end
function EDStore_relations(::Relation{MCParticle})
    global mcparticle_relations
    mcparticle_relations
end

#----Utility functions for MCParticle----------------------------------------------------------
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
#---Exports for MCParticle--------------------------------------------------------------------
export MCParticle, add_daughter, add_parent
