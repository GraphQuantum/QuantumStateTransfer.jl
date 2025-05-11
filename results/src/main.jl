# Copyright 2025 Luis M. B. Varona and Nathaniel Johnston
#
# Licensed under the MIT license <LICENSE-MIT or
# http://opensource.org/licenses/MIT>. This file may not be copied, mofified, or
# distributed except according to those terms.

using QuantumStateTransfer: optimized_state_transfer
using PyCall: PyObject
using JLD2, CodecZstd

include("../utils/SageImporter.jl")
include("../utils/GraphGenerators.jl")
include("../utils/AdjacencySerialization.jl")
using .SageImporter: import_sage
using .GraphGenerators:
    connected_graphs, connected_regular_graphs, connected_bipartite_graphs
using .AdjacencySerialization: serialize, deserialize

const CON_THRESHOLD = 9 # 261080
const REG_THRESHOLD = 13 # 389436
const BIP_THRESHOLD = 12 # 212780

const COMPRESS_LEVEL = 22 # The maximum for ZstdFrameCompressor
const ADJ_MATS_DEST = joinpath(dirname(@__FILE__), "../data/adjacency_matrices.jld2")

function main()
    sage = import_sage()

    if isfile(ADJ_MATS_DEST)
        println("File already exists at `$ADJ_MATS_DEST``.")
    else
        println("Generating adjacency matrices and saving to `$ADJ_MATS_DEST``...")
        _save_adj_mats(sage)
    end

    println("Loading adjacency matrices from `$ADJ_MATS_DEST``...")
    adj_mats_serialized = JLD2.load(ADJ_MATS_DEST)
    adj_mats = Dict(
        k_outer => Dict(
            k_inner => deserialize(v_inner, k_inner) for (k_inner, v_inner) in v_outer
        ) for (k_outer, v_outer) in adj_mats_serialized
    )

    _save_qst_results(sage) # TODO: Still under development
end

function _save_adj_mats(sage::PyObject)
    mkpath(dirname(ADJ_MATS_DEST))

    connected = Dict(
        n => serialize(map(BitMatrix, connected_graphs(n, sage))) for n in 1:CON_THRESHOLD
    )
    con_regular = Dict(
        n => serialize(map(BitMatrix, connected_regular_graphs(n, sage))) for
        n in (CON_THRESHOLD + 1):REG_THRESHOLD
    )
    con_bipartite = Dict(
        n => serialize(map(BitMatrix, connected_bipartite_graphs(n, sage))) for
        n in (REG_THRESHOLD + 1):BIP_THRESHOLD
    )

    jldopen(ADJ_MATS_DEST, "w"; compress=ZstdFrameCompressor(; level=COMPRESS_LEVEL)) do f
        f["connected"] = connected
        f["con_regular"] = con_regular
        f["con_bipartite"] = con_bipartite
    end
end

function _save_qst_results(sage::PyObject)
    # TODO: Iterate over all adjacency matrices and optimize state transfer, saving results
end

main()
