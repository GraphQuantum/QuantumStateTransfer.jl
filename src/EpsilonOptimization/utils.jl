# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    validate_solver_params(solver)

[TODO: Write here]

# Arguments
[TODO: Write here]

# Raises
[TODO: Write here]

# Returns
[TODO: Write here]
"""
function validate_solver_params(solver::AbstractEpsilonSolver)
    epsilon = solver.epsilon

    if epsilon <= 0
        throw(ArgumentError("Epsilon parameter must be positive, got $epsilon"))
    end

    max_iterations = solver.max_iterations

    if !isnothing(max_iterations) && max_iterations <= 0
        throw(
            ArgumentError(
                "Max iterations must be positive or nothing, got $(max_iterations)"
            ),
        )
    end
end
