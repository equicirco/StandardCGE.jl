using Test
using StandardCGE
using JuMP
using MathOptInterface

const MOI = MathOptInterface

@testset "Examples and paths" begin
    @test isdir(examples_dir())
    @test isfile(default_sam_path())
    examples = list_examples()
    @test "sam_2_2.csv" in examples
    @test "sam_4_2.csv" in examples
end

@testset "Load SAM tables" begin
    sam = load_example("sam_2_2.csv")
    @test sam isa SAM_table
    @test length(sam.goods) == 2
    @test length(sam.factors) == 2
    @test sam.numeraire_factor_label in sam.factors

    io = IOBuffer(read(default_sam_path()))
    sam_io = load_sam_table(io)
    @test sam_io.goods == sam.goods
    @test sam_io.factors == sam.factors
end

@testset "Build and solve small SAM" begin
    sam = load_example("sam_2_2.csv")
    model, start, params = solve_model(sam)
    @test model isa Model
    @test start isa starting_values
    @test params isa model_parameters
    @test termination_status(model) in (MOI.OPTIMAL, MOI.LOCALLY_SOLVED)
    @test primal_status(model) == MOI.FEASIBLE_POINT
    @test isfinite(objective_value(model))
end
