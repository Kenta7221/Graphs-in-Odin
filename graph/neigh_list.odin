package graph

import "core:fmt"
import "core:os"

NeighList :: struct { lists: map[u32]^[dynamic]u32 }

neigh_list_init :: proc(n, e_target: u32, edges: [][2]u32) -> NeighList {
    lists := make(map[u32]^[dynamic]u32)
    for i in 0..<n {
        arr := new([dynamic]u32)
        arr^ = make([dynamic]u32)
        lists[i] = arr
    }
    

    for i in 0..<e_target {
        x := edges[i][0]
        y := edges[i][1]

        if x > n || y > n {
            fmt.println("Node is out of bounds")
            os.exit(1)
        }

        arr := lists[x]
        append_elem(arr, y)
    }

    return NeighList{lists = lists}
}

neigh_list_zero_init :: proc(n: u32) -> NeighList {
    lists := make(map[u32]^[dynamic]u32)
    for i in 0..<n {
        arr := new([dynamic]u32)
        arr^ = make([dynamic]u32)
        lists[i] = arr
    }

    return NeighList{lists = lists}
}

neigh_list_destroy :: proc(data: rawptr) {
    n := cast(^NeighList)data
    for _, arr in n.lists {
        delete(arr^)
        free(arr)
    }
    delete(n.lists)
}

neigh_list_set_edge :: proc(i, j, n: u32, data: rawptr) {
    l := cast(^NeighList)data
    arr := l.lists[i]
    append_elem(arr, j)
}

neigh_list_get_edge :: proc(i, j, n: u32, data: rawptr) -> u8 {
    l := cast(^NeighList)data
    if i >= n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }
    arr, ok := l.lists[i]
    if !ok do return 0
    for edge in arr^ {
        if edge == j do return 1
    }
    return 0
}

neigh_list_has_edge :: proc(node, needle: u32, haystack: rawptr) -> bool {
    n := cast(^NeighList)haystack
    arr, ok := n.lists[node]
    if !ok do return false
    for edge in arr^ {
        if edge == needle do return true
    }
    return false
}

neigh_list_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    n := cast(^NeighList)data
    result := make([dynamic]u32)
    arr, ok := n.lists[node]
    if !ok {
        fmt.println("Node is out of range!")
        return result
    }
    for v in arr^ do append_elem(&result, v)
    return result
}
