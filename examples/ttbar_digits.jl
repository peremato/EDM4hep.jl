using Revise
using EDM4hep
using EDM4hep.RootIO

const f = "/Users/mato/Downloads/ttbar_edm4hep_digi.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events");
evt = events[1];

hits = RootIO.get(reader, evt, "VXDTrackerHits")
sim_hits = RootIO.get(reader, evt, "VertexBarrelCollection")
rela = RootIO.get(reader, evt, "VXDTrackerHitRelations")


