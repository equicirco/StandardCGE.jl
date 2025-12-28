module StandardCGE

##### export main module functions
export SAM_table, starting_values, model_parameters
export load_sam_table, loadSAMTableCSVFile
export compute_starting_values, computeStartingValues
export compute_calibration_params, computeCalibrationParams
export default_sam_path, load_default_sam
export examples_dir, list_examples, load_example
export build_model, solve_model

##### import libraries
using JuMP, CSV, DataFrames, Parameters
using Artifacts
using Ipopt

##### import data structures to set and load parameters
include("data_structures.jl")

##### import functions to load SAMS and compute parameters on SAM
include("SAM_functions.jl")

include("model_setup.jl")

function default_sam_path()
    return normpath(joinpath(@__DIR__, "..", "data", "sam_2_2.csv"))
end

function load_default_sam()
    return load_sam_table(default_sam_path())
end

function examples_dir()
    data_dir = normpath(joinpath(@__DIR__, "..", "data"))
    artifacts_toml = normpath(joinpath(@__DIR__, "..", "Artifacts.toml"))
    if isfile(artifacts_toml)
        artifacts = Artifacts.load_artifacts_toml(artifacts_toml)
        spec = get(artifacts, "standard_cge_examples", nothing)
        if spec !== nothing
            hash = spec["git-tree-sha1"]
            artifact_dir = Artifacts.artifact_path(hash)
            if isdir(artifact_dir)
                return artifact_dir
            end
        end
    end
    return data_dir
end

function list_examples()
    dir = examples_dir()
    return sort(filter(name -> endswith(name, ".csv"), readdir(dir)))
end

function load_example(name::AbstractString; kwargs...)
    dir = examples_dir()
    return load_sam_table(joinpath(dir, name); kwargs...)
end

function build_model(sam_table::SAM_table;
    optimizer = Ipopt.Optimizer,
    optimizer_attributes::Dict{String, Any} = Dict("print_level" => 0, "max_iter" => 3000))
    start = compute_starting_values(sam_table)
    params = compute_calibration_params(sam_table, start)
    CGEmodel = Model(optimizer)
    for (key, value) in optimizer_attributes
        set_optimizer_attribute(CGEmodel, key, value)
    end
    setup_model!(CGEmodel, sam_table, start, params)
    return CGEmodel, start, params
end

function solve_model(sam_table::SAM_table; kwargs...)
    CGEmodel, start, params = build_model(sam_table; kwargs...)
    optimize!(CGEmodel)
    return CGEmodel, start, params
end

end # module
