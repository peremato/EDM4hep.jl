using Documenter
using Literate
using EDM4hep
using EDM4hep.RootIO

for nb in ("edm","io" )
    src = joinpath(@__DIR__, "src", "tutorial_$(nb)_lit.jl")
    Literate.notebook(src, joinpath(@__DIR__, "src"), execute = false, name = "tutorial_$(nb)", documenter = true, credit = true)
    Literate.script(src, joinpath(@__DIR__, "src"), keep_comments = false, name = "tutorial_$(nb)", documenter = true, credit = false)
    Literate.markdown(src, joinpath(@__DIR__, "src"), name = "tutorial_$(nb)", documenter = true, credit = true)
end

makedocs(;
    modules=[EDM4hep, EDM4hep.RootIO],
    format = Documenter.HTML(
        prettyurls = Base.get(ENV, "CI", nothing) == "true",
        repolink="https://github.com/JuliaHEP/EDM4hep.jl",
    ),
    pages=[
        "Introduction" => "index.md",
        "Tutorial (EDM)" => "tutorial_edm.md",
        "Tutorial (I/O)" => "tutorial_io.md",
        "Public APIs" => "api.md",
        "Release Notes" => "release_notes.md",
    ],
    checkdocs=:exports,
    repo="https://github.com/JuliaHEP/EDM4hep.jl/blob/{commit}{path}#L{line}",
    sitename="EDM4hep.jl",
    authors="Pere Mato",
)

deploydocs(;
    repo="github.com/JuliaHEP/EDM4hep.jl",
    push_preview = true
)
