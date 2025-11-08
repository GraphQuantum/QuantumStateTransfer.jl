# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    AbstractEpsilonSolver

Abstract base type for all ``ϵ``-optimization solvers.

# Interface
Concrete subtypes of `AbstractEpsilonSolver` must implement the following methods:
- `Base.summary(::T) where {T<:AbstractAlgorithm}`: returns a `String` indicating the name
    of the algorithm (e.g., `"Lipschitz branch-and-bound"`).

Concrete subtypes of `AbstractEpsilonSolver` must also have the following fields:
- `epsilon::Real`: The tolerance for ``ϵ``-convergence.
- `target::Union{<:Real,Nothing}`: An optional threshold value resulting in termination once
    either (1) a function value less than `target + epsilon` is found or (2) it is
    determined that no function value less than or equal to `target` exists.
- `max_iterations::Union{<:Integer,Nothing}`: An optional maximum number of iterations after
    which the algorithm will terminate.
"""
abstract type AbstractEpsilonSolver end

"""
    EpsilonMinimizationResult{Tx,Tf}

Output struct for ``ϵ``-optimization results.

# Fields
- `algorithm::AbstractEpsilonSolver`: The algorithm used for the optimization.
- `lower::Tx<:AbstractVector{<:Real}}`: The lower bounds of the hyperrectangular domain.
- `upper::Tx<:AbstractVector{<:Real}}`: The upper bounds of the hyperrectangular domain.
- `epsilon::Real`: The tolerance provided for ``ϵ``-convergence.
- `minimizer::Tx<:AbstractVector{<:Real}}`: The estimated location of the global minimizer.
- `minimum::Tf<:Real`: The estimated global minimum function value.
- `stopped_by::NamedTuple`: The reason(s) for termination, namely:
    - `:epsilon_optimal::Bool`: Whether ``ϵ``-optimality was achieved.
    - `:target_reached::Bool`: Whether ta function value less than `target + epsilon` was
        found for some optionally provided `target`.
    - `:target_unreachable::Bool`: Whether it was determined that no function value less
        than or equal to `target` existed for some optionally provided `target`.
    - `:iterations::Bool`: Whether termination occurred due to reaching the maximum number
        of iterations for some optionally provided `max_iterations`.
"""
struct EpsilonMinimizationResult{Tx<:AbstractVector{<:Real},Tf<:Real}
    algorithm::AbstractEpsilonSolver
    lower::Tx
    upper::Tx
    epsilon::Real
    minimizer::Tx
    minimum::Tf
    stopped_by::NamedTuple{
        (:epsilon_optimal, :target_reached, :target_unreachable, :iterations),
        Tuple{Bool,Bool,Bool,Bool},
    }
end

function Base.show(io::IO, res::EpsilonMinimizationResult)
    println(io, "Results of Epsilon Minimization Algorithm")
    print(io, " * Status: ")

    if res.stopped_by.epsilon_optimal || res.stopped_by.target_reached
        println(io, "success")
    else
        println(io, "failure")
    end

    println(io, " * Algorithm: $(summary(res.algorithm))")
    println(io, " * Lower bounds: $(res.lower)")
    println(io, " * Upper bounds: $(res.upper)")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Minimizer: $(res.minimizer)")
    println(io, " * Minimum: $(res.minimum)")

    return nothing
end
