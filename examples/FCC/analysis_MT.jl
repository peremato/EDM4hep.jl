using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using EDM4hep.Analysis
using DataFrames

include("analysis_functions.jl")

fnames = """
events_000189367.root
events_000787350.root
events_001145354.root
events_001680909.root
events_001893485.root
events_002227306.root
events_002498645.root
events_002528960.root
events_002763770.root
events_003579490.root
"""
froot = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240"
files = joinpath.(Ref(froot),split(fnames))

#files = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
files = "/Users/mato/cernbox/Data/events_000189367-rntuple-rc2.root"

reader = RootIO.Reader(files);
events = RootIO.get(reader, "events");

const N = Threads.nthreads()
const tasks_per_thread = 4

mutable struct MyData <: AbstractAnalysisData
    df::DataFrame
    pevts::Int64
    sevts::Int64
    MyData() = new(DataFrame(Zcand_m = Float32[], Zcand_recoil_m = Float32[], Zcand_q = Int32[]), 0, 0)
end

function myanalysis!(data::MyData, reader, events)
    for evt in events
        data.pevts += 1                               # count process events
        μIDs = RootIO.get(reader, evt, "Muon_objIdx"; register=false) # get the ids of muons
        length(μIDs) < 2 && continue                  # skip if less than 2  
        
        recps = RootIO.get(reader, evt, "ReconstructedParticles"; register=false) 
        muons = recps[μIDs]                           # use the ids to subset the reco particles
    
        sel_muons = filter(x -> pₜ(x) > 10GeV, muons)  # select the the Pt of muons
        zed_leptonic = resonanceBuilder(91GeV, sel_muons)
        zed_leptonic_recoil = recoilBuilder(240GeV, zed_leptonic)
        if length(zed_leptonic) == 1                   #  filter to have exactly one Z candidate
            Zcand_m        = zed_leptonic[1].mass
            Zcand_recoil_m = zed_leptonic_recoil[1].mass
            Zcand_q        = zed_leptonic[1].charge
            if 80GeV <= Zcand_m <= 100GeV              # select on mass of Z candidate, push to dataframe
                push!(data.df, (Zcand_m, Zcand_recoil_m, Zcand_q))
                data.sevts += 1                        # count selected events
            end
        end
    end
    return data
end

mydata = MyData()
#subset = @view events[1:10000]
subset = events

@info "Serial 1st run"
@time do_analysis!(mydata, myanalysis!, reader, subset);
@info "Serial 2nd run"
@time do_analysis!(mydata, myanalysis!, reader, subset);
println("Processed events: $(mydata.pevts), selected: $(mydata.sevts)")
mydata.df |> describe |> println

@info "MT 1st run"
@time do_analysis!(mydata, myanalysis!, reader, subset; mt=true);
#Profile.clear_malloc_data()
@info "MT 2nd run"
@time do_analysis!(mydata, myanalysis!, reader, subset; mt=true);
println("Processed events: $(mydata.pevts), selected: $(mydata.sevts)")
mydata.df |> describe |> println

#using Parquet2
#Parquet2.writefile("m_H-recoil.parquet", mydata.df)

#using Plots
#histogram(sum_df.Zcand_m)

