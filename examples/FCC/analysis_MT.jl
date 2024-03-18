using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using DataFrames

include("analysis_functions.jl")

f = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
#f = "/Users/mato/cernbox/Data/events_000189367.root"
reader = RootIO.Reader(f);
events = RootIO.get(reader, "events");

const N = Threads.nthreads()
const tasks_per_thread = 4

mutable struct MyData
    df::DataFrame
    pevts::Int64
    sevts::Int64
    MyData() = new(DataFrame(Zcand_m = Float32[], Zcand_recoil_m = Float32[], Zcand_q = Int32[]), 0, 0)
end
function Base.empty!(data::MyData)
    empty!(data.df)
    data.pevts = 0
    data.sevts = 0
end
function Base.append!(d1::MyData, d2::MyData)
    append!(d1.df, d2.df)
    d1.pevts += d2.pevts
    d1.sevts += d2.sevts
end

function myiteration!(data::MyData, reader, evt)
    data.pevts += 1
    μIDs = RootIO.get(reader, evt, "Muon#0")
    length(μIDs) < 2 && return 

    recps = RootIO.get(reader, evt, "ReconstructedParticles")
    muons = recps[μIDs]

    sel_muons = filter(x -> pₜ(x) > 10GeV, muons)
    zed_leptonic = resonanceBuilder(91GeV, sel_muons)
    zed_leptonic_recoil = recoilBuilder(240GeV, zed_leptonic)
    if length(zed_leptonic) == 1    #  Filter to have exactly one Z candidate
        Zcand_m        = zed_leptonic[1].mass
        Zcand_recoil_m = zed_leptonic_recoil[1].mass
        Zcand_q        = zed_leptonic[1].charge
        if 80GeV <= Zcand_m <= 100GeV
            push!(data.df, (Zcand_m, Zcand_recoil_m, Zcand_q))
            data.sevts += 1
        end
    end
end

function myanalysis!(data::MyData, reader, events)
    for evt in events
        myiteration!(data, reader, evt)
    end
    return data
end


function do_analysis_mt!(data, afunc, reader, events)
    N = Threads.nthreads()
    # Empty the data
    empty!(data)

    # Chunk the total number of events to process
    chunks = Iterators.partition(events, length(events) ÷ (tasks_per_thread * N))
    # Spawn the tasks
    tasks = map(chunks) do chunk
        Threads.@spawn afunc(MyData(), reader, chunk)
    end
    # Wait and sum the reduce the results
    results = fetch.(tasks)
    append!.(Ref(data), results)
    return data
end

function do_analysis_serial!(data, afunc, reader, events)
    # Empty the data
    empty!(data)
    afunc(data, reader, events)
    return data
end

function do_analysis_threads!(data, afunc, reader, events)
    N = Threads.nthreads()
    # Empty the data
    empty!(data)
    vdata = [deepcopy(data) for i in 1:N]
    Threads.@threads for evt in events
        tid = Threads.threadid()
        afunc(vdata[tid], reader, evt)
    end
    for i in 1:N
        append!(data, vdata[i])
    end
    return data
end

mydata = MyData()

@info "Serial 1st run"
@time do_analysis_serial!(mydata, myanalysis!, reader, events);
@info "Serial 2nd run"
@time do_analysis_serial!(mydata, myanalysis!, reader, events);

@info "Chunk 1st run"
@time do_analysis_mt!(mydata, myanalysis!, reader, events);
#Profile.clear_malloc_data()
@info "Chunk 2nd run"
@time do_analysis_mt!(mydata, myanalysis!, reader, events);
 
@info "Threads 1st run"
@time do_analysis_threads!(mydata, myiteration!, reader, events);
@info "Threads 2nd run"
@time do_analysis_threads!(mydata, myiteration!, reader, events);

#using Parquet2
#Parquet2.writefile("m_H-recoil.parquet", mydata.df)

#using Plots
#histogram(sum_df.Zcand_m)



