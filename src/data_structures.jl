"""
    SAM_table

Container for the Social Accounting Matrix (SAM) and its label metadata.
"""
@with_kw struct SAM_table
    ##### Define labels used in CSV file
    # goods / industries
    goods::Vector{String} = ["BRD", "MLK"]
    #goods::Vector{String} = ["AGRI", "MANU", "SERV", "FINA"]
    # production factors
    factors::Vector{String} = ["CAP", "LAB"]
    # the label of the productoin factor for which the price is set = 1 as numerarire
    numeraire_factor_label::String = "LAB"
    # label for the SAM sector where indirect taxes are reported
    indirectTax_label::String = "IDT"
    # label for the SAM sector where import tariffs are reported
    tariff_label::String = "TRF"
    # label for the households sector in SAM 
    households_label::String = "HOH"
    # label for the government sector in SAM
    government_label::String = "GOV"
    # label for the investment sector in SAM
    investment_label::String = "INV"
    # label for the rest of the world sector in SAM
    restOfTheWorld_label::String = "EXT"
    # the SAM table object
    SAM::Containers.DenseAxisArray
 end

"""
    starting_values

Calibrated starting values derived from a SAM table.
"""
@with_kw struct starting_values
    # direct tax
    Td0::Float64
    # production tax
    Tz0::Containers.DenseAxisArray
    # import tariff
    Tm0::Containers.DenseAxisArray
    # factor input by firm
    F0::Containers.DenseAxisArray
    # composite factor
    Y0::Containers.DenseAxisArray
    # intermediate input
    X0::Containers.DenseAxisArray
    # output of good
    Z0::Containers.DenseAxisArray
    # imports
    M0::Containers.DenseAxisArray
    # production tax rate
    τz::Containers.DenseAxisArray
    # import tariff rate
    τm::Containers.DenseAxisArray
    # household consumption
    Xp0::Containers.DenseAxisArray
    # factor endowment
    FF::Containers.DenseAxisArray
    # government consumption
    Xg0::Containers.DenseAxisArray
    # investment demand
    Xv0::Containers.DenseAxisArray
    # exports
    E0::Containers.DenseAxisArray
    # Armington composite good
    Q0::Containers.DenseAxisArray
    # domestic good
    D0::Containers.DenseAxisArray
    # private saving
    Sp0::Float64
    # government saving
    Sg0::Float64
    # foreign saving in foreign currency
    Sf::Float64
    # export price in foreign currency
    pWe::Containers.DenseAxisArray
    # import price in foreign currency
    pWm::Containers.DenseAxisArray
 end

"""
    model_parameters

Calibrated model parameters derived from a SAM table and starting values.
"""
@with_kw struct model_parameters
    # elasticity of substitution
    σ::Containers.DenseAxisArray
    # elastictiy of transformation
    ψ::Containers.DenseAxisArray
    # parameter for the elasticity of substitution
    η::Containers.DenseAxisArray
    # parameter for the elasticity of transformation
    ϕ::Containers.DenseAxisArray
    # share parameter of the utility function
    α::Containers.DenseAxisArray
    # share parameter of the production function
    β::Containers.DenseAxisArray
    # scale parameter of the production function
    b::Containers.DenseAxisArray
    # coefficient of the required intermediate input
    ax::Containers.DenseAxisArray
    # coefficient of the required composite factor input
    ay::Containers.DenseAxisArray
    # share of government consumption
    μ::Containers.DenseAxisArray
    # share of investment demand
    λ::Containers.DenseAxisArray
    # share parameter of imports in the Armington function
    δm::Containers.DenseAxisArray
    # share parameter of domestic goods in the Armington function
    δd::Containers.DenseAxisArray
    # scale parameter of the Amington function
    γ::Containers.DenseAxisArray
    # share parameter of domestic goods in the transformation function
    xid::Containers.DenseAxisArray
    # share parameter of exports in the transformation function
    xie::Containers.DenseAxisArray
    # scale parameter of the transformation function
    θ::Containers.DenseAxisArray
    # average private saving propensity
    ssp::Float64
    # average government saving propensity
    ssg::Float64
    # direct tax rate
    τd::Float64
 end
