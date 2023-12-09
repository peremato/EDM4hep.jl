using Revise
using EDM4hep
using DataFrames
using EDM4hep.RootIO

f = "/Users/mato/Downloads/example_edm4hep2.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events")
evt = events[1]

se_hits = RootIO.get(reader, evt, "SETCollection")
mcps =  RootIO.get(reader, evt, "MCParticle")


for hit in set_hits:
    mc = hit.getMCParticle()
    print(f"Hit {hit.id().index} is related to MC {mc.id().index}")




tree = LazyTree(f, "events", ("SITCollection","MCParticle"))

layout_mcp = buildlayout(tree, "MCParticle", MCParticle)  # need the relation between the type and container name
layout_hits = buildlayout(tree, "SITCollection", SimTrackerHit)

df1 = DataFrame(getStructArray(tree[1], layout_mcp))
df2 = DataFrame(getStructArray(tree[1], layout_hits))

for evt in tree[1:10]
    assignEDStore(getStructArray(evt, layout_mcp))
    for p in getEDStore(MCParticle).objects
        println("MCParticle $(p.index) with PDG=$(p.PDG) and momentum $(p.momentum) has $(length(p.daughters)) daughters")
        #for d in p.daughters
        #    println("   ---> $(d.index) with PDG=$(d.PDG) and momentum $(d.momentum)")
        #end
    end
end

