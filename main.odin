package main

import "core:fmt"

N :: 4
S :: 100

main :: proc() {
    // Init
    m : AdjMatrix
    m.n = N
    m.mat = make([][]u8, m.n)
    for i in 0..<N do m.mat[i] = make([]u8, m.n)
    generate_dag(N, S, mat_set_edge, &m)
    defer {
        for i in 0..<m.n do delete(m.mat[i]);
        delete(m.mat)
    }

    n := NeighList{lists = make(map[u32][dynamic]u32)}
    generate_dag(N, S, neigh_list_set_edge, &n)
    defer delete(n.lists)

    e := EdgeList{edges = make([dynamic][2]u32)}
    generate_dag(N, S, edge_list_set_edge, &e)
    defer delete(e.edges)
    
    // Adjustment matrix print
    dag_matrix_print(N, mat_get_edge, &m)
    fmt.println()

    dag_matrix_print(N, neigh_list_get_edge, &n)
    fmt.println()

    dag_matrix_print(N, edge_list_get_edge, &e)
    fmt.println()
    
    // Printing BFS
    neighbours := bfs(0, N, neigh_list_get_neighbour, &n)
    defer delete(neighbours)

    dag_order_print(neighbours)


    //Printing DFS   
}
