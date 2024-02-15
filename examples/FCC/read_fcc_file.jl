using Revise
using EDM4hep
using EDM4hep.RootIO

cd(@__DIR__)

f = "/Users/mato/cernbox/Data/events_000189367.root"
#f = "/Users/mato/cernbox/Data/events_078174375.root"
#f = "../Output_REC_rntuple.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events")

evt = events[1];

mcps = RootIO.get(reader, evt, "Particle"; register=false);