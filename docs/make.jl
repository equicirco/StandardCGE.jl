using Documenter
using StandardCGE

DocMeta.setdocmeta!(StandardCGE, :DocTestSetup, :(using StandardCGE); recursive = true)

makedocs(
    modules = [StandardCGE],
    sitename = "StandardCGE.jl",
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = ["assets/custom.css"],
    ),
)

deploydocs(
    repo = "github.com/equicirco/StandardCGE.jl.git",
    devbranch = "main",
)
