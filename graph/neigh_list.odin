package graph

import "core:fmt"
import "core:os"

NeighList :: struct { lists: map[u32][dynamic]u32 }

neigh_list_init :: proc(n: u32) -> NeighList {
    lists := make(map[u32][dynamic]u32)
    for i in 0..<n {
        lists[i] = make([dynamic]u32)
    }
    return NeighList{lists = lists}
}

neigh_list_destroy :: proc(data: rawptr) {
    n := cast(^NeighList)data
    delete(n.lists)
}

neigh_list_set_edge :: proc(i, j, n: u32, data: rawptr) {
    l := cast(^NeighList)data
    arr := &l.lists[i]
    append(arr, j)
}

neigh_list_get_edge :: proc(i, j, n: u32, data: rawptr) -> u8 {
    neight_list := cast(^NeighList)data

    if i > n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    arr := neight_list.lists[i]
    
    for edge in arr {
        if edge == j do return 1
    }

    return 0
}

neigh_list_has_edge :: proc(node, needle: u32, haystack: rawptr) -> bool {
    n := cast(^NeighList)haystack
    list, ok := &n.lists[node]

    if(!ok) do return false
    
    for edge in list {
        if edge == needle do return true
    }

    return false
}

neigh_list_get_neighbours :: proc(node: u32, data: rawptr) -> [dynamic]u32 {
    n := cast(^NeighList)data
    result := make([dynamic]u32)

    list, ok := &n.lists[node]
    if !ok {
        fmt.println("Node is out of range!")
        return result
    }
    
    for v in list do append_elem(&result, v)
    return result
}

