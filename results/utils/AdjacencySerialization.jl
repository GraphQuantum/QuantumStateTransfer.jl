# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE or
# http://opensource.org/licenses/MIT>. This file may not be copied, mofified, or
# distributed except according to those terms.

module AdjacencySerialization

export serialize, deserialize

function serialize(mats::Vector{BitMatrix})::BitVector
    return collect(Iterators.flatten(Iterators.flatten(mats)))
end

function deserialize(vec::BitVector, k::Int)::Vector{BitMatrix}
    return map(slice -> Matrix(reshape(slice, k, k)), Iterators.partition(vec, k^2))
end

end
