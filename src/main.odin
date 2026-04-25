package main

import "core:fmt"

N :: 10
S :: 100

main :: proc() {
    m := mat_init(N)
    n := neigh_list_init(N)
    e := edge_list_init()

    ops := GraphOps{
        data = &n,
        set_edge = neigh_list_set_edge,
        get_edge = neigh_list_get_edge,
        has_edge = neigh_list_has_edge,
        get_neighbours = neigh_list_get_neighbours,
        destroy = neigh_list_destroy
    }

    defer ops.destroy(ops.data)
    
    dag_generate(N, S, ops.set_edge, ops.data)

    // Most basic operations
    matrix_print(N, ops.get_edge, ops.data)
    fmt.eprintln(ops.has_edge(0, 2, ops.data), ops.has_edge(1, 1, ops.data), ops.has_edge(100, 100, ops.data))

    // Traversing through Graph
    fmt.println(bfs(0, N, ops.get_neighbours, ops.data))
    fmt.println(dfs(0, N, ops.get_neighbours, ops.data))

    // Topological sort
    fmt.println(tarjan_sort(N, ops.get_neighbours, ops.data))
    fmt.println(kahn_sort(N, ops.get_neighbours, ops.data))
}
