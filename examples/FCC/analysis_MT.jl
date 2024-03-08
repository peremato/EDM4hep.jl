using EDM4hep
using EDM4hep.RootIO
using EDM4hep.SystemOfUnits
using EDM4hep.Histograms
using DataFrames
using StructArrays
using StaticArrays
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
#(ReconstructedParticle, ((ObjectID{ReconstructedParticle}, (-1, -2)), 168, 10, (Vector3f, (180, 214, 252), (), ()), (Vector3f, (231, 2, 255), (), ()), 101, 23, 143, (SVector{10, Float32}, (194, 10)), (Relation{ReconstructedParticle, Cluster, 1}, (215, 164, -2)), (Relation{ReconstructedParticle, Track, 2}, (205, 22, -2)), (Relation{ReconstructedParticle, ReconstructedParticle, 3}, (173, 234, -2)), (Relation{ReconstructedParticle, ParticleID, 4}, (175, 16, -2)), (ObjectID{Vertex}, (100, 244)), (ObjectID{ParticleID}, (24, 26))), (("ReconstructedParticles#0", Cluster), ("ReconstructedParticles#1", Track), ("ReconstructedParticles#2", ReconstructedParticle), ("ReconstructedParticles#3", ParticleID)), ())

function getReconstructedParticles_i(evt)
    types = evt[168]
    len = length(types)
    columns = (StructArray{ObjectID{ReconstructedParticle}}((collect(0:len-1),fill(0,len))),
               types,
               evt[10],
               StructArray{Vector3f}((evt[180], evt[214], evt[252])),
               StructArray{Vector3f}((evt[231], evt[2], evt[255])),
               evt[101],evt[23], evt[143],
               StructArray{SVector{10,Float32}}(reshape(evt[194], 10, len);dims=1),
               StructArray{Relation{ReconstructedParticle,Cluster,1}}((evt[215], evt[164], fill(0, len))),
               StructArray{Relation{ReconstructedParticle,Track,2}}((evt[205], evt[2], fill(0, len))),
               StructArray{Relation{ReconstructedParticle,ReconstructedParticle,3}}((evt[173], evt[234], fill(0, len))),
               StructArray{Relation{ReconstructedParticle,ParticleID,4}}((evt[175], evt[16], fill(0, len))),
               StructArray{ObjectID{Vertex}}((fill(0,len),fill(0,len))),
               StructArray{ObjectID{ParticleID}}((fill(0,len),fill(0,len))) 
               )
    return StructArray{ReconstructedParticle}(columns)
end
using UnROOT

function StructArray{ReconstructedParticle, bname}(evt::UnROOT.LazyEvent, collid, len = -1) where bname
    types = getproperty(evt, Symbol(bname, :_type))
    len = length(types)
    columns = (StructArray{ObjectID{ReconstructedParticle}}((collect(0:len-1),fill(0,len))),
        types,
        getproperty(evt, Symbol(bname, :_energy)),
        StructArray{Vector3f, Symbol(bname, :_momentum)}(evt, collid, len),
        StructArray{Vector3f, Symbol(bname, :_referencePoint)}(evt, collid, len),
        getproperty(evt, Symbol(bname, :_charge)),
        getproperty(evt, Symbol(bname, :_mass)),
        getproperty(evt, Symbol(bname, :_goodnessOfPID)),
        StructArray{SVector{10,Float32}}(reshape(getproperty(evt, Symbol(bname, "_covMatrix[10]")), 10, len);dims=1),
        StructArray{Relation{ReconstructedParticle,Cluster,1}, Symbol(bname, :_clusters)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,Track,2}, Symbol(bname, :_tracks)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,ReconstructedParticle,3}, Symbol(bname, :_particles)}(evt, collid, len),
        StructArray{Relation{ReconstructedParticle,ParticleID,4}, Symbol(bname, :_particleIDs)}(evt, collid, len),
        StructArray{ObjectID{Vertex}, Symbol(bname, "#4")}(evt, collid, len),
        StructArray{ObjectID{ParticleID}, Symbol(bname, "#5")}(evt, collid, len))
    return StructArray{ReconstructedParticle}(columns)
end

function myiteration!(data::MyData, reader, evt)
    data.pevts += 1
    #recps = RootIO.get(reader, evt, "ReconstructedParticles", register=false);
    #recps = getReconstructedParticles_i(evt)
    recps = StructArray{ReconstructedParticle, :ReconstructedParticles}(evt, 0)
    #_muons = RootIO.get(reader, evt, "Muon#0"; btype=_ObjectID{ReconstructedParticle}, register=false)
    #muons = [recps[mid.index+1] for mid in _muons]
    mids = getproperty(evt, Symbol("Muon#0_index"))
    muons = [recps[mid+1] for mid in mids]
    #muons = ReconstructedParticle[]
    #for mid in mids
    #    charge = getproperty(evt, Symbol(bname, :_charge[mid+1]
    #    px = getproperty(evt, Symbol(bname, :_momentum_x[mid+1]
    #    py = getproperty(evt, Symbol(bname, :_momentum_y[mid+1]
    #    pz = getproperty(evt, Symbol(bname, :_momentum_z[mid+1]
    #    energy = getproperty(evt, Symbol(bname, :_energy[mid+1]
    #    push!(muons, ReconstructedParticle(charge=charge, energy=energy, momentum=(px,py,pz)))
    #end

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
    @threads for evt in events
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
#println("Serial total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")

@info "Chunk[$N] 1st run"
@time do_analysis_mt!(mydata, myanalysis!, reader, events);
#Profile.clear_malloc_data()
@info "Chunk[$N] 2nd run"
@time do_analysis_mt!(mydata, myanalysis!, reader, events);
#println("MT[$N](tasking) total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")
 
@info "Threads[$N] 1st run"
@time do_analysis_threads!(mydata, myiteration!, reader, events);
@info "Threads[$N] 2nd run"
@time do_analysis_threads!(mydata, myiteration!, reader, events);
#println("MT[$N](threads) total time: $elapsed, $(mydata.pevts/elapsed) events/s\nSelected events: $(mydata.sevts)")

#@profview do_analysis_mt!(mydata, myanalysis!, events)
#@profview do_analysis_threads!(mydata, myiteration!, events)

#using Parquet2
#Parquet2.writefile("m_H-recoil.parquet", mydata.df)

#using Plots
#histogram(sum_df.Zcand_m)



