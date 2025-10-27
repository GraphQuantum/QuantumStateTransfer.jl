# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    LipschitzBranchAndBound <: AbstractEpsilonSolver

[TODO: Write here]
"""
struct LipschitzBranchAndBound <: AbstractEpsilonSolver
    epsilon::Real
    threshold::Union{<:Real,Nothing}
    max_iterations::Union{<:Integer,Nothing}
    lipschitz_constant::Real
end

"""
    LBBHyperrectangle{Tx,Tf}

[TODO: Write here]
"""
struct LBBHyperrectangle{Tx<:AbstractVector{<:Real},Tf<:Real}
    lower::Tx
    upper::Tx
    center::Tx
    f_center::Tf
    lower_bound::Tf

    function LBBHyperrectangle(
        lower::Tx, upper::Tx, f::Function, lipschitz_constant::Real
    ) where {Tx<:AbstractVector{<:Real}}
        center = lower .+ (upper .- lower) ./ 2
        f_center = f(center)
        diameter = norm(upper .- lower)
        lower_bound = f_center - (lipschitz_constant / 2) * diameter
        return new{Tx,typeof(f_center)}(lower, upper, center, f_center, lower_bound)
    end
end

function Base.isless(rect1::LBBHyperrectangle, rect2::LBBHyperrectangle)
    return rect1.lower_bound < rect2.lower_bound
end

function _epsilon_minimize_impl(
    f::Function, lower::Tx, upper::Tx, solver::LipschitzBranchAndBound
) where {Tx<:AbstractVector{<:Real}}
    epsilon = solver.epsilon
    lipschitz_constant = solver.lipschitz_constant

    if isnothing(solver.threshold)
        threshold = -Inf
    else
        threshold = solver.threshold
    end

    if isnothing(solver.max_iterations)
        max_iterations = Inf
    else
        max_iterations = solver.max_iterations
    end

    rect_init = LBBHyperrectangle(lower, upper, f, solver.lipschitz_constant)
    rects_cand = BinaryMinHeap{LBBHyperrectangle{Tx,typeof(rect_init.f_center)}}()
    push!(rects_cand, rect_init)

    minimizer = rect_init.center
    minimum = rect_init.f_center
    lower_bound = Inf
    iterations = 0

    while (
        iterations < max_iterations &&
        !isempty(rects_cand) &&
        min(lower_bound, first(rects_cand).lower_bound) <= threshold &&
        minimum - threshold >= epsilon
    )
        rect = pop!(rects_cand)

        if rect.f_center < minimum
            minimizer = rect.center
            minimum = rect.f_center
        end

        children = _lbb_split_hyperrectangle(rect, f, lipschitz_constant)

        for child in children
            if child.f_center < minimum
                minimizer = child.center
                minimum = child.f_center
            end

            if minimum - child.lower_bound >= epsilon
                push!(rects_cand, child)
            else
                lower_bound = min(lower_bound, child.lower_bound)
            end
        end

        iterations += 1
    end

    if !isempty(rects_cand)
        lower_bound = min(lower_bound, first(rects_cand).lower_bound)
    end

    return EpsilonMinimizationResult(
        solver,
        epsilon,
        lower,
        upper,
        minimizer,
        minimum,
        (
            epsilon_optimal=minimum - lower_bound < epsilon,
            threshold_reached=minimum - threshold < epsilon,
            threshold_unreachable=lower_bound > threshold,
            iterations=iterations >= max_iterations,
        ),
    )
end

function _lbb_split_hyperrectangle(
    rect::LBBHyperrectangle, f::Function, lipschitz_constant::Real
)
    lower = rect.lower
    upper = rect.upper

    dim_split = argmax(upper .- lower)
    mid = lower[dim_split] + (upper[dim_split] - lower[dim_split]) / 2

    lower1 = copy(lower)
    upper1 = copy(upper)
    upper1[dim_split] = mid
    child1 = LBBHyperrectangle(lower1, upper1, f, lipschitz_constant)

    lower2 = copy(lower)
    upper2 = copy(upper)
    lower2[dim_split] = mid
    child2 = LBBHyperrectangle(lower2, upper2, f, lipschitz_constant)

    return child1, child2
end
