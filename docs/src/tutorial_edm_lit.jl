# # EDM4hep.jl EDM Tutorial
# This tutorial shows how to use the EDM4hep Julia types to create data models in memory.
#
#md # !!! note "Note that"
#md #     You can also download this tutorial as a
#md #     [Jupyter notebook](tutorial_edm.ipynb) and a plain
#md #     [Julia source file](tutorial_edm.jl).
#
#md # #### Table of contents
#md # ```@contents
#md # Pages = ["tutorial_edm.md"]
#md # Depth = 2:3
#md # ```
#
#
# #### Loading the necessary modules
# - We will use the `EDM4hep` module that defines all the EDM4hep types and its relations and links.
# - We will use the [`PYTHIA8`](https://juliahep.github.io/PYTHIA8.jl/stable/) module to generate realistic MC Particles
# - We will use the [`Corpuscles`](https://juliaphysics.github.io/Corpuscles.jl/stable/) module to access the properties of the particles
# - We will use the [`FHist`](https://juliaphysics.github.io/FHist.jl/stable/) module to create histograms
# - We will use the [`Plots`](https://docs.juliaplots.org/stable/) module to plot the histograms
# If these modules are not installed, you can install them by running the following commands:
# ```julia
# using Pkg
# Pkg.add("EDM4hep")
# Pkg.add("PYTHIA8")
# Pkg.add("FHist")
# Pkg.add("Plots")
# ```
using EDM4hep
using PYTHIA8
using Corpuscles: hascharm, hasstrange, ismeson, isbaryon
using FHist
using Plots: plot, plot!, theme
#md import DisplayAs: PNG #hide

# ## Create a collection of MCParticles in memory
# We will create a collection of MCParticles explicitly
p1 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, 7000.0), generatorStatus=3);
p2 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, -7000.0), generatorStatus=3);
# The particles `p1` and `p2` are the initial protons in the event.

# ### Accessing the properties of the MCParticles
# You can access the properties of the particles as follows:
println("Particle p1 has PDG=$(p1.PDG), mass=$(p1.mass), momentum=$(p1.momentum), and generatorStatus=$(p1.generatorStatus)")
println("Particle p2 has PDG=$(p2.PDG), mass=$(p2.mass), momentum=$(p2.momentum), and generatorStatus=$(p2.generatorStatus)")
# The names of the particles can be accessed using the `name` property (added to MCParticle)
println("Particle p1 has name=$(p1.name)")
println("Particle p2 has name=$(p2.name)")
# The energy of the particles can be accessed using the `energy` property (added to MCParticle)
println("Particle p1 has energy=$(p1.energy)")
println("Particle p2 has energy=$(p2.energy)")

# You can see the full documentation of the `MCParticle` type to see all the available properties 
# by executing the command `?MCParticle` or using the `@doc` macro as follows:
# ```julia
# @doc MCParticle 
# ```

# ### Modifying the properties of the MCParticles
#md # !!! note "Note that"
#md #     EDM4hep data types are immutable, so we can not change the properties of the particles directly. 
#md #     To change the properties of a `MCParticle`, for example, we need to create a new instance with the desired properties.
#md #     This can be achieved by using the `@set` macro that will return a new instance with all untouched attributes 
#md #     plus the modified one.

# For example the following line will raise an error
try
    p1.time = 1.1
catch e
    println(e)
end
# To change the time property of the particle `p1` we can use the `@set` macro as follows:
p1 = @set p1.time = 1.1;
# Now we can access the new property
println("Particle p1 has time = $(p1.time)")

# ### Create a tree of MCParticles
# We will create a tree of MCParticles by adding daughters and parents to the particles
p3 = MCParticle(PDG=1, mass=0.0, momentum=(0.750, -1.569, 32.191), generatorStatus=3)
p3, p1 = add_parent(p3, p1)
#md # !!! note "Note that"
#md #     The `add_parent` function returns new instances with the related `MCParticle` objects since they have been modified.
#md #     The same applies to the `add_daughter` function.
# Lets add more particles to the tree
p4 = MCParticle(PDG=-2, mass=0.0, momentum=(-3.047, -19.000, -54.629), generatorStatus=3)
p4, p2 = add_parent(p4, p2)

p5 = MCParticle(PDG=-24, mass=80.799, momentum=(1.517, -20.68, -20.605), generatorStatus=3)
p5, p1 = add_parent(p5, p1)
p5, p2 = add_parent(p5, p2)

