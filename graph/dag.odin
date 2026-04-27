package graph

import "core:fmt"
import "core:math"
import "core:slice"
import "core:math/rand"

GraphOps :: struct {
    data          : rawptr,
    set_edge      : proc(i, j, n: u32, data: rawptr),
    get_edge      : proc(i, j, n: u32, data: rawptr) -> u8,
    has_edge      : proc(needle, val: u32, haystack: rawptr) -> bool,
    get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32,
    destroy       : proc(data: rawptr)
}

GraphRep :: enum {Matrix, Neighbour, Edge}

Frame :: struct { 
    node      : u32,
    nb_idx    : int,
}

dag_generate :: proc(n : u32, s : u32, set_edge: proc(i, j, n: u32, data: rawptr), data: rawptr) {
    e_max : u32 = n * (n-1) / 2
    e_target : u32 = cast(u32)math.floor(cast(f32)(s) / 100.0 * cast(f32)e_max)

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

    slice.sort_by(edges[:e_target], edge_less)
   
    for i in 0..<e_target do set_edge(edges[i][0], edges[i][1], n, data)
}

@(private="file")
edge_less :: proc(a, b: [2]u32) -> bool {
    if a[0] != b[0] do return a[0] < b[0]
    return a[1] < b[1]
}

kahn_sort :: proc(n: u32,
                  get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32,
                  data: rawptr) -> [dynamic]u32 {
    in_degree := make([]u32, n)
    defer delete(in_degree)

    for i in 0..<n {
        neighbours := get_neighbours(i, data)
        for nb in neighbours do in_degree[nb] += 1
        delete(neighbours)
    }

    queue : [dynamic]u32
    defer delete(queue)

    for i in 0..<len(in_degree) {
        if in_degree[i] == 0 do append_elem(&queue, cast(u32)i)
    }

    result := make([dynamic]u32)
    for len(queue) > 0 {
        node := queue[0]
        remove_range(&queue, 0, 1)
        append(&result, node)

        neighbours := get_neighbours(node, data)
        for nb in neighbours {
            in_degree[nb] -= 1
            if in_degree[nb] == 0 do append(&queue, nb)
        }
        delete(neighbours)
    }

    return result
}

tarjan_sort :: proc(n: u32, get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32, data: rawptr) -> [dynamic]u32 {

    marked := make([]bool, n)
    defer delete(marked)

    stack: [dynamic]Frame
    defer delete(stack)
    
    result: [dynamic]u32

    for i in 0..<n {
        if marked[i] do continue
        marked[i] = true
        append_elem(&stack, Frame{i, 0})

        for len(stack) > 0 {
            frame := &stack[len(stack)-1]
            found := false
            neighbours := get_neighbours(frame.node, data)

            for frame.nb_idx < len(neighbours) {
                nb := neighbours[frame.nb_idx]
                frame.nb_idx += 1
                if !marked[nb] {
                    marked[nb] = true
                    append_elem(&stack, Frame{nb, 0})
                    found = true
                    break
                }
            }
            if !found {
                append_elem(&result, frame.node)
                pop(&stack)
            }

            delete(neighbours)
        }
    }

    slice.reverse(result[:])
    return result
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
        node := queue[len(queue) - 1]
        ordered_remove(&queue, len(queue) - 1)
        append_elem(&result, node)

        neighbours := get_neighbours(node, data)
        #reverse for nb in neighbours {
            if !visited[nb] {
                visited[nb] = true
                append_elem(&queue, nb)
            }
        }

        delete(neighbours)
    }

    return result
}

matrix_print :: proc(n: u32, has_edge: proc(i, j, n: u32, data: rawptr) -> u8, data: rawptr) {
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
            fmt.print(has_edge(i, j, n, data), " ", sep = "")
	    }

	    fmt.println()
    }
}

order_print :: proc(neighbours: [dynamic]u32) {
    for nb in neighbours {
        fmt.print(nb, " ", sep = "")
    }

    fmt.println()
}
