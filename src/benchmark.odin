package main

import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:strings"
import "core:time"

import g "../graph"

Benchmark :: enum {
	Has_Edge,
	Kahn_Sort,
	Tarjan_Sort,
}

MIN_SATURATION :: 20
MAX_SATURATION :: 80 + 1
TEST_SIZE :: 5

main :: proc() {
	nodes_size := [TEST_SIZE]u32{1_000, 2_500, 5_000, 7_500, 10_000}
	graph_time: [TEST_SIZE][3]f64
	stopwatch: time.Stopwatch

	for bench in Benchmark {
		fmt.printf("[%v]\n", bench)
		for n, node_idx in nodes_size {
			s := rand.uint32_range(MIN_SATURATION, MAX_SATURATION)

			edges, e_target := g.dag_generate_edges(n, s)

			fmt.println("├──" if n != nodes_size[TEST_SIZE - 1] else "└──", n)

			for rep, rep_idx in g.GraphRep {
				ops: g.GraphOps

				prefix := "│" if n != nodes_size[TEST_SIZE - 1] else " "
				fmt.println(
					prefix,
					"   ├──" if rep != g.GraphRep.Edge else "   └──",
					rep,
				)

				#partial switch rep {
				case g.GraphRep.Matrix:
					m := g.mat_init(n, e_target, edges)
					ops = g.GraphOps {
						data           = &m,
						get_edge       = g.mat_get_edge,
						set_edge       = g.mat_set_edge,
						has_edge       = g.mat_has_edge,
						get_neighbours = g.mat_get_neighbours,
						destroy        = g.mat_destroy,
					}
				case g.GraphRep.Neighbour:
					nl := g.neigh_list_init(n, e_target, edges)
					ops = g.GraphOps {
						data           = &nl,
						get_edge       = g.neigh_list_get_edge,
						set_edge       = g.neigh_list_set_edge,
						has_edge       = g.neigh_list_has_edge,
						get_neighbours = g.neigh_list_get_neighbours,
						destroy        = g.neigh_list_destroy,
					}
				case g.GraphRep.Edge:
					el := g.edge_list_init(n, e_target, edges)
					ops = g.GraphOps {
						data           = &el,
						get_edge       = g.edge_list_get_edge,
						set_edge       = g.edge_list_set_edge,
						has_edge       = g.edge_list_has_edge,
						get_neighbours = g.edge_list_get_neighbours,
						destroy        = g.edge_list_destroy,
					}
				}

				#partial switch bench {
				case .Has_Edge:
					start := rand.uint32_range(1, n)
					end := rand.uint32_range(1, n)

					time.stopwatch_reset(&stopwatch)
					time.stopwatch_start(&stopwatch)

					ops.has_edge(end, start, ops.data)

					time.stopwatch_stop(&stopwatch)

					duration := time.stopwatch_duration(stopwatch)
					graph_time[node_idx][rep_idx] = time.duration_microseconds(duration)

				case .Kahn_Sort:
					time.stopwatch_reset(&stopwatch)
					time.stopwatch_start(&stopwatch)

					kahn_list := g.kahn_sort(n, ops.get_neighbours, ops.data)
					delete(kahn_list)

					time.stopwatch_stop(&stopwatch)

					duration := time.stopwatch_duration(stopwatch)
					graph_time[node_idx][rep_idx] = time.duration_seconds(duration)

				case .Tarjan_Sort:
					time.stopwatch_reset(&stopwatch)
					time.stopwatch_start(&stopwatch)

					tarjan_list := g.tarjan_sort(n, ops.get_neighbours, ops.data)
					delete(tarjan_list)

					time.stopwatch_stop(&stopwatch)

					duration := time.stopwatch_duration(stopwatch)
					graph_time[node_idx][rep_idx] = time.duration_seconds(duration)
				}
				ops.destroy(ops.data)
			}
			delete(edges)
		}
		write_csv(bench, nodes_size, graph_time)
		fmt.println()
	}
}

@(private = "file")
write_csv :: proc(bench: Benchmark, nodes_size: [TEST_SIZE]u32, graph_time: [TEST_SIZE][3]f64) {
	sb: strings.Builder
	strings.builder_init(&sb)
	defer strings.builder_destroy(&sb)

	strings.write_string(&sb, "n;Adjacency Matrix;Neighbour List;Edge List\n")
	for i in 0 ..< TEST_SIZE {
		strings.write_string(&sb, fmt.tprintf("%d", nodes_size[i]))
		for j in 0 ..< 3 {
			strings.write_string(&sb, fmt.tprintf(";%.3f", graph_time[i][j]))
		}
		strings.write_string(&sb, "\n")
	}

	filename := fmt.tprintf("bin/%v.csv", bench)
	filename = strings.to_lower(filename)
	err := os.write_entire_file_from_string(filename, strings.to_string(sb))
	if err != nil {
		fmt.println("Error creating file")
		os.exit(1)
	}
}
