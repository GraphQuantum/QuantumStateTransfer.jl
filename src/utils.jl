# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    is_zerodiag_symmetric(A) -> Bool

Check whether a matrix `A` is symmetric with a zero diagonal.

Supposing that `A` is the adjacency (and walk Hamiltonian) of a graph representing a quantum
spin network, a nonzero diagonal would indicate couplings between qubits and themselves,
which is physically nonsensical. On the other hand, symmetry (Hermicity in the general case,
but we only consider here real-valued adjacency matrices) is required for the transition
matrix ``eⁱᵗᴬ`` to be unitary.

# Arguments
- `A::AbstractMatrix{<:Real}`: The matrix to check.

# Returns
- `::Bool`: `true` if `A` is symmetric with a zero diagonal, and `false` otherwise.

# Examples
[TODO: Write here]
"""
function is_zerodiag_symmetric(A::AbstractMatrix{<:Real})
    (m, n) = size(A)

    return m == n && # Square
           all(iszero, Iterators.map(i -> A[i, i], 1:n)) && # Zero diagonal
           all(A[i, j] == A[j, i] for i in 1:(n - 1) for j in (i + 1):n) # Symmetric
end

"""
    is_simple(g) -> Bool

Check whether a graph `g` is simple (i.e., undirected with no self-loops).

Supposing that `g` represents a quantum spin network (whose walk Hamiltonian is the
adjacency matrix `A` of `g`), self-loops would indicate couplings between qubits and
themselves, which is physically nonsensical. On the other hand, undirectedness is required
for the transition matrix ``eⁱᵗᴬ`` to be unitary.

# Arguments
- `g::AbstractGraph`: The graph to check.

# Returns
- `::Bool`: `true` if `g` is undirected with no self-loops, and `false` otherwise.

# Examples
[TODO: Write here]
"""
function is_simple(g::AbstractGraph)
    return !is_directed(g) && !has_self_loops(g)
end

"""
    transfer_fidelity_deriv_bound(A, order) -> Float64

[TODO: Write here]

# Arguments
[TODO: Write here]

# Returns
[TODO: Write here]

# Notes
[TODO: Proof sketch of bound, plus further relevant references?]
"""
function transfer_fidelity_deriv_bound(A::Matrix{Float64}, order::Int)
    return opnorm(A)^order # Equivalent to `opnorm(A^order)`, since `A` is symmetric
end

"""
    mixing_uniformity_deriv_bound(A, order) -> Float64

[TODO: Write here]

# Arguments
[TODO: Write here]

# Returns
[TODO: Write here]

# Notes
[TODO: Proof sketch of bound, plus further relevant references?]
"""
function mixing_uniformity_deriv_bound(A::Matrix{Float64}, order::Int)
    return 2 * opnorm(A)^order # Equivalent to `2 * opnorm(A^order)`, since `A` is symmetric
end

function _validate_problem_params(
    t_lower::Real,
    t_upper::Real,
    epsilon::Real,
    target_fidelity::Union{Nothing,Real}=nothing,
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

    if !isnothing(target_fidelity)
        if !(0 < target_fidelity <= 1)
            throw(
                ArgumentError(
                    "Target fidelity must be in the interval (0, 1], got $target_fidelity"
                ),
            )
        end
    end

    return nothing
end
