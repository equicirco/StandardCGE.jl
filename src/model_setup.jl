function setup_model!(CGEmodel::Model, sam_table::SAM_table, start::starting_values, params::model_parameters)
    goods = sam_table.goods
    factors = sam_table.factors

    ##### Variables
    ### with non negativity constraints, eventual lower bounds to avoid division by zero,
    ### eventual starting/initialization values (only some solvers may take advantage of them)
    @variable(CGEmodel, Y[i=goods]>=0.00001, base_name = "composite factor", start = start.Y0[i])
    @variable(CGEmodel, F[h=factors,i=goods]>=0.00001, base_name = "the h-th factor input by the j-th firm", start = start.F0[h,i])
    @variable(CGEmodel, X[i=goods,j=goods]>=0.00001, base_name = "intermediate input", start = start.X0[i,j])
    @variable(CGEmodel, Z[i=goods]>=0.00001, base_name = "output of the j-th good", start = start.Z0[i])
    @variable(CGEmodel, Xp[i=goods]>=0.00001, base_name = "household consumption of the i-th good", start = start.Xp0[i])
    @variable(CGEmodel, Xg[i=goods]>=0.00001, base_name = "government consumption", start = start.Xg0[i])
    @variable(CGEmodel, Xv[i=goods]>=0.00001, base_name = "investment demand", start = start.Xv0[i])
    @variable(CGEmodel, E[i=goods]>=0.00001, base_name = "exports", start = start.E0[i])
    @variable(CGEmodel, M[i=goods]>=0.00001, base_name = "imports", start = start.M0[i])
    @variable(CGEmodel, Q[i=goods]>=0.00001, base_name = "Armington's composite good", start = start.Q0[i])
    @variable(CGEmodel, D[i=goods]>=0.00001, base_name = "domestic good", start = start.D0[i])
    @variable(CGEmodel, pf[h=factors]>=0.00001, base_name = "the h-th factor price", start = Containers.DenseAxisArray(fill(1, length(factors)), vec(factors))[h])
    ### Set the numeraire
    fix(pf[sam_table.numeraire_factor_label], 1; force = true)
    @variable(CGEmodel, py[i=goods]>=0.00001, base_name = "composite factor price", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, pz[i=goods]>=0.00001, base_name = "supply price of the i-th good", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, pq[i=goods]>=0.00001, base_name = "Armington's composite good price", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, pe[i=goods]>=0.00001, base_name = "export price in local currency", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, pm[i=goods]>=0.00001, base_name = "import price in local currency", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, pd[i=goods]>=0.00001, base_name = "the i-th domestic good price", start = Containers.DenseAxisArray(fill(1, length(goods)), vec(goods))[i])
    @variable(CGEmodel, ϵ>=0.00001, base_name = "exchange rate", start = 1)
    @variable(CGEmodel, Sp>=0.00001, base_name = "private saving", start = start.Sp0)
    @variable(CGEmodel, Sg>=0.00001, base_name = "government saving", start = start.Sg0)
    @variable(CGEmodel, Td>=0.00001, base_name = "direct tax", start = start.Td0)
    @variable(CGEmodel, Tz[i=goods]>=0, base_name = "production tax", start = start.Tz0[i])
    @variable(CGEmodel, Tm[i=goods]>=0, base_name = "import tariff", start = start.Tm0[i])


    ##### Constraints
    ###* domestic production
    #   eqpy[i]  'composite factor agg. func.'
    @NLconstraint(CGEmodel, eqpy[i in goods], Y[i] == params.b[i] * prod(F[h,i] ^ params.β[h,i] for h in factors))
    #   eqF[h,i]  'factor demand function'
    @NLconstraint(CGEmodel, eqF[h in factors, i in goods], F[h,i] == params.β[h,i] * py[i] * Y[i] / pf[h])
    #   eqX[i,j]  'intermediate demand function'
    @constraint(CGEmodel, eqX[i in goods, j in goods], X[i,j] == params.ax[i,j] * Z[j])
    #   eqY[i]    'composite factor demand function'
    @constraint(CGEmodel, eqY[i in goods], Y[i] == params.ay[i] * Z[i])
    #   eqpzs[i]  'unit cost function'
    @constraint(CGEmodel, eqpzs[i in goods], pz[i]  == params.ay[i] * py[i] + sum(params.ax[j,i]*pq[j] for j in goods))
    ###* government behavior
    #   eqTd      'direct tax revenue function'
    @constraint(CGEmodel, eqTd, Td == params.τd * sum(pf[h] * start.FF[h] for h in factors))
    #   eqTz[i]   'production tax revenue function'
    @constraint(CGEmodel, eqTz[i in goods], Tz[i] == start.τz[i] * pz[i] * Z[i])
    #   eqTm[i]   'import tariff revenue function'
    @constraint(CGEmodel, eqTm[i in goods], Tm[i] == start.τm[i] * pm[i] * M[i])
    #   eqXg[i]   'government demand function'
    @NLconstraint(CGEmodel, eqXg[i in goods], Xg[i] == params.μ[i] * (Td + sum(Tz[j] for j in goods) + sum(Tm[j] for j in goods) - Sg) / pq[i])
    ###* investment behavior
    #   eqXv[i]   'investment demand function'
    @NLconstraint(CGEmodel, eqXv[i in goods], Xv[i] == params.λ[i] * (Sp + Sg + ϵ * start.Sf) / pq[i])
    ###* savings
    #   eqSp      'private saving function'
    @constraint(CGEmodel, eqSp, Sp == params.ssp * sum(pf[h] * start.FF[h] for h in factors))
    #   eqSg      'government saving function'
    @constraint(CGEmodel, eqSg, Sg == params.ssg * (Td + sum(Tz[i] for i in goods) + sum(Tm[i] for i in goods)))
    ###* household consumption
    #   eqXp[i]   'household demand function'
    @NLconstraint(CGEmodel, eqXp[i in goods], Xp[i] == params.α[i] * (sum(pf[h] * start.FF[h] for h in factors) - Sp - Td) / pq[i])
    ###* international trade
    #   eqpe[i]   'world export price equation'
    @constraint(CGEmodel, eqpe[i in goods], pe[i] == ϵ * start.pWe[i])
    #   eqpm[i]   'world import price equation'
    @constraint(CGEmodel, eqpm[i in goods], pm[i] == ϵ * start.pWm[i])
    #   eqepsilon 'balance of payments'
    @constraint(CGEmodel, eqepsilon, sum(start.pWe[i] * E[i] for i in goods) + start.Sf == sum(start.pWm[i] * M[i] for i in goods))
    ###* Armington function
    #   eqpqs[i]  'Armington function'
    @NLconstraint(CGEmodel, eqpqs[i in goods], Q[i] == params.γ[i] * (params.δm[i] * M[i] ^ params.η[i] + params.δd[i] * D[i] ^ params.η[i]) ^ (1 / params.η[i]))
    #   eqM[i]    'import demand function'
    @NLconstraint(CGEmodel, eqM[i in goods], M[i] == (params.γ[i] ^ params.η[i] * params.δm[i] * pq[i] / ((1 + start.τm[i]) * pm[i])) ^ (1 / (1 - params.η[i])) * Q[i])
    #   eqD[i]    'domestic good demand function'
    @NLconstraint(CGEmodel, eqD[i in goods], D[i] == (params.γ[i] ^ params.η[i] * params.δd[i] * pq[i] / pd[i]) ^ (1 / (1 - params.η[i])) * Q[i])
    ###* transformation function
    #   eqpzd[i]  'transformation function'
    @NLconstraint(CGEmodel, eqpzd[i in goods], Z[i] == params.θ[i] * (params.xie[i] * E[i] ^ params.ϕ[i] + params.xid[i] * D[i] ^ params.ϕ[i]) ^ (1 / params.ϕ[i]))
    #   eqE[i]    'export supply function'
    @NLconstraint(CGEmodel, eqE[i in goods], E[i] == (params.θ[i] ^ params.ϕ[i] * params.xie[i] * (1 + start.τz[i]) * pz[i] / pe[i]) ^ (1 / (1 - params.ϕ[i])) * Z[i])
    #   eqDs[i]   'domestic good supply function'
    @NLconstraint(CGEmodel, eqDs[i in goods], D[i] == (params.θ[i] ^ params.ϕ[i] * params.xid[i] * (1 + start.τz[i]) * pz[i] / pd[i]) ^ (1 / (1 - params.ϕ[i])) * Z[i])
    ###* market clearing condition
    #   eqpqd[i]  'market clearing cond. for comp. good'
    @constraint(CGEmodel, eqpqd[i in goods], Q[i] == Xp[i] + Xg[i] + Xv[i] + sum(X[i,j] for j in goods))
    #   eqpf[h]   'factor market clearing condition'
    @constraint(CGEmodel, eqpf[h in factors], start.FF[h] == sum(F[h,i] for i in goods))

    ##### Objective function
    @NLobjective(CGEmodel, Max, prod(Xp[i] ^ params.α[i] for i in goods))

    return CGEmodel
end
