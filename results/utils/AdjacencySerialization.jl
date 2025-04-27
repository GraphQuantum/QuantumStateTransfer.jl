module AdjacencySerialization

export serialize, deserialize

function serialize(mats::Vector{BitMatrix})::BitVector
    return collect(Iterators.flatten(Iterators.flatten(mats)))
end

function deserialize(vec::BitVector, k::Int)::Vector{BitMatrix}
    return map(slice -> Matrix(reshape(slice, k, k)), Iterators.partition(vec, k^2))
end

end
