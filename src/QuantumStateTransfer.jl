# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, mofified, or
# distributed except according to those terms.

module QuantumStateTransfer

using Graphs
using LinearAlgebra
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
