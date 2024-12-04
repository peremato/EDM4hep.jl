using EDM4hep
using PYTHIA8
using Corpuscles: hascharm, hasstrange, ismeson, isbaryon
using FHist
using Plots: plot, plot!, theme

p1 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, 7000.0), generatorStatus=3);
p2 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, -7000.0), generatorStatus=3);

println("Particle p1 has PDG=$(p1.PDG), mass=$(p1.mass), momentum=$(p1.momentum), and generatorStatus=$(p1.generatorStatus)")
println("Particle p2 has PDG=$(p2.PDG), mass=$(p2.mass), momentum=$(p2.momentum), and generatorStatus=$(p2.generatorStatus)")

println("Particle p1 has name=$(p1.name)")
println("Particle p2 has name=$(p2.name)")

println("Particle p1 has energy=$(p1.energy)")
println("Particle p2 has energy=$(p2.energy)")

try
    p1.time = 1.1
catch e
    println(e)
end

p1 = @set p1.time = 1.1;

println("Particle p1 has time = $(p1.time)")

p3 = MCParticle(PDG=1, mass=0.0, momentum=(0.750, -1.569, 32.191), generatorStatus=3)
p3, p1 = add_parent(p3, p1)

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

for p in getEDCollection(MCParticle)
    println("MCParticle $(p.index) with PDG=$(p.PDG) and momentum $(p.momentum) has $(length(p.daughters)) daughters")
    for d in p.daughters
        println("   ---> $(d.index) with PDG=$(d.PDG) and momentum $(d.momentum)")
    end
end

hit = SimTrackerHit(cellID=0xabadcaffee, eDep=0.1, position=(0.0, 0.0, 0.0), particle=p7);
println("index=$(hit.index)")

nhit = register(hit)
println("index=$(nhit.index)")

for h in getEDCollection(SimTrackerHit)
    println("SimTrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position) associated to particle $(h.particle.index)")
end

hitcollection = EDCollection{SimTrackerHit}()
push!(hitcollection, hit)
push!(hitcollection, hit)
for h in hitcollection
    println("SimTrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position) associated to particle $(h.particle.index)")
end

t_hit1 = TrackerHit3D(cellID=0x1, eDep=0.1, position=(1., 1., 1.))
t_hit2 = TrackerHit3D(cellID=0x1, eDep=0.2, position=(2., 2., 2.))
track = Track()
track = pushToTrackerHits(track, t_hit1)
track = pushToTrackerHits(track, t_hit2)
println("Track has $(length(track.trackerHits)) hits")
for h in track.trackerHits
   println("TrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position)")
end

println("Hit 1: $(track.trackerHits[1])")
println("Hit 2: $(track.trackerHits[2])")

track = popFromTrackerHits(track)
for h in track.trackerHits
    println("TrackerHit in cellID=$(string(h.cellID, base=16)) with eDep=$(h.eDep) and position=$(h.position)")
 end
println("After pop Track has $(length(track.trackerHits)) hits")

function convertToEDM(event, onlyFinal=false)
    # Initialize the MCParticle collection
    mcps = getEDCollection(MCParticle) |> empty!
    # Loop over the particles in the Pythia event
    for p in event
        onlyFinal && (p |> isFinal || continue)
        # Create a new EDM particle
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
    # Loop over the particles in the Pythia event to create the relations (second pass)
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

pythia = PYTHIA8.Pythia("", false) # Create a PYTHIA object (mode=0, no output)
pythia << "Beams:eCM = 8000." <<
          "HardQCD:all = on" <<
          "PhaseSpace:pTHatMin = 20.";
# The purpose of the next two lines is to reduce the amount of output during the event generation
pythia << "Next:numberShowEvent = 0" <<
          "Next:numberShowProcess = 0";
pythia |> init
pythia |> next

mcps = convertToEDM(event(pythia), true);

println("Total energy = $(sum(p.energy for p in mcps))")
println("Total charge = $(sum(mcps.charge))")
println("Total momentum = $(sum(mcps.momentum))")

mcps = convertToEDM(event(pythia));
function printdecay(indent, p)
    println(isempty(indent) ? "" : indent*"---> ", "$(p.name) E=$(p.energy)")
    for d in p.daughters
        printdecay(indent*"   ", d)
    end
end

for p in mcps
    hascharm(p.PDG) || continue
    printdecay("", p)
end

pythia |> next
mcps = convertToEDM(event(pythia));
for p in mcps
    hascharm(p.PDG) || continue
    printdecay("", p)
end
