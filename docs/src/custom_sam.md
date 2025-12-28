# Using Your Own SAM

This page explains how to load a custom Social Accounting Matrix (SAM) with an
arbitrary number of products (goods) and production factors.

## What the loader expects

The CSV file must include a header row with column labels and a first column
with row labels. The loader uses these labels to index the SAM:

- `goods` and `factors` are not inferred from the CSV. You must pass them in
  `load_sam_table(...; goods=..., factors=...)`.
- The CSV must include rows and columns for all `goods`, `factors`, and the
  special sectors listed below.

Required sector labels (defaults shown):

- `indirectTax_label` = `IDT`
- `tariff_label` = `TRF`
- `households_label` = `HOH`
- `government_label` = `GOV`
- `investment_label` = `INV`
- `restOfTheWorld_label` = `EXT`
- `numeraire_factor_label` = `LAB` (must be one of the factor labels)

If your CSV uses different labels, pass them as keyword arguments to
`load_sam_table`.

## Minimal structure example

The table must be square and include all the labels you reference. This
illustrative header shows the kind of layout expected:

```text
Column1,BRD,MLK,CAP,LAB,IDT,TRF,HOH,GOV,INV,EXT
BRD,    ...
MLK,    ...
CAP,    ...
LAB,    ...
IDT,    ...
TRF,    ...
HOH,    ...
GOV,    ...
INV,    ...
EXT,    ...
```

## Loading a custom SAM

```julia
using StandardCGE

goods = ["A", "B", "C"]
factors = ["LAB", "CAP", "LAND"]

sam = load_sam_table(
    "path/to/your_sam.csv";
    goods = goods,
    factors = factors,
    numeraire_factor_label = "LAB",
    indirectTax_label = "IDT",
    tariff_label = "TRF",
    households_label = "HOH",
    government_label = "GOV",
    investment_label = "INV",
    restOfTheWorld_label = "EXT",
)

model, start, params = solve_model(sam)
```

## Common pitfalls

- The SAM must be square and include all labels used in `goods`, `factors`, and
  the special sector labels.
- The `numeraire_factor_label` must match one of the factor labels.
- Missing values are replaced by `0`, but missing rows or columns will cause
  indexing errors.

## Tips for larger SAMs

- Keep goods and factors ordered consistently between the CSV and your lists.
- Start by running `compute_starting_values(sam)` and `compute_calibration_params(sam, start)`
  to catch data issues before solving.
