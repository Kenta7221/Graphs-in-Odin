package graph

import "core:fmt"
import "core:os"

EdgeList :: struct { edges: [dynamic][2]u32 }

edge_list_init :: proc() -> EdgeList {
    return EdgeList{edges = make([dynamic][2]u32)}
}

edge_list_destroy :: proc(data: rawptr) {
    e := cast(^EdgeList)data
    delete(e.edges)
}

edge_list_set_edge :: proc(i, j, n: u32, data: rawptr) {
    if i > n || j > n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    l := cast(^EdgeList)data
    append_elem(&l.edges, [2]u32{cast(u32)i, cast(u32)j})
}

edge_list_get_edge :: proc(i, j, n: u32, data: rawptr) -> u8 {
    if i > n || j > n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    l := cast(^EdgeList)data
    
    for pair in l.edges {
        if pair[0] == i && pair[1] == j do return 1
    }

    return 0
}

edge_list_has_edge :: proc(node, needle: u32, haystack: rawptr) -> bool {
    l := cast(^EdgeList)haystack
    
    for pair in l.edges {
        if pair[0] == node && pair[1] == needle do return true
    }

    return false
}

edge_list_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    l := cast(^EdgeList)data
    neighbour: [dynamic]u32

    for e in l.edges {
        if e[0] == node do append_elem(&neighbour, e[1])
    }

    return neighbour
}
