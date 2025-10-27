# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    epsilon_minimize(f, lower, upper, solver)

Converge to within an arbitrary ``ϵ`` of the true global minimum of an ``ℝⁿ → ℝ`` function
`f` over the hyperrectangular domain defined by the bounds `lower` and `upper`, using the
specified ``ϵ``-optimization `solver`.

# Arguments
- `f::Function`: The objective function to be minimized. Must map from `ℝⁿ → ℝ`.
- `lower::Tx<:AbstractVector{<:Real}`: The lower bounds of the hyperrectangular domain.
- `upper::Tx<:AbstractVector{<:Real}`: The upper bounds of the hyperrectangular domain.
- `solver::AbstractEpsilonSolver`: The ``ϵ``-optimization solver to use.

# Returns
- `::EpsilonMinimizationResult{Tx,<:Real}}`: The result of the ``ϵ``-optimization.

# Examples
[TODO: Write here]
"""
function epsilon_minimize(
    f::Function, lower::Tx, upper::Tx, solver::S
) where {Tx<:AbstractVector{<:Real},S<:AbstractEpsilonSolver}
    if length(lower) != length(upper)
        throw(ArgumentError("Lower and upper bounds must have the same dimension"))
    end

    if any(lower .> upper)
        throw(
            ArgumentError("Lower bound must be entrywise less than or equal to upper bound")
        )
    end

    return _epsilon_minimize_impl(f, lower, upper, solver)
end

function _epsilon_minimize_impl(
    ::Function, ::Tx, ::Tx, ::S
) where {Tx<:AbstractVector{<:Real},S<:AbstractEpsilonSolver}
    throw(NotImplementedError(_epsilon_minimize_impl, :solver, S, AbstractEpsilonSolver))
end
