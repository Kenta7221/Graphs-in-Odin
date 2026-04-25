package main

import "core:fmt"

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

neigh_list_has_edge :: proc(i, j: u32, data: rawptr) -> bool {
    n := cast(^NeighList)data
    list, ok := &n.lists[i]

    if(!ok) {
        fmt.println("Node is out of range!")
        return false;
    }
    
    for edge in list {
        if edge == j do return true
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
