using Documenter
using Literate
using EDM4hep
using EDM4hep.RootIO

gen_content_dir = joinpath(@__DIR__, "src")
tutorial_edm = joinpath(@__DIR__, "src", "tutorial_edm_lit.jl")
Literate.markdown(tutorial_edm, gen_content_dir, name = "tutorial_edm", documenter = true, credit = true)
Literate.notebook(tutorial_edm, gen_content_dir, execute = false, name = "tutorial_edm", documenter = true, credit = true)
Literate.script(tutorial_edm, gen_content_dir, keep_comments = false, name = "tutorial_edm", documenter = true, credit = false)

makedocs(;
    modules=[EDM4hep, EDM4hep.RootIO],
    format = Documenter.HTML(
        prettyurls = Base.get(ENV, "CI", nothing) == "true",
        repolink="https://github.com/JuliaHEP/EDM4hep.jl",
    ),
    pages=[
        "Introduction" => "index.md",
        "Tutorial (EDM)" => "tutorial_edm.md",
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
