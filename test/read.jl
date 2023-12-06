using UnROOT
using EDM4hep


f = "/Users/mato/Downloads/ODD_gamma_theta1.57_500events_100GeV_edm4hep.root"

file = ROOTFile(f; customstructs = Dict("edm4hep::MCParticle" => MCParticle))
mytree = LazyTree(file, "events", "MCParticles")


