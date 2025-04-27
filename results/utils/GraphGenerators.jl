module GraphGenerators

using PyCall

export connected_graphs, connected_regular_graphs, connected_bipartite_graphs

_sage_graph_to_adj_mat(g::PyObject) = g.adjacency_matrix().numpy()

function connected_graphs(order::Int, sage::PyObject)
    graph_gen = sage.graphs.nauty_geng("$order -c -l")
    return Iterators.map(_sage_graph_to_adj_mat, graph_gen)
end

function connected_regular_graphs(order::Int, sage::PyObject)
    valid_degrees = if order == 1
        0:0 # The only degree-1 graph has no edges and is trivially regular
    elseif order == 2
        1:1 # The only connected degree-2 graph has one edge and is regular
    elseif order % 2 == 0
        2:(order - 1) # For even-ordered graphs, any `k` allows `k`-regularity`
    else
        2:2:(order - 1) # For odd-ordered graphs, only even `k`'s allow for `k`-regularity
    end

    graph_gens = map(k -> sage.graphs.nauty_geng("$order -c -l -d$k -D$k"), valid_degrees)
    graph_gen = py"(g for gen in $graph_gens for g in gen)"
    return Iterators.map(_sage_graph_to_adj_mat, graph_gen)
end

function connected_bipartite_graphs(order::Int, sage::PyObject)
    graph_gen = sage.graphs.nauty_geng("$order -c -l -b")
    return Iterators.map(_sage_graph_to_adj_mat, graph_gen)
end

end
