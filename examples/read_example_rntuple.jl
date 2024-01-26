using Revise
using EDM4hep
using EDM4hep.RootIO

cd(@__DIR__)

f = "ttbar_edm4hep_digi_rntuple.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events");

evt = events[1];

hits = RootIO.get(reader, evt, "InnerTrackerBarrelCollection")
mcps = RootIO.get(reader, evt, "MCParticle")

for hit in hits
    println("Hit $(hit.index) is related to MCParticle $(hit.mcparticle.index) with name $(hit.mcparticle.name)")
end

for p in mcps
    println("MCParticle $(p.index) $(p.name) with momentum $(p.momentum) and energy $(p.energy) has $(length(p.daughters)) daughters")
    for d in p.daughters
        println("   ---> $(d.index) $(d.name) and momentum $(d.momentum) has $(length(d.parents)) parents")
        for m in d.parents
            println("      ---> $(m.index) $(m.name)")
        end 
    end
end

barrel_clusters = RootIO.get(reader, evt, "ECalBarrelCollection")
contributions = RootIO.get(reader, evt, "AllCaloHitContributionsCombined")

for c in barrel_clusters[1:50]
    particles = collect(Set("$(contrib.particle_idx)" for contrib in c.contributions))
    println("SimCalorimeterHit $(c.index) with CellID $(EDM4hep.hex(c.cellID)),  position $(c.position) and energy $(c.energy) has $(length(c.contributions)) contributions from particles $particles")
end

#---Loop over events-------------------------------------------------------------------------------
for (n,e) in enumerate(events)
    ps =  RootIO.get(reader, e, "MCParticle")
    #println("Event #$(n) has $(length(ps)) MCParticles with a charge sum of $(sum(ps.charge))")
end
