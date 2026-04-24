package main

AdjMatrix :: struct { mat: [][]u8, n: uint }

mat_init :: proc(n: u32) -> AdjMatrix {
    m : AdjMatrix
    m.n = N

    m.mat = make([][]u8, m.n)
    for i in 0..<N do m.mat[i] = make([]u8, m.n)

    return m
}

mat_destroy :: proc(data: rawptr) {
    m := cast(^AdjMatrix)data
    for i in 0..<m.n do delete(m.mat[i]);
    delete(m.mat)
}

mat_set_edge :: proc(i, j: u32, data: rawptr) {
    m := cast(^AdjMatrix)data
    m.mat[i][j] = 1
}

mat_get_edge :: proc(i, j: u32, data: rawptr) -> u8 {
    m := cast(^AdjMatrix)data
    return m.mat[i][j]
}

mat_has_edge :: proc(i, j: u32, data: rawptr) -> bool {
    m := cast(^AdjMatrix)data
    return m.mat[i][j] == 1
}

mat_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    m := cast(^AdjMatrix)data

    neighbour: [dynamic]u32

    for i in 0..<m.n {
        if m.mat[node][i] == 1 do append_elem(&neighbour, cast(u32)i)
    }

    return neighbour
}
