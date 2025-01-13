using EDM4hep.RootIO
using EDM4hep.Analysis
using EDM4hep.SystemOfUnits

mutable struct AnalysisData <: AbstractAnalysisData
    all::Int64
    found::Int64
    AnalysisData() = new(0,0)
end

function myanalysis!(data::AnalysisData, reader, events)
    for evt in events
        data.all += 1
        mcparticles = RootIO.get(reader, evt, "MCParticle")
        # search first genStat 1 pion
        idx = findfirst(p -> abs(p.PDG) == 211 && p.generatorStatus == 1, mcparticles)
        mcp = mcparticles[idx]
        if mcp.energy > 2GeV
            data.found += 1
        end
    end
    data
end

@testset "$(T)Analysis" for T in (:TTree,) # (:TTree, :RNTuple)
    if T == :RNTuple
        f = joinpath(@__DIR__, "../examples/Output_REC_rntuple-rc2.root")
    else
        f = joinpath(@__DIR__, "../examples/Output_REC.root")
    end
    
    reader = RootIO.Reader(f)
    events = RootIO.get(reader, "events")

    @test length(split(string(reader),'\n')) > 100    # check the show() method

    mydata1 = AnalysisData()
    @test mydata1.all == 0
    @test mydata1.found == 0

    do_analysis!(mydata1, myanalysis!, reader, events)
    @test mydata1.all > mydata1.found

    mydata2 = AnalysisData()
    @test mydata2.all == 0
    @test mydata2.found == 0

    do_analysis!(mydata2, myanalysis!, reader, events; mt=true)
    @test mydata2.all > mydata2.found
    @test mydata1.found == mydata2.found   
end 


