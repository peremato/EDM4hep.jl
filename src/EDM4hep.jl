"""
Main module for `EDM4hep.jl` -- Key4hep Event Data Model for Julia.

All data model types are exported from this module for public use

# Exports

"""
module EDM4hep

    include("Components.jl")
    include("Datatypes.jl")
    include("EDStore.jl")
    include("RootIO.jl")
    include("SystemOfUnits.jl")
    include("Histograms.jl")
    include("Analysis.jl")
    
end # module EDM4hep
