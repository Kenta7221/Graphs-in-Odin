package graph

import "core:fmt"
import "core:os"

AdjMatrix :: struct { mat: [][]u8, n: u32 }

mat_init :: proc(n, e_target: u32, edges: [][2]u32) -> AdjMatrix {
    m : AdjMatrix
    m.n = n
    m.mat = make([][]u8, m.n)
    for i in 0..<n do m.mat[i] = make([]u8, m.n)

    for i in 0..<e_target {
        x := edges[i][0]
        y := edges[i][1]

        if x > n || y > n {
            fmt.println("Node is out of bounds")
            os.exit(1)
        }

        m.mat[x][y] = 1
    }

    return m
}

mat_zero_init :: proc (n: u32)  -> AdjMatrix {
    m : AdjMatrix
    m.n = n
    m.mat = make([][]u8, m.n)
    for i in 0..<n do m.mat[i] = make([]u8, m.n)

    return m
}

mat_destroy :: proc(data: rawptr) {
    m := cast(^AdjMatrix)data
    for i in 0..<m.n do delete(m.mat[i])
    delete(m.mat)
}

mat_set_edge :: proc(i, j, n: u32, data: rawptr) {
    if i > n || j > n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    m := cast(^AdjMatrix)data
    m.mat[i][j] = 1
}

mat_get_edge :: proc(i, j, n: u32, data: rawptr) -> u8 {
    m := cast(^AdjMatrix)data
    if i > n || j > n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }
    
    return m.mat[i][j]
}

mat_has_edge :: proc(node, needle: u32, haystack: rawptr) -> bool {
    m := cast(^AdjMatrix)haystack
    if node > m.n || needle > m.n do return false
    
    return m.mat[node][needle] == 1
}

mat_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    m := cast(^AdjMatrix)data

    if node > cast(u32)m.n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    neighbour: [dynamic]u32

    for i in 0..<m.n {
        if m.mat[node][i] == 1 do append_elem(&neighbour, cast(u32)i)
    }

    return neighbour
}
