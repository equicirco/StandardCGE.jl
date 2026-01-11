using Documenter
using StandardCGE

DocMeta.setdocmeta!(StandardCGE, :DocTestSetup, :(using StandardCGE); recursive = true)

makedocs(
    modules = [StandardCGE],
    sitename = "StandardCGE.jl",
    pages = [
        "Home" => "index.md",
        "Using Your Own SAM" => "custom_sam.md",
        "API" => "api.md",
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        logo = "assets/logo-light.png",
        logo_dark = "assets/logo-dark.png",
        assets = [
            "assets/custom.css",
            "assets/deepwiki-chat.css",
            "assets/deepwiki-chat.js",
        ],
    ),
)

deploydocs(
    repo = "github.com/equicirco/StandardCGE.jl.git",
    devbranch = "main",
)
