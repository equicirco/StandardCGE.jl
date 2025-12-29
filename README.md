<img src="docs/assets/logo.png" alt="StandardCGE logo" width="180">

# StandardCGE.jl
Julia implementation of the standard CGE model from Hosoe, Gasawa, and Hashimoto (Chapter 6).

## What a CGE is?
A **Computable General Equilibrium (CGE)** model is a quantitative economic model that represents an entire economy as a system of interconnected markets of goods and services, of factors of production (e.g., labor and capital), institutions (households, firms, government), and the rest of the world. 

It is *computable* because it is calibrated with data (typically from a Social Accounting Matrix) and solved numerically as a **system of nonlinear equations** (or an equivalent **nonlinear optimization problem**) using a **mathematical solver**, typically a Newton-type algorithm, until the equilibrium conditions (zero-profit, market-clearing, and income-balance constraints) are satisfied within a chosen tolerance.

In a CGE model, economic agents follow explicit behavioral rules (e.g., firms minimize costs, households maximize utility), and **prices adjust so that all markets clear simultaneously**. CGE models are suitable for analyzing how a policy or external shock propagates through the economy, not only in the directly affected sector, but also through input–output linkages, income changes, and price effects.

## Documentation
https://equicirco.github.io/StandardCGE.jl

## License
MIT License. See [`LICENSE`](LICENSE).

## Citation
If you use this software, please cite:

```bibtex
@software{StandardCGEjl,
  title = {StandardCGE.jl - Julia implementation of the Standard CGE model from Hosoe, Gasawa, and Hashimoto (Chapter 6).},
  author = {Boero, Riccardo},
  doi = {10.5281/zenodo.18079154},
  url = {https://equicirco.github.io/StandardCGE.jl/}
}
```

## Acknowledgments
This project was initiated with the generous support of a SIS internal project from [NILU](https://nilu.com). Their support was crucial in starting this research and development effort.

## Author
Riccardo Boero (ribo@nilu.no)
