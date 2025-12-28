```@raw html
<img src="assets/logo.png" class="logo" alt="StandardCGE logo">
```

# StandardCGE.jl

StandardCGE.jl implements the small standard CGE model from the handbook
chapter 6, with utilities to load a SAM from CSV, calibrate parameters, and
solve the model with JuMP/Ipopt.

## Install

```julia
using Pkg
Pkg.add(url="https://github.com/equicirco/StandardCGE.jl")
```

## Quickstart

```julia
using StandardCGE

sam = load_example("sam_2_2.csv")
model, start, params = solve_model(sam)
```

## Load your own SAM

```julia
using StandardCGE

sam = load_sam_table("path/to/your_sam.csv"; goods=["A", "B"], factors=["LAB", "CAP"])
model, start, params = solve_model(sam)
```

For a full walkthrough, see "Using Your Own SAM" in the sidebar.

## Examples

```julia
using StandardCGE

list_examples()
```

## API

- `load_sam_table`
- `list_examples`
- `load_example`
- `build_model`
- `solve_model`
