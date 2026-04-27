package main

import "core:math/rand"
import "core:strings"
import "core:fmt"
import "core:os"
import "core:time"

import "../graph"

Benchmark :: enum {HAS_EDGE, KAHN_SORT, TARJAN_SORT}

TEST_SIZE :: 5

main :: proc() {
    nodes_size := [TEST_SIZE]u32{100_000, 250_000, 500_000, 750_000, 1_000_000}
    graph_time: [TEST_SIZE][3]f64

    for bench, idx in Benchmark {
        for n in nodes_size[idx] {
            n := rand.uint32_range(1, MAX_NODE)
            s := rand.uint32_range(MIN_SATURATION, 100 + 1)

            
        }
    }

    write_csv(69, .HAS_EDGE)

    stopwatch: time.Stopwatch

    time.stopwatch_start(&stopwatch)
    time.stopwatch_stop(&stopwatch)
    fmt.println(time.stopwatch_duration(stopwatch))

    

    // for i in 0..<ITERATION {
    //     n := rand.uint32_range(1, MAX_NODE)
    //     s := rand.uint32_range(MIN_SATURATION, 100 + 1)

    //     for rep in g.GraphRep {
    //         ops: g.GraphOps
            
    //         #partial switch rep {
    //             case g.GraphRep.Matrix:
    //             m := g.mat_init(n)
    //             ops = g.GraphOps{
    //                 data = &m,
    //                 set_edge       = g.mat_set_edge,
    //                 get_edge       = g.mat_get_edge,
    //                 has_edge       = g.mat_has_edge,
    //                 get_neighbours = g.mat_get_neighbours,
    //                 destroy        = g.mat_destroy
    //             }
    //             case g.GraphRep.Neighbour:
    //             nl := g.neigh_list_init(n)
    //             ops = g.GraphOps{
    //                 data = &nl,
    //                 set_edge = g.neigh_list_set_edge,
    //                 get_edge = g.neigh_list_get_edge,
    //                 has_edge = g.neigh_list_has_edge,
    //                 get_neighbours = g.neigh_list_get_neighbours,
    //                 destroy = g.neigh_list_destroy
    //             }
    //             case g.GraphRep.Edge:
    //             el := g.edge_list_init()
    //             ops = g.GraphOps{
    //                 data = &el,
    //                 set_edge = g.edge_list_set_edge,
    //                 get_edge = g.edge_list_get_edge,
    //                 has_edge = g.edge_list_has_edge,
    //                 get_neighbours = g.edge_list_get_neighbours,
    //                 destroy = g.edge_list_destroy
    //             }
    //         }

    //         g.dag_generate(n, s, ops.set_edge, ops.data)
            

    //         //kahn_list := g.kahn_sort(n, ops.get_neighbours, ops.data)
    //         //delete(kahn_list)
 

    //         tarjan_list := g.tarjan_sort(n, ops.get_neighbours, ops.data)
    //         delete(tarjan_list)

    //         ops.destroy(ops.data)
    //     }
    // }
}

write_csv :: proc(n: u32, bench: Benchmark) {
    sb: strings.Builder
    strings.builder_init(&sb)
    defer strings.builder_destroy(&sb)

    strings.write_string(&sb, fmt.tprintf("%d;Adjacency Matrix;Neighbour List;Edge List\n", n))

    
    
    filename := fmt.tprintf("bin/%v.csv", bench)
    filename = strings.to_lower(filename)
    err := os.write_entire_file_from_string(filename, strings.to_string(sb))
    if err != nil {
        fmt.println("Error creating file")
        os.exit(1)
    }
}
