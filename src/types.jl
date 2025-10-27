# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, modified, or
# distributed except according to those terms.

"""
    NotImplementedError{Nothing}(f, subtype, abstracttype)
    NotImplementedError{Symbol}(f, arg, subtype, abstracttype)

An exception indicating that a function lacks dispatch to handle a specific argument type.

Semantically, this differs from `MethodError` in that it connotes a developer-side failure
to implement a method rather than erroneous user input. Throughout this package, it is often
used to warn when an existing function with multiple dispatch on some abstract type is
called on a newly created subtype for which no method has been defined.

# Fields
- `f::Function`: the function called.
- `arg::Symbol`: the name of the argument with the unsupported type, if the function has
    multiple arguments. If the function has only one argument, this field should be set to
    `nothing`.
- `subtype::Type`: the type of the argument. May be the actual concrete type or some
    intermediate supertype. (For instance, if the relevant input has concrete type `A` with
    hierarchy `A <: B <: C` and the `abstracttype` field is `C`, then both `A` and `B` are
    perfectly valid choices for `subtype`.)
- `abstracttype::Type`: the abstract type under which the argument is meant to fall.

# Constructors
- `NotImplementedError(::Function, ::Type, ::Type)`: constructs a new `NotImplementedError`
    instance for a single-argument function. Throws an error if the second type is not
    abstract or the first type is not a subtype of the second.
- `NotImplementedError(::Function, ::Symbol, ::Type, ::Type)`: constructs a new
    `NotImplementedError` instance for a multi-argument function. Throws an error if the
    second type is not abstract or the first type is not a subtype of the second.

# Supertype Hierarchy
`NotImplementedError` <: `Exception`

# Notes
This struct was taken from one of the authors' other packages, MatrixBandwidth.jl.
"""
struct NotImplementedError{T<:Union{Nothing,Symbol}} <: Exception
    f::Function
    arg::T
    subtype::Type
    abstracttype::Type

    function NotImplementedError(f::Function, subtype::Type, abstracttype::Type)
        return NotImplementedError(f, nothing, subtype, abstracttype)
    end

    function NotImplementedError(
        f::Function, arg::T, subtype::Type, abstracttype::Type
    ) where {T<:Union{Nothing,Symbol}}
        if !isabstracttype(abstracttype)
            throw(ArgumentError("Expected an abstract type, got $abstracttype"))
        end

        if !(subtype <: abstracttype)
            throw(ArgumentError("Expected a subtype of $abstracttype, got $subtype"))
        end

        return new{T}(f, arg, subtype, abstracttype)
    end
end

function Base.showerror(io::IO, e::NotImplementedError{Nothing})
    print(
        io,
        """NotImplementedError with $(e.subtype):
        $(e.f) is not yet implemented for this subtype of $(e.abstracttype).
        Try defining method dispatch manually if this is a newly created subtype.""",
    )
    return nothing
end

function Base.showerror(io::IO, e::NotImplementedError{Symbol})
    print(
        io,
        """NotImplementedError with argument $(e.arg)::$(e.subtype):
        $(e.f) is not yet implemented for this subtype of $(e.abstracttype).
        Try defining method dispatch manually if this is a newly created subtype.""",
    )
    return nothing
end
