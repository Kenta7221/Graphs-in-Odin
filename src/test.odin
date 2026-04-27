package tests

import "core:log"
import "core:testing"
import "core:math/rand"

import g "../graph"

ITERATION :: 100

// If in DAG there is an edge from A to B
// then A must come before B
@(private="file")
is_proof_correct :: proc(n: u32, result: [dynamic]u32, get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32, data: rawptr) -> bool {
    if(n != cast(u32)len(result)) do return false

    node_idx := make([]u32, n)
    defer delete(node_idx)

    for i in 0..<n {
        node_idx[result[i]] = i
    }    

    for i in 0..<n {
        neighbours := get_neighbours(i, data)
        for nb in neighbours {
            if node_idx[i] > node_idx[nb] do return false
        }
        delete(neighbours)
    }

    return true
}

@(test)
test_kahn_sort :: proc(t: ^testing.T) {
    for i in 0..<ITERATION {
        n := rand.uint32_range(1, 100)
        s := rand.uint32_range(70, 100 + 1)
        
        m := g.mat_init(n)
        nl := g.neigh_list_init(n)
        el := g.edge_list_init()

        for rep in g.GraphRep {
            ops: g.GraphOps
            
            #partial switch rep {
            case g.GraphRep.Matrix:
                ops = g.GraphOps{
                    data = &m,
                    set_edge       = g.mat_set_edge,
                    get_edge       = g.mat_get_edge,
                    has_edge       = g.mat_has_edge,
                    get_neighbours = g.mat_get_neighbours,
                    destroy        = g.mat_destroy
                }
            case g.GraphRep.Neighbour:           
                ops = g.GraphOps{
                    data = &nl,
                    set_edge = g.neigh_list_set_edge,
                    get_edge = g.neigh_list_get_edge,
                    has_edge = g.neigh_list_has_edge,
                    get_neighbours = g.neigh_list_get_neighbours,
                    destroy = g.neigh_list_destroy
                }
            case g.GraphRep.Edge:          
                ops = g.GraphOps{
                    data = &el,
                    set_edge = g.edge_list_set_edge,
                    get_edge = g.edge_list_get_edge,
                    has_edge = g.edge_list_has_edge,
                    get_neighbours = g.edge_list_get_neighbours,
                    destroy = g.edge_list_destroy
                }
            }

            g.dag_generate(n, s, ops.set_edge, ops.data)

            kahn_list := g.kahn_sort(n, ops.get_neighbours, ops.data)
            defer delete(kahn_list)

            is_correct:= is_proof_correct(n, kahn_list, ops.get_neighbours, ops.data)
            testing.expect(t, is_correct, "Kahn sort failed the topological sort principle.")

            ops.destroy(ops.data)
        }
    }
}

@(test)
test_tarjan_sort :: proc(t: ^testing.T) {
    for i in 0..<ITERATION {
        n := rand.uint32_range(1, 100)
        s := rand.uint32_range(70, 100 + 1)
        
        m := g.mat_init(n)
        nl := g.neigh_list_init(n)
        el := g.edge_list_init()

        for rep in g.GraphRep {
            ops: g.GraphOps
            
            #partial switch rep {
            case g.GraphRep.Matrix:
                ops = g.GraphOps{
                    data = &m,
                    set_edge       = g.mat_set_edge,
                    get_edge       = g.mat_get_edge,
                    has_edge       = g.mat_has_edge,
                    get_neighbours = g.mat_get_neighbours,
                    destroy        = g.mat_destroy
                }
            case g.GraphRep.Neighbour:           
                ops = g.GraphOps{
                    data = &nl,
                    set_edge = g.neigh_list_set_edge,
                    get_edge = g.neigh_list_get_edge,
                    has_edge = g.neigh_list_has_edge,
                    get_neighbours = g.neigh_list_get_neighbours,
                    destroy = g.neigh_list_destroy
                }
            case g.GraphRep.Edge:
                ops = g.GraphOps{
                    data = &el,
                    set_edge = g.edge_list_set_edge,
                    get_edge = g.edge_list_get_edge,
                    has_edge = g.edge_list_has_edge,
                    get_neighbours = g.edge_list_get_neighbours,
                    destroy = g.edge_list_destroy
                }
            }

            g.dag_generate(n, s, ops.set_edge, ops.data)

            tarjan_list := g.kahn_sort(n, ops.get_neighbours, ops.data)
            defer delete(kahn_list)

            is_correct:= is_proof_correct(n, kahn_list, ops.get_neighbours, ops.data)
            testing.expect(t, is_correct, "Tarjan sort failed the topological sort principle.")

            ops.destroy(ops.data)
        }
    }
}
