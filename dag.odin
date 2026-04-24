package main

import "core:fmt"
import "core:math"
import "core:slice"
import "core:math/rand"

GraphOps :: struct {
    data          : rawptr,
    set_edge      : proc(i, j: u32, data: rawptr),
    get_edge      : proc(i, j: u32, data: rawptr) -> u8,
    has_edge      : proc(i, j: u32, data: rawptr) -> bool,
    get_neighbours: proc(i: u32, data: rawptr) -> [dynamic]u32,
    destroy       : proc(data: rawptr),
}

generate_dag :: proc(n : u32, s : u32, set_edge: proc(i, j: u32, data: rawptr), data: rawptr) {
    e_max : u32 = n * (n-1) / 2

    edges := make([][2]u32, e_max);
    defer delete(edges)
    
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

        delete(neighbours)
    }

    return result
}

dfs :: proc(start, n: u32, get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32, data: rawptr) -> [dynamic]u32 {
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

        delete(neighbours)
    }

    return result
}

