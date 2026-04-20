package main

<<<<<<< HEAD
main :: proc() {
    dag: Dag
    init_dag(&dag, 6, 100)

    print_dag(&dag)

    delete_dag(&dag)
=======
import "core:fmt"

N :: 4
S :: 100

main :: proc() {
    m : AdjMatrix
    m.n = N
    m.mat = make([][]u8, m.n)
    for i in 0..<N do m.mat[i] = make([]u8, m.n)
    generate_dag(N, S, mat_set_edge, &m)

    n := NeighList{lists = make(map[u32][dynamic]u32)}
    generate_dag(N, S, neigh_list_set_edge, &n)

    e := EdgeList{edges = make([dynamic][2]u32)}
    generate_dag(N, S, edge_list_set_edge, &e)

    defer {
        for i in 0..<m.n do delete(m.mat[i]);
        delete(m.mat)

        delete(n.lists)
        delete(e.edges)
    }
    
    dag_print(N, mat_get_edge, &m)  
    fmt.println()

    dag_print(N, neigh_list_get_edge, &n)
    fmt.println()

    dag_print(N, edge_list_get_edge, &e)
    fmt.println()
>>>>>>> 476c775 (Print implementation)
}
