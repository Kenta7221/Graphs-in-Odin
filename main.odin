package main

import "core:fmt"

N :: 4
S :: 100

// Check for every implementation init, destroy and has_edge

main :: proc() {
    m := mat_init(N)

    ops := GraphOps{
        data = &m,
        set_edge = mat_set_edge,
        get_edge = mat_get_edge,
        has_edge = mat_has_edge,
        get_neighbours = mat_get_neighbours,
        destroy = mat_destroy
    }

    defer ops.destroy(ops.data)

    generate_dag(N, S, ops.set_edge, ops.data)
    dag_matrix_print(N, ops.get_edge, ops.data)

    fmt.println(ops.has_edge(0, 1, ops.data))
}
