package main

import "core:fmt"
import "core:math"
import "core:slice"
import "core:math/rand"
import "core:container/intrusive/list"

AdjMatrix :: struct { mat: [][]u8, n: uint }

mat_set_edge :: proc(i, j: u32, data: rawptr) {
    m := cast(^AdjMatrix)data
    m.mat[i][j] = 1
}

mat_get_edge :: proc(i, j: u32, data: rawptr) -> u8 {
    m := cast(^AdjMatrix)data
    return m.mat[i][j]
}

mat_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    m := cast(^AdjMatrix)data

    neighbour: [dynamic]u32

    for i in 0..<m.n {
        if m.mat[node][i] == 1 do append_elem(&neighbour, cast(u32)i)
    }

    return neighbour
}

NeighList :: struct { lists: map[u32][dynamic]u32 }

neigh_list_set_edge :: proc(i, j: u32, data: rawptr) {
    l := cast(^NeighList)data
    arr := l.lists[i]
    append(&arr, j)
    l.lists[i] = arr
}

neigh_list_get_edge :: proc(i, j: u32, data: rawptr) -> u8 {
    n := cast(^NeighList)data
    arr := n.lists[i]
    
    for edge in arr {
        if edge == j do return 1
    }

    return 0
}

neigh_list_get_neighbour :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    n := cast(^NeighList)data
    return n.lists[node]
}

EdgeList :: struct { edges: [dynamic][2]u32 }

edge_list_set_edge :: proc(i, j: u32, data: rawptr) {
    l := cast(^EdgeList)data
    append_elem(&l.edges, [2]u32{cast(u32)i, cast(u32)j})
}

edge_list_get_edge :: proc(i, j: u32, data: rawptr) -> u8 {
    l := cast(^EdgeList)data
    
    for pair in l.edges {
        if pair[0] == i && pair[1] == j do return 1
    }

    return 0
}

edge_list_get_neighbour :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    l := cast(^EdgeList)data
    neighbour: [dynamic]u32

    for e in l.edges {
        if e[0] == node do append_elem(&neighbour, e[1])
    }

    return neighbour
}

generate_dag :: proc(n : u32, s : u32, set_edge: proc(i, j: u32, data: rawptr), data: rawptr) {
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
   
    for i in 0..<e_target do set_edge(edges[i][0], edges[i][1], data)
}

dag_matrix_print :: proc(n: u32, has_edge: proc(i, j: u32, data: rawptr) -> u8, data: rawptr) {
    if n == 0 { return }

    spaces := "  | "
    fmt.print(spaces, sep = "")
    for i in 0..<n {
	    fmt.print(i, " ", sep = "")
    }
    fmt.println()

    for i in 0..<n*2+4 {
	    fmt.print("-" if i != 2 else "+")
    }
    fmt.println()

    for i in 0..<n {
	    fmt.print(i, "| ")

	    for j in 0..<n {
            fmt.print(has_edge(i, j, data), " ", sep = "")
	    }

	    fmt.println()
    }
}

dag_order_print :: proc(neighbours: [dynamic]u32) {
    for nb in neighbours {
        fmt.print(nb, " ", sep = "")
    }
}

bfs :: proc(start, n: u32, get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32, data: rawptr) -> [dynamic]u32 {
    visited := make([]bool, n)
    defer delete(visited)

    queue: [dynamic]u32
    defer delete(queue)
    
    result: [dynamic]u32

    visited[start] = true
    append_elem(&queue, start)

    for len(queue) > 0 {
        node := queue[0]
        ordered_remove(&queue, 0)
        append_elem(&result, node)

        neighbours := get_neighbours(node, data)
        for nb in neighbours {
            if !visited[nb] {
                visited[nb] = true
                append_elem(&queue, nb)
            }
        }
    }

    return result
}
