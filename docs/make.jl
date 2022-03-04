using AppDirs
using Documenter

DocMeta.setdocmeta!(AppDirs, :DocTestSetup, :(using AppDirs); recursive=true)

makedocs(;
    modules=[AppDirs],
    authors="Jack Dunn",
    repo="https://github.com/JackDunnNZ/AppDirs.jl/blob/{commit}{path}#{line}",
    sitename="AppDirs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JackDunnNZ.github.io/AppDirs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JackDunnNZ/AppDirs.jl",
    devbranch="main",
)
