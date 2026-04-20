package main

import "core:fmt"
import "core:math"
import "core:math/rand"

Dag :: struct {
    adj_mat: [][]u8,
    neigh_list: map[u32][]u32,
    edge_list: []u32,
}

init_dag :: proc(dag: ^Dag, n, s: u32) {
    dag.adj_mat = generate_dag(n, s)
}

delete_dag :: proc(dag: ^Dag) {
    delete(dag.adj_mat)
}

generate_dag :: proc(n : u32, s : u32) -> [][]u8 {
    e_max : u32 = n * (n-1) / 2

    edges := make([][2]u32, e_max);    
    defer { delete(edges) }
    
    idx : u32 = 0
    for i in 0..<n {
	for j in i+1..<n {
	    edges[idx] = [2]u32{i, j}
	    idx += 1
	}
    }

    rand.shuffle(edges)

    e_target : u32 = cast(u32)math.floor(cast(f32)(s) / 100.0 * cast(f32)e_max)

    dag_mat := make([][]u8, n)

    for i in 0..<n do dag_mat[i] = make([]u8, n)
    
    for i in 0..<e_target {
	row := edges[i][0]
	col := edges[i][1]
	dag_mat[row][col] = 1;
    }

    return dag_mat;
}

print_dag :: proc(dag: ^Dag) {
    n := len(dag.adj_mat)

    spaces := "  | "
    fmt.print(spaces, sep = "")
    for i in 0..<n {
	fmt.print(i + 1, " ", sep = "")
    }
    fmt.println()

    for i in 0..<n*2+4 {
	fmt.print("-" if i != 2 else "+")
    }
    fmt.println()

    for i in 0..<n {
	fmt.print(i + 1, "| ")

	for j in 0..<n {
	    fmt.print(dag.adj_mat[i][j], " ", sep = "")
	}
	fmt.println()
    }
}
