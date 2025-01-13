using Revise
using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using EDM4hep.Analysis
using LinearAlgebra
using Parameters
using Plots
using FHist

include("analysis_functions.jl")
include("dataset_functions.jl")
#onst nevents = 73200
const nevents = 10000

#@time files = get_filelist("ee_mumuH", nevents)

f = "/Users/mato/cernbox/Data/mumuH_rec_16610_1.root"
#f = "root://eospublic.cern.ch//eos/experiment/fcc/prod/fcc/ee/test_spring2024/240gev/Hbb/CLD_o2_v05/rec/00016562/000/Hbb_rec_16562_1.root"

@time reader = RootIO.Reader(f);
@time events = RootIO.get(reader, "events");

evt = events[1];

@with_kw mutable struct MyData <: AbstractAnalysisData
    nevents::Int64 =  0
    μ1::Int64 = 0
    μ2::Int64 = 0
    mμμ::Int64 = 0
    pμμ::Int64 = 0
    nrecoils::Int64 = 0
    ctmiss::Int64 = 0
    hzmass::H1D = H1D("Z mass [GeV]", 100, 80., 100., unit=:GeV)
    hrecoil::H1D = H1D("Z leptonic recoil [GeV]", 100, 120., 160., unit=:GeV)
    hresolu::H1D = H1D("Resolution [GeV]", 100, -5., 5., unit=:GeV)
end

get_recps = RootIO.create_getter(reader, "PandoraPFOs"; selection=[:type, :energy, :momentum, :charge, :mass, :tracks])
get_mcps  = RootIO.create_getter(reader, "MCParticles"; selection=[:PDG, :momentum, :charge, :mass])
get_trks  = RootIO.create_getter(reader, "SiTracks_Refitted"; selection=[:type])
get_links = RootIO.create_getter(reader, "SiTracksMCTruthLink")  

function myanalysis!(data::MyData, reader, events)
    for evt in events
        data.nevents += 1
        recps = RootIO.get(reader, evt, "PandoraPFOs")
        recps = unBoostCrossingAngle(recps, -0.015rad)
        muons_all = filter(x -> abs(x.type) == 13, recps)            # select muons
        muons_sel = filter(x -> norm(x.momentum) > 20GeV, muons_all) # select muons with p > 20 GeV
        isos = coneIsolation(0.01, 0.5, muons_sel, recps)            # calculate cone isolations
        muons_iso = [x for (x,iso) in zip(muons_sel, isos) if iso < 0.25] # apply isolation

        # CUT 1: at least a lepton with at least 1 isolated one
        length(muons_sel) >= 1 && length(muons_iso) > 0 || continue
        data.μ1 += 1

        # CUT 2 :at least 2 OS leptons, and build the resonance
        length(muons_sel) >= 2 && sum(muons_sel.charge) < length(muons_sel)|| continue
        data.μ2 += 1
        Zs = resonanceBuilder(91GeV, muons_sel)                      # build the Z candidates

        # CUT 3: Z mass window
        86GeV < Zs[1].mass < 96GeV  || continue
        data.mμμ += 1

        # CUT 4: Z momentum
        20GeV < norm(Zs[1].momentum) < 70GeV || continue
        data.pμμ += 1
        push!(data.hzmass, Zs[1].mass)
        recoils = recoilBuilder(240GeV, Zs)

        # CUT 5: recoil cut
        120GeV < recoils[1].mass < 160GeV || continue
        data.nrecoils += 1
        push!(data.hrecoil, recoils[1].mass)

        # CUT 6: cosTheta missing
        missenergy = missingEnergy(240GeV, recps)
        cos(θ(missenergy)) < 0.98 || continue
        data.ctmiss += 1

        # Resolution of Reconstructed muons
        mcps = unBoostCrossingAngle(get_mcps(evt), -0.015rad) 
        trks = get_trks(evt)
        links = get_links(evt)
        for muon in muons_sel
            for trk in muon.tracks
                nl = findfirst(x -> x.rec == trk, links)
                isnothing(nl) && continue
                push!(data.hresolu, muon.energy - links[nl].sim.energy)
            end
        end

    end
    return data
end

function do_plot(data::T) where T<:AbstractAnalysisData
    img = plot(layout=(2,2), show=true, size=(1000,1500))
    idx = 1
    for fn in fieldnames(T)
        fv = getproperty(data, fn)
        if fv isa H1D
            plot!(subplot=idx, fv.hist, title=fv.title, show=true, cgrad=:plasma)
            idx += 1
        end
    end
    return img
end

@time subset = @view events[1:100]

@info "Serial 1st run"
mydata = MyData()
@time do_analysis!(mydata, myanalysis!, reader, subset; mt=false);
dump(mydata)
do_plot(mydata)


