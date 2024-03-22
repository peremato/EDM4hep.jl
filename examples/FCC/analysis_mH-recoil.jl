using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using DataFrames

include("analysis_functions.jl")

#f= "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
#f = "/Users/mato/cernbox/Data/events_000189367.root"
f = "/Users/mato/cernbox/Data/events_000189367-rntuple-rc2.root"

reader = RootIO.Reader(f);
events = RootIO.get(reader, "events");

#const μobjIdx = "Muon#0"
const μobjIdx = "Muon_objIdx"

df = DataFrame(Zcand_m = Float32[], Zcand_recoil_m = Float32[], Zcand_q = Int32[])

nevents = 0
elaptime = @elapsed for evt in events
    global nevents += 1
    μIDs = RootIO.get(reader, evt, μobjIdx)       # get the ids of muons
    length(μIDs) < 2 && continue                  # skip if less than 2  
    recps = RootIO.get(reader, evt, "ReconstructedParticles") 
    muons = recps[μIDs]                           # use the ids to subset the reco particles
    sel_muons = filter(x -> pₜ(x) > 10GeV, muons)
    zed_leptonic = resonanceBuilder(91GeV, sel_muons)
    zed_leptonic_recoil = recoilBuilder(240GeV, zed_leptonic)
    if length(zed_leptonic) == 1    #  Filter to have exactly one Z candidate
        Zcand_m        = zed_leptonic[1].mass
        Zcand_recoil_m = zed_leptonic_recoil[1].mass
        Zcand_q        = zed_leptonic[1].charge
        if 80GeV <= Zcand_m <= 100GeV
            push!(df, (Zcand_m, Zcand_recoil_m, Zcand_q))
        end
    end
end
println("Events processed: $nevents, elapsed time: $elaptime s, events/s: $(nevents/elaptime)")
println("Selected events: $(nrow(df))")

#using Parquet2
#Parquet2.writefile("m_H-recoil.parquet", df)
