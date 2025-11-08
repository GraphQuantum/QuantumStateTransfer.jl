# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    EpsilonOptimization

Optimization algorithms with guaranteed finite ``ϵ``-convergence to the true global minimum
of ``ℝⁿ → ℝ`` functions over hyperrectangular domains.
"""
module EpsilonOptimization

using QuantumStateTransfer: NotImplementedError

using DataStructures: BinaryMinHeap
using LinearAlgebra: norm
using Optim

export
    # Types
    AbstractEpsilonSolver,
    EpsilonMinimizationResult,

    # Core functions
    epsilon_minimize,

    # Solvers
    LipschitzBranchAndBound,
    AlphaBranchAndBound

include("types.jl")
include("utils.jl")
include("core.jl")

include("solvers/lipschitz_branch_and_bound.jl")
include("solvers/alpha_branch_and_bound.jl")

end
