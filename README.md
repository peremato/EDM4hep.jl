[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https:///peremato.github.io/EDM4hep.jl/dev/)
[![Build Status](https://github.com/peremato/EDM4hep.jl/workflows/CI/badge.svg)](https://github.com/peremato/EDM4hep.jl/actions)
[![codecov](https://codecov.io/gh/peremato/EDM4hep.jl/graph/badge.svg?token=AS74WXOYT6)](https://codecov.io/gh/peremato/EDM4hep.jl)

# EDM4hep in Julia
Prototype of the [EDM4hep](https://github.com/key4hep/EDM4hep) (generic Event Data Model for HEP experiments part of Key4hep) for Julia with the goal to have very simple structures (isbits) with the purpose to evaluate its ergonomic design and implementation performance.

See presentations: 
- [FCC Software meeting 26/2/2024](https://indico.cern.ch/event/1351111/contributions/5687785/attachments/2807853/4899861/EDM4hep.jl-20240226.pdf)
- [EDM4hep developers 26/03/2024](https://indico.cern.ch/event/1398635/contributions/5879405/attachments/2826751/4938272/EDM4hep.jl-20240326.pdf) 

## Installation
The package has been registered in the General Julia registry therefore its installation is simply using the `Pkg` packager manager.
```
julia -e ‘import Pkg; Pkg.add(“EDM4hep”)’
```

## Getting Started
```julia
julia> using EDM4hep
julia> using EDM4hep.RootIO
julia> file = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
julia> reader = RootIO.Reader(file)
┌───────────────┬────────────────────────────────────────────────────────────────────────────────────────────┐
│ Attribute     │ Value                                                                                      │
├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────┤
│ File Name(s)  │ root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter202....     │
│ n of events   │ 100000                                                                                      
│ IO Format     │ TTree                                                                                      │
│ PODIO version │ 0.16.2                                                                                     │
│ ROOT version  │ 6.26.6                                                                                     │
└───────────────┴────────────────────────────────────────────────────────────────────────────────────────────
julia> events = RootIO.get(reader, "events");
julia> evt = events[1];
julia> recps = RootIO.get(reader, evt, "ReconstructedParticles");
julia> recps.energy[1:5]
5-element Vector{Float32}:
...
```
