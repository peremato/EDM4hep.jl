using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using DataFrames
using Base.Threads
using Profile

struct _ObjectID{ED <: EDM4hep.POD} <: EDM4hep.POD
    index::Int32
    collectionID::UInt32    # in some cases (reading from files) the collection ID is -2
end

include("analysis_functions.jl")

#f = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
f = "/Users/mato/cernbox/Data/events_000189367.root"
reader = RootIO.Reader(f);
events = RootIO.get(reader, "events");

const N = nthreads()
const tasks_per_thread = 16

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

function myiteration!(data::MyData, evt)
    data.pevts += 1
    recps = RootIO.get(reader, evt, "ReconstructedParticles", register=false);
    _muons = RootIO.get(reader, evt, "Muon#0"; btype=_ObjectID{ReconstructedParticle}, register=false)
    muons = [recps[mid.index+1] for mid in _muons]
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

function myanalysis!(data::MyData, events)
    for evt in events
        myiteration!(data, evt)
    end
end


function do_analysis_mt!(data, afunc, events)
    N = Threads.nthreads()
    # Empty the data
    empty!(data)
    vdata = [deepcopy(data) for i in 1:N]
    function do_chunk(func, chunk)
        tid = Threads.threadid()
        func(vdata[tid], chunk)
        nothing
    end
    # Chunk the total number of events to process
    chunks = Iterators.partition(events, length(events) ÷ (tasks_per_thread * N))
    # Spawn the tasks
    tasks = map(chunks) do chunk
        Threads.@spawn do_chunk(afunc, chunk)
    end
    # Wait and sum the reduce the results
    wait.(tasks)
    for i in 1:N
        append!(data, vdata[i])
    end
    return data
end

function do_analysis_serial!(data, afunc, events)
    # Empty the data
    empty!(data)
    afunc(data, events)
    return data
end

function do_analysis_threads!(data, afunc, events)
    N = Threads.nthreads()
    # Empty the data
    empty!(data)
    vdata = [deepcopy(data) for i in 1:N]
    @threads for evt in events
        tid = Threads.threadid()
        afunc(vdata[tid], evt)
    end
    for i in 1:N
        append!(data, vdata[i])
    end
    return data
end

mydata = MyData()

do_analysis_mt!(mydata, myanalysis!, Iterators.take(events, 1000))

elapsed = @elapsed do_analysis_serial!(mydata, myanalysis!, events)
println("Serial total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")

elapsed = @elapsed do_analysis_mt!(mydata, myanalysis!, events)
println("MT[$N](tasking) total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")

elapsed = @elapsed do_analysis_threads!(mydata, myiteration!, events)
println("MT[$N](threads) total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")

#@profview do_analysis_mt!(mydata, myanalysis!, events)
#@profview do_analysis_threads!(mydata, myiteration!, events)

#using Parquet2
#Parquet2.writefile("m_H-recoil.parquet", mydata.df)

#using Plots
#histogram(sum_df.Zcand_m)



