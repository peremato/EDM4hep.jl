using EDM4hep
using EDM4hep.RootIO

cd(@__DIR__)

f = "Output_REC_rntuple-rc2.root"
#f = "Output_REC.root"
#f = "/Users/mato/cernbox/Data/Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00001.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events");

evt = events[1];

particles = RootIO.get(reader, evt, "PandoraPFOs");
for p in particles
    println("Particle $(p.index) with energy $(p.energy)")
end

 

