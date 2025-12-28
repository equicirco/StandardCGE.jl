function load_sam_table(file_path::AbstractString; goods::Vector{String} = ["BRD", "MLK"],
    factors::Vector{String} = ["CAP", "LAB"],
    numeraire_factor_label::String = "LAB",
    indirectTax_label::String = "IDT",
    tariff_label::String = "TRF",
    households_label::String = "HOH",
    government_label::String = "GOV",
    investment_label::String = "INV",
    restOfTheWorld_label::String = "EXT")
    ##### Load the SAM table
    df = DataFrame(CSV.File(file_path))
    for col in eachcol(df)
       replace!(col,missing => 0)
    end
    ##### Return tuple with keyword
    return SAM_table(
        goods = goods,
        factors = factors,
        numeraire_factor_label = numeraire_factor_label,
        indirectTax_label = indirectTax_label,
        tariff_label = tariff_label,
        households_label = households_label,
        government_label = government_label,
        investment_label = investment_label,
        restOfTheWorld_label = restOfTheWorld_label,
        SAM = Containers.DenseAxisArray(
            Matrix(df[:, 2:end]),
            Vector{String}(df[:, "Column1"]),
            Vector{String}(names(df)[2:end])
        )
    )
end

function load_sam_table(io::IO; goods::Vector{String} = ["BRD", "MLK"],
    factors::Vector{String} = ["CAP", "LAB"],
    numeraire_factor_label::String = "LAB",
    indirectTax_label::String = "IDT",
    tariff_label::String = "TRF",
    households_label::String = "HOH",
    government_label::String = "GOV",
    investment_label::String = "INV",
    restOfTheWorld_label::String = "EXT")
    ##### Load the SAM table
    df = DataFrame(CSV.File(io))
    for col in eachcol(df)
       replace!(col,missing => 0)
    end
    ##### Return tuple with keyword
    return SAM_table(
        goods = goods,
        factors = factors,
        numeraire_factor_label = numeraire_factor_label,
        indirectTax_label = indirectTax_label,
        tariff_label = tariff_label,
        households_label = households_label,
        government_label = government_label,
        investment_label = investment_label,
        restOfTheWorld_label = restOfTheWorld_label,
        SAM = Containers.DenseAxisArray(
            Matrix(df[:, 2:end]),
            Vector{String}(df[:, "Column1"]),
            Vector{String}(names(df)[2:end])
        )
    )
end

function compute_starting_values(sam_table::SAM_table)
    sam = sam_table.SAM
    goods = sam_table.goods
    factors = sam_table.factors
    Td0 = sam[sam_table.government_label, sam_table.households_label]
    Tz0 = sam[sam_table.indirectTax_label, goods]
    Tm0 = sam[sam_table.tariff_label, goods]
    F0 = sam[factors, goods]
    Y0 = Containers.DenseAxisArray(vec(sum(F0.data, dims=1)), vec(goods))
    X0 = sam[goods, goods]
    Z0 = vec(sum(X0.data, dims=1)) .+ Y0
    M0 = sam[sam_table.restOfTheWorld_label, goods]
    τz = Tz0 ./ Z0.data
    τm = Tm0 ./ M0
    Xp0 =  sam[goods, sam_table.households_label]
    FF = sam[sam_table.households_label, factors]
    Xg0 = sam[goods, sam_table.government_label]
    Xv0 = sam[goods, sam_table.investment_label]
    E0 = sam[goods, sam_table.restOfTheWorld_label]
    Q0 = Xp0 .+ Xg0 .+ Xv0 .+ vec(sum(X0.data, dims=2))
    D0 = (1 .+ τz) .* Z0 .- E0
    Sp0 = sam[sam_table.investment_label, sam_table.households_label]
    Sg0 = sam[sam_table.investment_label, sam_table.government_label]
    Sf = sam[sam_table.investment_label, sam_table.restOfTheWorld_label]
    pWe = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))
    pWm = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))
    ##### Return tuple with keyword: pWe and pWm are left to default values
    return starting_values(Td0 = Td0, Tz0 = Tz0, Tm0 = Tm0, F0 = F0, Y0 = Y0,
    X0 = X0, Z0 = Z0, M0 = M0, τz = τz, τm = τm, Xp0 = Xp0, FF = FF, Xg0 = Xg0, 
    Xv0 = Xv0, E0 = E0, Q0 = Q0, D0 = D0, Sp0 = Sp0, Sg0 = Sg0, Sf = Sf,
    pWe = pWe, pWm = pWm)
end

function compute_calibration_params(sam_table::SAM_table, start::starting_values)
    goods = sam_table.goods
    σ = Containers.DenseAxisArray(fill(2, length(goods)), vec(goods))
    ψ = Containers.DenseAxisArray(fill(2, length(goods)), vec(goods))
    η = (σ .- 1.0) ./ σ
    ϕ = (ψ .+ 1.0) ./ ψ
    α = start.Xp0 ./ sum(start.Xp0)
    β = start.F0 ./ sum(start.F0.data, dims=1)
    b = start.Y0 ./ vec(prod((start.F0 .^ β).data, dims=1))
    ax = start.X0 ./ transpose(start.Z0.data)
    ay = start.Y0 ./ start.Z0
    μ = start.Xg0 ./ sum(start.Xg0.data)
    λ = start.Xv0 ./ (start.Sp0 .+ start.Sg0 .+ start.Sf)
    δm = (1 .+ start.τm) .* start.M0 .^ (1 .- η) ./ ((1 .+ start.τm) .* start.M0 .^ (1 .- η) .+ start.D0 .^ (1 .- η))
    δd = start.D0 .^ (1 .- η) ./ ((1 .+ start.τm) .* start.M0 .^ (1 .- η) .+ start.D0 .^ (1 .- η))
    γ = start.Q0 ./ (δm .* start.M0 .^ η .+ δd .* start.D0 .^ η) .^ (1 ./ η)
    xie = start.E0 .^ (1 .- ϕ) ./ (start.E0  .^ (1 .- ϕ) .+ start.D0 .^ (1 .- ϕ))
    xid = start.D0 .^ (1 .- ϕ) ./ (start.E0 .^ (1 .- ϕ) .+ start.D0 .^ (1 .- ϕ))
    θ = start.Z0 ./ (xie .* start.E0 .^ ϕ .+ xid .* start.D0 .^ ϕ) .^ (1 ./ ϕ)
    ssp = start.Sp0 ./ sum(start.FF)
    ssg = start.Sg0 ./ (start.Td0 .+ sum(start.Tz0) .+ sum(start.Tm0))
    τd =  start.Td0 ./ sum(start.FF)
    ##### Return named tuple
    return model_parameters(σ = σ, ψ = ψ, η = η, ϕ = ϕ, α = α, β = β, b = b, 
    ax = ax, ay = ay, μ = μ, λ = λ, δm = δm, δd = δd, γ = γ, xid = xid, 
    xie = xie, θ = θ, ssp = ssp, ssg = ssg, τd = τd)
end

function loadSAMTableCSVFile(filePath::String)
    return load_sam_table(filePath)
end

function computeStartingValues(sam_table::SAM_table)
    return compute_starting_values(sam_table)
end

function computeCalibrationParams(sam_table::SAM_table, start::starting_values)
    return compute_calibration_params(sam_table, start)
end