p6 = MCParticle(PDG=22, mass=0.0, momentum=(-3.813, 0.113, -1.833), generatorStatus=1)
p6, p1 = add_parent(p6, p1)
p6, p2 = add_parent(p6, p2)

p7 = MCParticle(PDG=1, mass=0.0, momentum=(-2.445, 28.816, 6.082), generatorStatus=1)
p7, p5 = add_parent(p7, p5)

p8 = MCParticle(PDG=-2, mass=0.0, momentum=(3.962, -49.498, -26.687), generatorStatus=1)
p8, p5 = add_parent(p8, p5)

# ### Iterate over the particles
# Now that we have constructed the tree in memory, we can iterate over the particles, daughters and parents
# The function `getEDCollection` returns the collection of particles (`EDCollection{MCParticle}`). The one-to-many relations
# are stored in the `daughters` and `parents` properties of the `MCParticle` type. They can be iterated as follows:
for p in getEDCollection(MCParticle)
    println("MCParticle $(p.index) with PDG=$(p.PDG) and momentum $(p.momentum) has $(length(p.daughters)) daughters")
    for d in p.daughters
        println("   ---> $(d.index) with PDG=$(d.PDG) and momentum $(d.momentum)")
    end
end

# ### One-to-one relations
# The type `SimTrackerHit` has a one-to-one relation with the type `MCParticle`. Lets create a hit and associate it to a 
# particle in the tree. We use the keyword argument `particle` to associate the hit to the particle, like this: 
hit = SimTrackerHit(cellID=0xabadcaffee, eDep=0.1, position=(0.0, 0.0, 0.0), particle=p7);
#md # !!! note "Note that"
#md #     The just created hit is not yet registered to any collection. This is seen by the value of the `index` attribute.
println("index=$(hit.index)")
# The value #0 indicates that is not registered. To register it, we can use the function `register` to the default `EDCollection`
nhit = register(hit)
println("index=$(nhit.index)")
# Now the hit is registered and can be accessed by the `getEDCollection` function
for h in getEDCollection(SimTrackerHit)
    println("SimTrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position) associated to particle $(h.particle.index)")
end
# Alternatively, instead of using the `register` function, we can also use the function `push!` to a specific `EDCollection`.
hitcollection = EDCollection{SimTrackerHit}()
push!(hitcollection, hit)
push!(hitcollection, hit)
for h in hitcollection
    println("SimTrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position) associated to particle $(h.particle.index)")
end

# ### One-to-many relations
# The type `Track` has a one-to-many relation with objects of type `TrackerHit` that have
# created the `Track`. The `Track` type has a `trackerHits` property that behaves as a vector of `TrackerHit` objects.
# Functions `pushToTrackerHits` and `popFromTrackerHits` are provided
# to create the relation between the `Track` and the `TrackerHit`.
t_hit1 = TrackerHit3D(cellID=0x1, eDep=0.1, position=(1., 1., 1.))
t_hit2 = TrackerHit3D(cellID=0x1, eDep=0.2, position=(2., 2., 2.))
track = Track()
track = pushToTrackerHits(track, t_hit1)
track = pushToTrackerHits(track, t_hit2)
println("Track has $(length(track.trackerHits)) hits")
for h in track.trackerHits
   println("TrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position)")
end
# The `Track` object has a `trackerHits` property that can be iterated and index of `TrackerHit3D` objects.
println("Hit 1: $(track.trackerHits[1])")
println("Hit 2: $(track.trackerHits[2])")
# We can remove the hits from the track using the `popFromTrackerHits` function
track = popFromTrackerHits(track)
for h in track.trackerHits
    println("TrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position)")
 end
println("After pop Track has $(length(track.trackerHits)) hits")

