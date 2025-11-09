# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    StateTransferMaximizationResult{Tn,Ts}

[TODO: Write here]
"""
struct StateTransferMaximizationResult{
    Tn<:Union{AbstractGraph,Matrix{Float64}},Ts<:Union{Int,Tuple{Int,Int}}
}
    network::Tn
    src::Ts
    dst::Ts
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    maximizer::Float64
    max_fidelity::Float64
end

function Base.show(io::IO, res::StateTransferMaximizationResult{Tn,Int}) where {Tn}
    println(io, "Vertex State Transfer Maximization:")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Source vertex: $(res.src)")
    println(io, " * Destination vertex: $(res.dst)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Maximizing time: $(res.maximizer)")
    println(io, " * Maximum fidelity: $(res.max_fidelity)")

    return nothing
end

function Base.show(
    io::IO, res::StateTransferMaximizationResult{Tn,Tuple{Int,Int}}
) where {Tn}
    println(io, "Pair State Transfer Maximization:")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Source vertices: $(res.src)")
    println(io, " * Destination vertices: $(res.dst)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Maximizing time: $(res.maximizer)")
    println(io, " * Maximum fidelity: $(res.max_fidelity)")

    return nothing
end

"""
    StateTransferRecognitionResult{Tn,Ts}

[TODO: Write here]
"""
struct StateTransferRecognitionResult{
    Tn<:Union{AbstractGraph,Matrix{Float64}},Ts<:Union{Int,Tuple{Int,Int}}
}
    network::Tn
    src::Ts
    dst::Ts
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    target_fidelity::Float64
    achieved::Bool
    time_achieved::Union{Nothing,Float64}
    fidelity_achieved::Union{Nothing,Float64}
end

function Base.show(io::IO, res::StateTransferRecognitionResult{Tn,Int}) where {Tn}
    println(io, "Vertex State Transfer Recognition:")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Source vertex: $(res.src)")
    println(io, " * Destination vertex: $(res.dst)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Target fidelity: $(res.target_fidelity)")
    println(io, " * Achieved: $(res.achieved)")

    if res.achieved
        println(io, " * Time achieved: $(res.time_achieved)")
        println(io, " * Fidelity achieved: $(res.fidelity_achieved)")
    end

    return nothing
end

function Base.show(
    io::IO, res::StateTransferRecognitionResult{Tn,Tuple{Int,Int}}
) where {Tn}
    println(io, "Pair State Transfer Recognition:")
    println(io, " * Network: $(summary(res.network))")
    println(io, " * Source vertices: $(res.src)")
    println(io, " * Destination vertices: $(res.dst)")
    println(io, " * Time interval: [$(res.t_lower), $(res.t_upper)]")
    println(io, " * Epsilon tolerance: $(res.epsilon)")
    println(io, " * Target fidelity: $(res.target_fidelity)")
    println(io, " * Achieved: $(res.achieved)")

    if res.achieved
        println(io, " * Time achieved: $(res.time_achieved)")
        println(io, " * Fidelity achieved: $(res.fidelity_achieved)")
    end

    return nothing
end

"""
    max_state_transfer(g::AbstractGraph, args...) -> StateTransferMaximizationResult
    max_state_transfer(A::AbstractMatrix{<:Real}, args...) -> StateTransferMaximizationResult

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
[TODO: Refer to [`transfer_fidelity_deriv_bound`](@ref) for proof sketch of bounds]
"""
function max_state_transfer(g::AbstractGraph, args...)
    if !is_simple(g)
        throw(ArgumentError("Graph must be undirected with no self-loops"))
    end

    return max_state_transfer(adjacency_matrix(g), args...)
end

function max_state_transfer(
    A::AbstractMatrix{<:Real},
    src::Tl,
    dst::Tl,
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    method::Symbol=:lipschitz_bb,
) where {Tl<:Union{Integer,Tuple{Integer,Integer}}}
    if !is_zero_diag_symmetric(A)
        throw(ArgumentError("Matrix must be symmetric with zero diagonal"))
    end

    _validate_state_transfer_params(t_lower, t_upper, epsilon, method)

    input = _preprocess_state_transfer_input(A, src, dst, t_lower, t_upper, epsilon, method)
    res = _optimize_state_transfer_impl(input)

    return StateTransferMaximizationResult(
        input.A,
        input.src,
        input.dst,
        input.t_lower,
        input.t_upper,
        input.epsilon,
        res.minimizer[1],
        1 - res.minimum,
    )
end

"""
    check_state_transfer(g::AbstractGraph, args...) -> StateTransferRecognitionResult
    check_state_transfer(A::AbstractMatrix{<:Real}, args...) -> StateTransferRecognitionResult

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
[TODO: Refer to [`transfer_fidelity_deriv_bound`](@ref) for proof sketch of bounds]
"""
function check_state_transfer(g::AbstractGraph, args...)
    if !is_simple(g)
        throw(ArgumentError("Graph must be undirected with no self-loops"))
    end

    return check_state_transfer(adjacency_matrix(g), args...)
end

function check_state_transfer(
    A::AbstractMatrix{<:Real},
    src::Tl,
    dst::Tl,
    t_lower::Real,
    t_upper::Real,
    target_fidelity::Real,
    epsilon::Real,
    method::Symbol=:lipschitz_bb,
) where {Tl<:Union{Integer,Tuple{Integer,Integer}}}
    if !is_zero_diag_symmetric(A)
        throw(ArgumentError("Matrix must be symmetric with zero diagonal"))
    end

    _validate_state_transfer_params(t_lower, t_upper, epsilon, method, target_fidelity)

    input = _preprocess_state_transfer_input(
        A, src, dst, t_lower, t_upper, epsilon, method, target_fidelity
    )
    res = _optimize_state_transfer_impl(input)

    achieved = res.target_reached

    if achieved
        time_achieved = res.minimizer[1]
        fidelity_achieved = 1 - res.minimum
    else
        time_achieved = nothing
        fidelity_achieved = nothing
    end

    return StateTransferRecognitionResult(
        input.A,
        input.src,
        input.dst,
        input.t_lower,
        input.t_upper,
        input.epsilon,
        target_fidelity,
        achieved,
        time_achieved,
        fidelity_achieved,
    )
end

struct _StateTransferProblemInput{Tl<:Union{Int,Tuple{Int,Int}}}
    A::Matrix{Float64}
    src::Tl
    dst::Tl
    t_lower::Float64
    t_upper::Float64
    epsilon::Float64
    method::Symbol
    target_fidelity::Union{Nothing,Float64}
end

function _validate_state_transfer_params(
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    method::Symbol,
    target_fidelity::Union{Nothing,Float64}=nothing,
)
    if t_lower > t_upper
        throw(
            ArgumentError(
                "Lower time bound must be less than or equal to upper bound, got [$t_lower, $t_upper]",
            ),
        )
    end

    if epsilon <= 0
        throw(ArgumentError("Epsilon tolerance must be positive, got $epsilon"))
    end

    if !(method in (:lipschitz_bb, :alpha_bb))
        throw(
            ArgumentError(
                "Unsupported epsilon-convergent optimization method; must be `:lipschitz_bb` or `:alpha_bb`, got $method",
            ),
        )
    end

    if !isnothing(target_fidelity)
        if !(0 < target_fidelity <= 1)
            throw(
                ArgumentError(
                    "Target fidelity must be in the interval (0, 1], got $target_fidelity"
                ),
            )
        end
    end
end

function _preprocess_state_transfer_input(
    A::AbstractMatrix{<:Real},
    src::Tl,
    dst::Tl,
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    method::Symbol,
    target_fidelity::Union{Nothing,Float64}=nothing,
) where {Tl<:Union{Integer,Tuple{Integer,Integer}}}
    A = Matrix{Float64}(A)
    src = _preprocess_label(src)
    dst = _preprocess_label(dst)
    t_lower = Float64(t_lower)
    t_upper = Float64(t_upper)
    epsilon = Float64(epsilon)

    return _StateTransferProblemInput(
        A, src, dst, t_lower, t_upper, epsilon, method, target_fidelity
    )
end

_preprocess_label(label::Integer) = Int(label)
_preprocess_label(label::Tuple{Integer,Integer}) = Tuple{Int,Int}(label)

_label_to_state(label::Int, buf::UnitRange{Int}) = buf .== label

function _label_to_state(label::Tuple{Int,Int}, buf::UnitRange{Int})
    if allequal(label)
        throw(ArgumentError("Vertex pairs must consist of distinct vertices"))
    end

    return ((buf .== label[1]) - (buf .== label[2])) / sqrt(2)
end

function _optimize_state_transfer_impl(input::_StateTransferProblemInput)
    A = input.A
    t_lower = input.t_lower
    t_upper = input.t_upper
    method = input.method
    epsilon = input.epsilon

    buf = 1:size(A, 1)
    state_src = _label_to_state(input.src, buf)
    state_dst = _label_to_state(input.dst, buf)

    if isnothing(input.target_fidelity)
        target_infidelity = nothing
    else
        target_infidelity = 1 - input.target_fidelity
    end

    if method == :lipschitz_bb
        lipschitz_constant = transfer_fidelity_deriv_bound(A, 1)
        solver = LipschitzBranchAndBound(
            epsilon, lipschitz_constant; target=target_infidelity
        )
    elseif method == :alpha_bb
        alpha = transfer_fidelity_deriv_bound(A, 2) / 2
        solver = AlphaBranchAndBound(epsilon, alpha; target=target_infidelity)
    else
        throw(
            ArgumentError(
                "Unsupported epsilon-convergent optimization method; must be `:lipschitz_bb` or `:alpha_bb`",
            ),
        )
    end

    eigenvals, eigenvecs = eigen(A)
    left = state_src' * eigenvecs
    right = eigenvecs' * state_dst

    function infidelity(t::Vector{Float64})
        return 1 - abs2(left * Diagonal(exp.(im * t[1] * eigenvals)) * right)
    end

    return epsilon_minimize(infidelity, [t_lower], [t_upper], solver)
end
