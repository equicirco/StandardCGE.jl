```@raw html
<img src="assets/logo.png" class="logo" alt="StandardCGE logo">
```

# StandardCGE.jl

Julia implmentation of the Standard CGE model Chapter 6 of Hosoe, N, Gasawa, K, and Hashimoto, H, *Handbook of Computable General Equilibrium Modeling*, University of Tokyo Press, Tokyo, Japan, 2004

StandardCGE.jl implements the small standard CGE model from the handbook chapter 6, with utilities to load a SAM from CSV, calibrate parameters, and solve the model with JuMP/Ipopt.

## What a CGE is?

A **Computable General Equilibrium (CGE)** model is a quantitative economic model that represents an entire economy as a system of interconnected markets of goods and services, of factors of production (e.g., labor and capital), institutions (households, firms, government), and the rest of the world. 

It is *computable* because it is calibrated with data (typically from a Social Accounting Matrix) and solved numerically as a **system of nonlinear equations** (or an equivalent **nonlinear optimization problem**) using a **mathematical solver**, typically a Newton-type algorithm, until the equilibrium conditions (zero-profit, market-clearing, and income-balance constraints) are satisfied within a chosen tolerance.

In a CGE model, economic agents follow explicit behavioral rules (e.g., firms minimize costs, households maximize utility), and **prices adjust so that all markets clear simultaneously**. CGE models are suitable for analyzing how a policy or external shock propagates through the economy, not only in the directly affected sector, but also through input–output linkages, income changes, and price effects.

## Project info

- Source code: [https://github.com/equicirco/StandardCGE.jl](https://github.com/equicirco/StandardCGE.jl)
- License: [https://github.com/equicirco/StandardCGE.jl/blob/main/LICENSE](https://github.com/equicirco/StandardCGE.jl/blob/main/LICENSE)
- Author: Riccardo Boero
- Citation (DOI): [https://doi.org/10.5281/zenodo.18079154](https://doi.org/10.5281/zenodo.18079154)

```bibtex
@software{StandardCGEjl,
  title = {StandardCGE.jl - Julia implementation of the Standard CGE model from Hosoe, Gasawa, and Hashimoto (Chapter 6).},
  author = {Boero, Riccardo},
  doi = {10.5281/zenodo.18079154},
  url = {https://equicirco.github.io/StandardCGE.jl/},
  year = {2025}
}
```

## Installation
StandardCGE.jl is available as a package from the Julia General Registry:
```julia
using Pkg
Pkg.add("StandardCGE")
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
