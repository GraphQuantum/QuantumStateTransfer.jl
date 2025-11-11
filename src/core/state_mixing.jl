# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    StateMixingMaximizationResult{Tn}

[TODO: Write here]
"""
struct StateMixingMaximizationResult{Tn<:Union{AbstractGraph,Matrix{Float64}}}
    network::Tn
    node::Int
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    maximizer::Float64
    max_uniformity::Float64
end

function Base.show(io::IO, res::StateMixingMaximizationResult)
    println(io, "Results of State Mixing Maximization")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Node: $(res.node)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Maximizing time: $(res.maximizer)")
    println(io, " * Maximum uniformity: $(res.max_mixing)")

    return nothing
end

"""
    StateMixingRecognitionResult{Tn}

[TODO: Write here]
"""
struct StateMixingRecognitionResult{Tn<:Union{AbstractGraph,Matrix{Float64}}}
    network::Tn
    node::Int
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    target_uniformity::Float64
    achieved::Bool
    time_achieved::Union{Nothing,Float64}
    uniformity_achieved::Union{Nothing,Float64}
end

function Base.show(io::IO, res::StateMixingRecognitionResult)
    println(io, "Results of State Mixing Recognition")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Node: $(res.node)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Target uniformity: $(res.target_uniformity)")
    println(io, " * Achieved: $(res.achieved)")

    if res.achieved
        println(io, " * Time achieved: $(res.time_achieved)")
        println(io, " * Uniformity achieved: $(res.uniformity_achieved)")
    end

    return nothing
end

"""
    maximize_state_mixing(g::AbstractGraph, args...) -> StateMixingMaximizationResult
    maximize_state_mixing(A::AbstractMatrix{<:Real}, args...) -> StateMixingMaximizationResult

[TODO: Write here]

# Arguments
[TODO: Write here]

# Optional Arguments
[TODO: Write here]

# Raises
[TODO: Write here]

# Returns
[TODO: Write here]

# Examples
[TODO: Write here]

# Notes
[TODO: Refer to [`mixing_uniformity_deriv_bound`](@ref) for proof sketch of bounds]
"""
function maximize_state_mixing(g::AbstractGraph, args...)
    if !is_simple(g)
        throw(ArgumentError("Graph must be undirected with no self-loops"))
    end

    return maximize_state_mixing(adjacency_matrix(g), args...)
end

function maximize_state_mixing(
    A::AbstractMatrix{<:Real},
    node::Integer,
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    method::Symbol=:lipschitz_bb,
)
    if !is_zerodiag_symmetric(A)
        throw(ArgumentError("Matrix must be symmetric with zero diagonal"))
    end

    _validate_problem_params(t_lower, t_upper, epsilon)

    input = _preprocess_state_mixing_input(A, node, t_lower, t_upper, epsilon, method)
    res = _optimize_state_mixing_impl(input)

    return StateMixingMaximizationResult(
        input.A,
        input.node,
        input.t_lower,
        input.t_upper,
        input.epsilon,
        res.minimizer[1],
        1 - res.minimum,
    )
end

"""
    check_state_mixing(g::AbstractGraph, args...) -> StateMixingRecognitionResult
    check_state_mixing(A::AbstractMatrix{<:Real}, args...) -> StateMixingRecognitionResult

[TODO: Write here]

# Arguments
[TODO: Write here]

# Optional Arguments
[TODO: Write here]

# Raises
[TODO: Write here]

# Returns
[TODO: Write here]

# Examples
[TODO: Write here]

# Notes
[TODO: Refer to [`mixing_uniformity_deriv_bound`](@ref) for proof sketch of bounds]
"""
function check_state_mixing(g::AbstractGraph, args...)
    if !is_simple(g)
        throw(ArgumentError("Graph must be undirected with no self-loops"))
    end

    return check_state_mixing(adjacency_matrix(g), args...)
end

function check_state_mixing(
    A::AbstractMatrix{<:Real},
    node::Integer,
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    target_uniformity::Real,
    method::Symbol=:lipschitz_bb,
)
    if !is_zerodiag_symmetric(A)
        throw(ArgumentError("Matrix must be symmetric with zero diagonal"))
    end

    _validate_problem_params(t_lower, t_upper, epsilon, target_uniformity)

    input = _preprocess_state_mixing_input(
        A, node, t_lower, t_upper, epsilon, method, target_uniformity
    )
    res = _optimize_state_mixing_impl(input)

    achieved = res.minimum <= 1.0 - target_uniformity + 1e-8

    if achieved
        time_achieved = res.minimizer[1]
        uniformity_achieved = 1 - res.minimum
    else
        time_achieved = nothing
        uniformity_achieved = nothing
    end

    return StateMixingRecognitionResult(
        input.A,
        input.node,
        input.t_lower,
        input.t_upper,
        input.epsilon,
        target_uniformity,
        achieved,
        time_achieved,
        uniformity_achieved,
    )
end

struct _StateMixingProblemInput
    A::Matrix{Float64}
    node::Int
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    method::Symbol
    target_uniformity::Union{Nothing,Float64}
end

function _preprocess_state_mixing_input(
    A::AbstractMatrix{<:Real},
    node::Integer,
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    method::Symbol,
    target_uniformity::Union{Nothing,Real}=nothing,
)
    A = Matrix{Float64}(A)
    node = Int(node)
    t_lower = Float64(t_lower)
    t_upper = Float64(t_upper)
    epsilon = Float64(epsilon)

    if !isnothing(target_uniformity)
        target_uniformity = Float64(target_uniformity)
    end

    return _StateMixingProblemInput(
        A, node, t_lower, t_upper, epsilon, method, target_uniformity
    )
end

function _optimize_state_mixing_impl(input::_StateMixingProblemInput)
    A = input.A
    node = input.node
    t_lower = input.t_lower
    t_upper = input.t_upper
    epsilon = input.epsilon
    method = input.method
    target_uniformity = input.target_uniformity

    if isnothing(target_uniformity)
        target_nonuniformity = nothing
    else
        target_nonuniformity = 1.0 - target_uniformity
    end

    if method == :lipschitz_bb
        lipschitz_const = mixing_uniformity_deriv_bound(A, 1)
        solver = LipschitzBranchAndBound(
            epsilon, lipschitz_const; target=target_nonuniformity
        )
    elseif method == :alpha_bb
        alpha = mixing_uniformity_deriv_bound(A, 2) / 2
        solver = AlphaBranchAndBound(epsilon, alpha; target=target_nonuniformity)
    else
        throw(
            ArgumentError(
                "Unsupported epsilon-convergent optimization method; must be `:lipschitz_bb` or `:alpha_bb`",
            ),
        )
    end

    eigenvals, eigenvecs = eigen(A)
    right = eigenvecs[:, node]
    n = size(A, 1)
    perf_mixed = fill(1 / n, n)

    function nonuniformity(t::Vector{Float64})
        diff = abs2.(eigenvecs * Diagonal(exp.(im * t[1] * eigenvals)) * right) - perf_mixed
        return 1 - norm(diff)
    end

    return epsilon_minimize(nonuniformity, [t_lower], [t_upper], solver)
end
