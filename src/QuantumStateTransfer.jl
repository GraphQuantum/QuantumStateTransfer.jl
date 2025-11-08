# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    QuantumStateTransfer

A Julia toolbox for modeling state transfer on quantum networks.
"""
module QuantumStateTransfer

using DataStructures
using Graphs
using LinearAlgebra
using PrecompileTools: @setup_workload, @compile_workload

include("utils.jl")
include("types.jl")

include("EpsilonOptimization/EpsilonOptimization.jl")
using .EpsilonOptimization

include("state_transfer.jl")
include("uniform_mixing.jl")
include("fractional_revival.jl")

# TODO: Exports (add more later)
export max_state_transfer, check_state_transfer

include("startup.jl")

end