# ## Convert PYTHIA event to MCParticles
# Next we will generate a PYTHIA event and convert it to `MCParticle`s and use the interface provided by EDM4hep to 
# navigate through the particles.
#
# ### Conversion function of PYTHIA event to MCParticles
# The following function `convertToEDM` takes a `PYTHIA8.Event` object and converts it to a collection of `MCParticle` objects.
# The properties of a PYTHIA `Particle` are mapped to the properties of a `MCParticle` object. The only complexity is to
# create the relations between the particles. The function `add_parent` is used to create the relations between the particles.
# The interpretation of the indices is described in the PYTHIA documentation:
#
# There are six allowed combinations of mother1 and mother2:
# - mother1 = mother2 = 0: for lines 0 - 2, where line 0 represents the event as a whole, and 1 and 2 the two incoming beam particles;
# - mother1 = mother2 > 0: the particle is a "carbon copy" of its mother, but with changed momentum as a "recoil" effect, e.g. in a shower;
# - mother1 > 0, mother2 = 0: the "normal" mother case, where it is meaningful to speak of one single mother to several products, in a shower or decay;
# - mother1 < mother2, both > 0, for abs(status) = 81 - 86: primary hadrons produced from the fragmentation of a string spanning the range from mother1 to mother2, so that all partons in this range should be considered mothers; and analogously for abs(status) = 101 - 106, the formation of R-hadrons;
# - mother1 < mother2, both > 0, except case 4: particles with two truly different mothers, in particular the particles emerging from a hard 2 → n interaction.
# - mother2 < mother1, both > 0: particles with two truly different mothers, notably for the special case that two nearby partons are joined together into a status 73 or 74 new parton, in the g + q → q case the q is made first mother to simplify flavour tracing.
# 
# Note that indices in the `PYTHIA8.Event` start at 0, while in the `EDM4hep` types start at 1.
function convertToEDM(event, onlyFinal=false)
    ## Initialize the MCParticle collection
    mcps = getEDCollection(MCParticle) |> empty!
    ## Loop over the particles in the Pythia event 
    for p in event
        onlyFinal && (p |> isFinal || continue)
        ## Create a new EDM particle
        MCParticle(PDG = p |> id,
                   generatorStatus = p |> status,
                   charge = p |> charge,
                   time = p |> tProd,
                   mass = p |> m,
                   vertex = Vector3d(p |> xProd, p |> yProd, p |> zProd),
                   momentum = Vector3d(p |> px, p |> py, p |> pz),
                   colorFlow = (p |> col, p|> acol)) |> register
    end
    onlyFinal && return mcps
    ## Loop over the particles in the Pythia event to create the relations (second pass)
    for (i,p) in enumerate(event)
        mcp = mcps[i]
        m1, m2 = p |> mother1, p |> mother2
        m1 == m2 > 0 &&  add_parent(mcp, mcps[m1+1])
        m1 > 0 && m2 == 0 && add_parent(mcp, mcps[m1+1])
        if 0 < m1 < m2
            for j in m1:m2
                add_parent(mcp, mcps[j+1])
            end
        end
    end
    return mcps
end
# ### Generate a PYTHIA event
pythia = PYTHIA8.Pythia("", false) # Create a PYTHIA object (mode=0, no output)
pythia << "Beams:eCM = 8000." <<
          "HardQCD:all = on" <<
          "PhaseSpace:pTHatMin = 20.";
## The purpose of the next two lines is to reduce the amount of output during the event generation
pythia << "Next:numberShowEvent = 0" <<
          "Next:numberShowProcess = 0"; 
pythia |> init
pythia |> next

# We convert now the PYTHIA event to `MCParticles` (only final particles in this case)
mcps = convertToEDM(event(pythia), true);

# Lets's see if the conversion was successful and the set of particles conserves the energy, charge and momentum
println("Total energy = $(sum(p.energy for p in mcps))")
println("Total charge = $(sum(mcps.charge))")
println("Total momentum = $(sum(mcps.momentum))")
# We recover here ths center-of-mass energy, the total charge of 2 from the incident protons and the 
# total momentum of the event (compatible with zero). 
# 
# Lets now display some selected decay trees inside the full `MCParticle` collection.
# We start by converting the PYTHIA event taking all particles this time.
# The, we implement a recursive function `printdecay`to print the decay tree of the particles.
mcps = convertToEDM(event(pythia));
function printdecay(indent, p)
    println(isempty(indent) ? "" : indent*"---> ", "$(p.name) E=$(p.energy)")
    for d in p.daughters
        printdecay(indent*"   ", d)
    end
end
# Lets use the function to print the decay trees of all the particles in the event
# that contains the charm quark. The module `Corpuscles` is used to identify the charm quark.
for p in mcps
    hascharm(p.PDG) || continue
    printdecay("", p)
end
# In another event we get obviously a different set of particles and decay trees.
pythia |> next
mcps = convertToEDM(event(pythia));
for p in mcps
    hascharm(p.PDG) || continue
    printdecay("", p)
end

