# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    AlphaBranchAndBound <: AbstractEpsilonSolver

[TODO: Write here]
"""
struct AlphaBranchAndBound <: AbstractEpsilonSolver
    epsilon::Real
    threshold::Union{<:Real,Nothing}
    max_iterations::Union{<:Integer,Nothing}
    alpha::Real
end

"""
    ABBHyperrectangle{Tx,Tf}

[TODO: Write here]
"""
struct ABBHyperrectangle{Tx<:AbstractVector{<:Real},Tf<:Real}
    lower::Tx
    upper::Tx
    x_min::Tx
    lower_bound::Tf

    function ABBHyperrectangle(
        lower::Tx, upper::Tx, f::Function, alpha::Real
    ) where {Tx<:AbstractVector{<:Real}}
        f_convex(x::Tx) = f(x) + alpha * sum((x .- lower) .* (upper .- x))
        x0 = lower .+ (upper .- lower) ./ 2

        res = optimize(f_convex, lower, upper, x0, Fminbox(LBFGS()))
        x_min = res.minimizer
        lower_bound = res.minimum

        return new{Tx,typeof(lower_bound)}(lower, upper, x_min, lower_bound)
    end
end

function Base.isless(rect1::ABBHyperrectangle, rect2::ABBHyperrectangle)
    return rect1.lower_bound < rect2.lower_bound
end

function _epsilon_minimize_impl(
    f::Function, lower::Tx, upper::Tx, solver::AlphaBranchAndBound
) where {Tx<:AbstractVector{<:Real}}
    epsilon = solver.epsilon
    alpha = solver.alpha

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

    rect_init = ABBHyperrectangle(lower, upper, f, alpha)
    rects_cand = BinaryMinHeap{ABBHyperrectangle{Tx,typeof(rect_init.lower_bound)}}()
    push!(rects_cand, rect_init)

    minimizer = rect_init.x_min
    minimum = f(rect_init.x_min)
    lower_bound = Inf
    iterations = 0

    while (
        iterations < max_iterations &&
        !isempty(rects_cand) &&
        min(lower_bound, first(rects_cand).lower_bound) <= threshold &&
        minimum - threshold >= epsilon
    )
        rect = pop!(rects_cand)
        f_val = f(rect.x_min)

        if f_val < minimum
            minimizer = rect.x_min
            minimum = f_val
        end

        children = _abb_split_hyperrectangle(rect, f, alpha)

        for child in children
            f_val_child = f(child.x_min)

            if f_val_child < minimum
                minimizer = child.x_min
                minimum = f_val_child
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

function _abb_split_hyperrectangle(rect::ABBHyperrectangle, f::Function, alpha::Real)
    lower = rect.lower
    upper = rect.upper

    dim_split = argmax(upper .- lower)
    mid = lower[dim_split] + (upper[dim_split] - lower[dim_split]) / 2

    lower1 = copy(lower)
    upper1 = copy(upper)
    upper1[dim_split] = mid
    child1 = ABBHyperrectangle(lower1, upper1, f, alpha)

    lower2 = copy(lower)
    upper2 = copy(upper)
    lower2[dim_split] = mid
    child2 = ABBHyperrectangle(lower2, upper2, f, alpha)

    return child1, child2
end
