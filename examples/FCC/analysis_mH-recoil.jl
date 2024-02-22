using Revise
using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using Parameters

using Plots

include("analysis_functions.jl")

f = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"

reader = RootIO.Reader(f);
events = RootIO.get(reader, "events");

@with_kw struct Histograms
    mz          = H1D("m_{Z} [GeV]",125,0,250, unit=:GeV)
    mz_zoom     = H1D("m_{Z} [GeV]",40,80,100, unit=:GeV)
    lr_m        = H1D("Z leptonic recoil [GeV]", 100, 0, 200, unit=:GeV)
    lr_m_zoom   = H1D("Z leptonic recoil [GeV]", 200, 80, 160, unit=:GeV)
    lr_m_zoom1  = H1D("Z leptonic recoil [GeV]", 100, 120, 140, unit=:GeV)
    lr_m_zoom2  = H1D("Z leptonic recoil [GeV]", 200, 120, 140, unit=:GeV)
    lr_m_zoom3  = H1D("Z leptonic recoil [GeV]", 400, 120, 140, unit=:GeV)
    lr_m_zoom4  = H1D("Z leptonic recoil [GeV]", 800, 120, 140, unit=:GeV)
    lr_m_zoom5  = H1D("Z leptonic recoil [GeV]", 2000, 120, 140, unit=:GeV)
    lr_m_zoom6  = H1D("Z leptonic recoil [GeV]", 100, 130.3, 132.5, unit=:GeV)
end
function do_plot(histos::Histograms)
    img = plot(layout=(3,4), show=true, size=(1400,1000))
    for (i,fn) in enumerate(fieldnames(Histograms))
        h = getfield(histos, fn)
        plot!(subplot=i, h.hist, title=h.title, show=true, cgrad=:plasma)
    end
    return img
end

myhists = Histograms()

nevts = 0
elaptime = @elapsed for evt in events
    nevts += 1
    recps = RootIO.get(reader, evt, "ReconstructedParticles");
    muons = RootIO.get(reader, evt, "Muon#0"; btype=ObjectID{ReconstructedParticle})
    sel_muons = filter(x -> pₜ(x) > 10GeV, muons)
    zed_leptonic = resonanceBuilder(91GeV, sel_muons)
    zed_leptonic_recoil = recoilBuilder(240GeV, zed_leptonic)
    if length(zed_leptonic) == 1    #  Filter to have exactly one Z candidate
        Zcand_m        = zed_leptonic[1].mass
        Zcand_recoil_m = zed_leptonic_recoil[1].mass
        Zcand_q        = zed_leptonic[1].charge
        if 80GeV <= Zcand_m <= 100GeV
            #---Fill histograms now--------------------------------------
            push!(myhists.mz, Zcand_m)
            push!(myhists.mz_zoom, Zcand_m)
            push!(myhists.lr_m, Zcand_recoil_m)
            push!(myhists.lr_m_zoom1, Zcand_recoil_m)
            push!(myhists.lr_m_zoom2, Zcand_recoil_m)
            push!(myhists.lr_m_zoom3, Zcand_recoil_m)
            push!(myhists.lr_m_zoom4, Zcand_recoil_m)
            push!(myhists.lr_m_zoom5, Zcand_recoil_m)
            push!(myhists.lr_m_zoom6, Zcand_recoil_m)
        end
    end
end
println("Events processed: $nevts, elapsed time: $elaptime s, events/s: $(nevts/elaptime)")

do_plot(myhists)
