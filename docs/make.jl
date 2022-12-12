
originally_active_proj = Base.active_project()

using Pkg
Pkg.activate(@__DIR__)

on_github = (get(ENV, "GITHUB_ACTIONS", "") == "true")
first_run = !isdefined(Main, :first_run_complete)

if !on_github
    first_run && print("Loading Revise … ")
    using Revise
    first_run && println("done")
    build_dir_exists = isdir(joinpath(@__DIR__, "build"))
    if !build_dir_exists
        println("Instantiating docs/Manifest.toml")
        Pkg.instantiate()  # See ReadMe
    end
end

using PkgGraph
using Documenter

if first_run
    # Configure doctests to not need `using PkgGraph` in every example.
    DocMeta.setdocmeta!(PkgGraph, :DocTestSetup, :(using PkgGraph); recursive=true)
end

println("Running makedocs")
makedocs(
    modules = [PkgGraph],
    # ↪ To get a warning if there are any docstrings not mentioned in the markdown.
    sitename = "PkgGraph.jl",
    # ↪ Displayed in page title and navbar.
    doctest = true,
    format = Documenter.HTML(;
        prettyurls = on_github,
        # ↪ When local, generate `/pagename.html`s, not `/pagename`s (i.e. not
        #   `/pagename/index.html`s), so that you don't need a localhost server
        canonical = "https://tfiers.github.io/PkgGraph.jl/stable",
        # ↪ To not have search engines send users to old versions.
        edit_link = "main",
        # ↪ Instead of current commit hash. Let 'em edit main.
        footer = nothing,
        # ↪ Normally "Powered by …"
    ),
    pages=[
        "Home" => "index.md",
        "usage.md",
        "internals.md",
        "background.md",
    ],
)

if on_github
    deploydocs(;
        repo = "github.com/tfiers/PkgGraph.jl",
        devbranch = "main",
        # ↪ What 'Dev' in the version dropdown points to.
    )
end

# Open browser to the generated docs the first time this script is run (included).
if first_run && !on_github
    using DefaultApplication
    DefaultApplication.open(joinpath(@__DIR__, "build", "index.html"))
    first_run_complete = true
end

Pkg.activate(originally_active_proj)
