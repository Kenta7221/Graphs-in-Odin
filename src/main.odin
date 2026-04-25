package main

import "core:fmt"

N :: 4
S :: 100

// Check for every implementation init, destroy and has_edge

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

    matrix_print(N, ops.get_edge, ops.data)

    res := bfs(0, N, ops.get_neighbours, ops.data)
    order_print(res)
    fmt.println()

    list := tarjan_sort(N, ops.get_neighbours, ops.data)
    fmt.println(list)
}
