
using Revise
using EDM4hep

# place the following generator event to the MCParticle collection
#     name status pdg_id  parent Px       Py    Pz       Energy      Mass
#  1  !p+!    3   2212    0,0    0.000    0.000 7000.000 7000.000    0.938
#  2  !p+!    3   2212    0,0    0.000    0.000-7000.000 7000.000    0.938
# =========================================================================
#  3  !d!     3      1    1,1    0.750   -1.569   32.191   32.238    0.000
#  4  !u~!    3     -2    2,2   -3.047  -19.000  -54.629   57.920    0.000
#  5  !W-!    3    -24    1,2    1.517   -20.68  -20.605   85.925   80.799
#  6  !gamma! 1     22    1,2   -3.813    0.113   -1.833    4.233    0.000
#  7  !d!     1      1    5,5   -2.445   28.816    6.082   29.552    0.010
#  8  !u~!    1     -2    5,5    3.962  -49.498  -26.687   56.373    0.006

p1 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, 7000.0), generatorStatus=3)
p1 = register(p1)

p2 = MCParticle(PDG=2212, mass=0.938, momentum=(0.0, 0.0, -7000.0), generatorStatus=3)
p2 = register(p2)

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

for p in EDM4hep.mcparticle_objects
    println("MCParticle $(p.index) with PDG=$(p.PDG) and momentum $(p.momentum) has $(length(p.daughters)) daughters")
    for d in p.daughters
        println("   ---> $(d.index) with PDG=$(d.PDG) and momentum $(d.momentum)")
    end
end

#---Simulation tracking hits

const nsh = 5
for j in 1:nsh
  sth1 = SimTrackerHit(cellID=0xabadcaffee, EDep=j*0.000001, position=(j * 10., j * 20., j * 5.), mcparticle=p7)
  sth1 = register(sth1)

  sth2 = SimTrackerHit(cellID=0xcaffeebabe, EDep=j*0.001, position=(-j * 10., -j * 20., -j * 5.), mcparticle=p8)
  sth2 = register(sth2)
end

for s in EDM4hep.simtrackerhit_objects
    println("SimTrackerHit in cellID=$(string(s.cellID, base=16)) with EDep=$(s.EDep) and position=$(s.position) associated to particle $(s.mcparticle.index)")
end

using DataFrames
df = DataFrame(EDM4hep.mcparticle_objects)

using StructArrays
sa = StructArray(EDM4hep.mcparticle_objects)

