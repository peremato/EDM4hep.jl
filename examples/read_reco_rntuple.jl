using Revise
using EDM4hep
using EDM4hep.RootIO

cd(@__DIR__)

#f = "Output_REC_rntuple.root"
f = "Output_REC.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events");

evt = events[1];

tracks = RootIO.get(reader, evt, "SiTracks_Refitted");
for t in tracks
    println("Track $(t.index) with sum(subdet hit numbers) $(sum(t.subdetectorHitNumbers))")
end

 

