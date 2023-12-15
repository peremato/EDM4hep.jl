using Revise
using EDM4hep
using EDM4hep.RootIO: Reader,get
using Plots

# To emulate the python collections.defaultdict(list)
append!(d::Dict{String, Vector}, k::String, v::T) where T = haskey(d,k) ? push!(d[k], v) : d[k] = [v]

cd(@__DIR__)
const files = ["ttbar_edm4hep_digi.root", "Output_REC.root"]

all_dists = Dict{String,Vector}()  # Collected distributions

for (i,f) in enumerate(files)
    reader = Reader(f)
    events = get(reader, "events")
    smearing_dists = Vector3d[]   # Position differences between simulation an rconstruction 
    for evt in events
        tracker_hit_coll = get(reader, evt, "VXDTrackerHits")
        sim_tracker_hit_coll = get(reader, evt, "VertexBarrelCollection")
        sim_tracker_hit_rel_coll = get(reader, evt, "VXDTrackerHitRelations")

        for ass in sim_tracker_hit_rel_coll
            diff = ass.rec.position - ass.sim.position
            push!(smearing_dists, diff)
        end
    end
    append!(all_dists, "smearing", smearing_dists)
end

# Lets fill some histograms and plot them
for key in ["smearing"]
    new_dist, old_dist = all_dists[key]
    lay = @layout [°;°;°]
    plot(layout=lay, show=true, size=(1200,1000))
    for (i,l) in enumerate(fieldnames(eltype(new_dist)))
        stephist!(getfield.(new_dist, l), subplot=i, title="Δ$(l)", linewidth=2, label= i==1 ? "Gaudi" : nothing)
        stephist!(getfield.(old_dist, l), subplot=i, linewidth=2, label=i==1 ? "Marlin" : nothing)
    end
end

savefig("results.png")