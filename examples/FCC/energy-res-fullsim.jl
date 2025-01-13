using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using EDM4hep.Analysis
using LinearAlgebra
using Plots

include("analysis_functions.jl")
include("dataset_functions.jl")
const nevents = 10000

files = get_filelist("ee_mumuH", nevents)
reader = RootIO.Reader(files);
events = RootIO.get(reader, "events");

hresolu = H1D("Resolution [GeV]", 100, -5., 5., unit=:GeV)

get_recps = RootIO.create_getter(reader, "PandoraPFOs"; selection=[:type, :energy, :momentum, :charge, :mass, :tracks])
get_mcps  = RootIO.create_getter(reader, "MCParticles"; selection=[:PDG, :momentum, :charge, :mass])
get_trks  = RootIO.create_getter(reader, "SiTracks_Refitted"; selection=[:type])
get_links = RootIO.create_getter(reader, "SiTracksMCTruthLink")  

for evt in events
    # Select muons
    recps = unBoostCrossingAngle(get_recps(evt), -0.015rad)
    muons_all = filter(x -> abs(x.type) == 13, recps)            # select muons
    muons_sel = filter(x -> norm(x.momentum) > 20GeV, muons_all) # select muons with p > 20 GeV

    # Energy resolution of Reconstructed muons
    mcps = unBoostCrossingAngle(get_mcps(evt), -0.015rad) # MC particles
    trks = get_trks(evt)                                  # Tracks
    links = get_links(evt)                                # Links T`racks<->MC particles   
    for muon in muons_sel
        for trk in muon.tracks
            nl = findfirst(x -> x.rec == trk, links)
            isnothing(nl) && continue
            push!(hresolu, muon.energy - links[nl].sim.energy)
        end
    end
end
plot(hresolu.hist, title=hresolu.title, cgrad=:plasma)
