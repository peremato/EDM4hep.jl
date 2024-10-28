using Documenter
using EDM4hep
using EDM4hep.RootIO

makedocs(;
    modules=[EDM4hep, EDM4hep.RootIO],
    format = Documenter.HTML(
        prettyurls = Base.get(ENV, "CI", nothing) == "true",
        repolink="https://github.com/JuliaHEP/EDM4hep.jl",
    ),
    pages=[
        "Introduction" => "index.md",
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
