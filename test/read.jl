using Revise
using UnROOT
using EDM4hep
using StructArrays

f = "/Users/mato/Downloads/ODD_gamma_theta1.57_500events_100GeV_edm4hep.root"
tree = LazyTree(f, "events", ("PixelBarrelReadout","MCParticles"))

layout_mcp = buildlayout(tree, "MCParticles", MCParticle)
evt = tree[1]

mcps = getStructArray(evt, layout_mcp)
