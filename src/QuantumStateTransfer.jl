module QuantumStateTransfer

using Graphs: AbstractGraph, adjacency_matrix, nv
using LinearAlgebra: I, norm
using PrecompileTools: @setup_workload, @compile_workload

include("ShubertPiyavskii/ShubertPiyavskii.jl")
using .ShubertPiyavskii: maximize_shubert

include("error_messages.jl")
include("unitary_evolution.jl")
include("optimized_state_transfer.jl")
include("precompile_workload.jl")

export UnitaryEvolution, unitary_evolution, track_qubit_amplitude
export OptimizedStateTransfer,
    QubitPairTransfer, optimized_state_transfer, qubit_pair_transfer

end
