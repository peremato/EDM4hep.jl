using EDM4hep
using EDM4hep.RootIO
using Base.Iterators: partition, take
using FHist
using Plots: plot, scatter, plot!, theme

finput = joinpath(@__DIR__,"../../examples" ,"ttbar_edm4hep_digi.root")

reader = RootIO.Reader(finput)

events = RootIO.get(reader, "events");

evt = events[1];

for n in names(events) |> sort!
    startswith(n, "ECalBarrelCollection") && println(n)
end

show(reader)

calo = RootIO.get(reader, evt, "AllCaloHitContributionsCombined");
hits = RootIO.get(reader, evt, "ECalBarrelCollection");
mcps = RootIO.get(reader, evt, "MCParticle");

for hit in take(hits, 20)
    println("ECAL Hit $(hit.index) has energy $(hit.energy) at position $(hit.position) with $(length(hit.contributions)) contributions")
end

for hit in hits
    StructArray(hit.contributions).energy |> sum |> c -> c ≈ hit.energy || println("Hit $(hit.index) has energy $(hit.energy) and contributions $(c)")
end

maxE = hits.energy |> maximum
scatter(hits.position.x, hits.position.y, hits.position.z,
        markersize = (hits.energy/maxE)*10, color = :blue)

scatter(hits.position.x, hits.position.y, markersize = (hits.energy/maxE)*10, color = :blue)

using BenchmarkTools
@benchmark hits.energy |> maximum

@benchmark begin
    _max = 0.0f0
    for h in hits
        _max = max(_max, h.energy)
    end
    _max
end
