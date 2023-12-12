using Revise
using EDM4hep
using DataFrames
using EDM4hep.RootIO

f = "/Users/mato/Downloads/example_edm4hep2.root"
#f = "https://cernbox.cern.ch/remote.php/dav/public-files/yOmBeyVaiYpj46S/example_edm4hep2.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events")
evt = events[1];

set_hits = RootIO.get(reader, evt, "SETCollection")
mcps =  RootIO.get(reader, evt, "MCParticle")

for hit in set_hits
    println("Hit $(hit.index) is related to MCParticle $(hit.mcparticle.index) with PDG $(hit.mcparticle.PDG)")
end

for p in mcps
    println("MCParticle $(p.index) with PDG=$(p.PDG) and momentum $(p.momentum) and energy $(p.energy) has $(length(p.daughters)) daughters")
    for d in p.daughters
        println("   ---> $(d.index) with PDG=$(d.PDG) and momentum $(d.momentum) has $(length(d.parents)) parents")
        for m in d.parents
            println("      ---> $(m.index) with PDG=$(m.PDG)")
        end 
    end
end

#DataFrame(set_hits)
#DataFrame(mcps)[!,14:15]
#parents =  RootIO.get(reader, evt, "_MCParticle_parents"; T=ObjectID{MCParticle}, register=false)
#daughters =  RootIO.get(reader, evt, "_MCParticle_daughters", T=ObjectID{MCParticle}, register=false)

#---Loop over events-------------------------------------------------------------------------------
for (n,e) in enumerate(events)
    ps =  RootIO.get(reader, e, "MCParticle")
    println("Event #$(n) has $(length(ps)) MCParticles with a charge sum of $(sum(ps.charge))")
end