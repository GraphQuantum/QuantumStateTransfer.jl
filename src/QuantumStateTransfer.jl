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

include("core.jl")

# TODO: Exports

include("startup.jl")

end
