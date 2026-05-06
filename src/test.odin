package main

import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:testing"

import bt "../bt"
import g "../graph"

MAX_NODE :: 100 + 1
MIN_SATURATION :: 70
ITERATION :: 1000

@(test)
topological_sort :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		n := rand.uint32_range(1, MAX_NODE)
		s := rand.uint32_range(MIN_SATURATION, 100 + 1)

		edges, e_target := g.dag_generate_edges(n, s)

		for rep in g.GraphRep {
			ops: g.GraphOps

			#partial switch rep {
			case g.GraphRep.Matrix:
				m := g.mat_init(n, e_target, edges)
				ops = g.GraphOps {
					data           = &m,
					set_edge       = g.mat_set_edge,
					get_edge       = g.mat_get_edge,
					has_edge       = g.mat_has_edge,
					get_neighbours = g.mat_get_neighbours,
					destroy        = g.mat_destroy,
				}
			case g.GraphRep.Neighbour:
				nl := g.neigh_list_init(n, e_target, edges)
				ops = g.GraphOps {
					data           = &nl,
					set_edge       = g.neigh_list_set_edge,
					get_edge       = g.neigh_list_get_edge,
					has_edge       = g.neigh_list_has_edge,
					get_neighbours = g.neigh_list_get_neighbours,
					destroy        = g.neigh_list_destroy,
				}
			case g.GraphRep.Edge:
				el := g.edge_list_init(n, e_target, edges)
				ops = g.GraphOps {
					data           = &el,
					set_edge       = g.edge_list_set_edge,
					get_edge       = g.edge_list_get_edge,
					has_edge       = g.edge_list_has_edge,
					get_neighbours = g.edge_list_get_neighbours,
					destroy        = g.edge_list_destroy,
				}
			}
			is_correct: bool

			kahn_list := g.kahn_sort(n, ops.get_neighbours, ops.data)
			is_correct = is_proof_correct(n, kahn_list, ops.get_neighbours, ops.data)
			if !is_correct {
				log.info("Kahn sort failed the topological sort principle.")
				g.matrix_print(n, ops.get_edge, ops.data)
				fmt.println(n)
				fmt.println(kahn_list)
				testing.fail(t)
			}

			delete(kahn_list)

			tarjan_list := g.tarjan_sort(n, ops.get_neighbours, ops.data)
			is_correct = is_proof_correct(n, tarjan_list, ops.get_neighbours, ops.data)
			if !is_correct {
				log.infof("Tarjan sort failed %d, %d", n, kahn_list)
				debug_matrix_print(n, ops.get_edge, ops.data)
				testing.fail(t)
			}
			delete(tarjan_list)

			ops.destroy(ops.data)
		}
	}
}

@(test)
graph_traversing :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		n := rand.uint32_range(1, MAX_NODE)

		m := g.mat_zero_init(n)
		nl := g.neigh_list_zero_init(n)
		el := g.edge_list_zero_init()

		tree := bt.bt_init(n)

		for rep in g.GraphRep {
			ops: g.GraphOps

			#partial switch rep {
			case g.GraphRep.Matrix:
				ops = g.GraphOps {
					data           = &m,
					set_edge       = g.mat_set_edge,
					get_edge       = g.mat_get_edge,
					has_edge       = g.mat_has_edge,
					get_neighbours = g.mat_get_neighbours,
					destroy        = g.mat_destroy,
				}
			case g.GraphRep.Neighbour:
				ops = g.GraphOps {
					data           = &nl,
					set_edge       = g.neigh_list_set_edge,
					get_edge       = g.neigh_list_get_edge,
					has_edge       = g.neigh_list_has_edge,
					get_neighbours = g.neigh_list_get_neighbours,
					destroy        = g.neigh_list_destroy,
				}
			case g.GraphRep.Edge:
				ops = g.GraphOps {
					data           = &el,
					set_edge       = g.edge_list_set_edge,
					get_edge       = g.edge_list_get_edge,
					has_edge       = g.edge_list_has_edge,
					get_neighbours = g.edge_list_get_neighbours,
					destroy        = g.edge_list_destroy,
				}
			}

			generate_graph_as_bt(n, ops.set_edge, ops.data)

			is_correct: bool

			// I'm too lazy to create a list from bt without recursion
			bt_dfs := make([dynamic]u32)
			bt.dfs(tree.root, &bt_dfs)

			dag_dfs := g.dfs(0, n, ops.get_neighbours, ops.data)
			is_correct = is_traversing_correct(n, dag_dfs, bt_dfs)
			if !is_correct {
				log.infof("BFS failed expected: %d got: %d.", bt_dfs, dag_dfs)
				debug_matrix_print(n, ops.get_edge, ops.data)
				testing.fail(t)
			}

			delete(bt_dfs)
			delete(dag_dfs)

			bt_bfs := bt.bfs(tree.root)
			dag_bfs := g.bfs(0, n, ops.get_neighbours, ops.data)
			is_correct = is_traversing_correct(n, dag_bfs, bt_bfs)
			if !is_correct {
				log.infof("BFS failed expected: %d got: %d.", bt_bfs, dag_bfs)
				debug_matrix_print(n, ops.get_edge, ops.data)
				testing.fail(t)
			}

			delete(bt_bfs)
			delete(dag_bfs)

			ops.destroy(ops.data)
		}
		bt.bt_destroy(tree.root)
	}
}

// If in DAG there is an edge from A to B
// then A must come before B
@(private = "file")
is_proof_correct :: proc(
	n: u32,
	result: [dynamic]u32,
	get_neighbours: proc(node: u32, data: rawptr) -> [dynamic]u32,
	data: rawptr,
) -> bool {
	if (n != cast(u32)len(result)) do return false

	node_idx := make([]u32, n)
	defer delete(node_idx)

	for i in 0 ..< n {
		node_idx[result[i]] = i
	}

	for i in 0 ..< n {
		neighbours := get_neighbours(i, data)
		for nb in neighbours {
			if node_idx[i] > node_idx[nb] do return false
		}
		delete(neighbours)
	}

	return true
}

@(private = "file")
generate_graph_as_bt :: proc(n: u32, set_edge: proc(i, j, n: u32, data: rawptr), data: rawptr) {
	for i in 0 ..< n {
		left := 2 * i + 1
		right := 2 * i + 2
		if left < n do set_edge(i, left, n, data)
		if right < n do set_edge(i, right, n, data)
	}
}

@(private = "file")
is_traversing_correct :: proc(n: u32, graph, bt: [dynamic]u32) -> bool {
	if (len(bt) != len(graph)) do return false

	for i in 0 ..< n {
		if bt[i] != graph[i] do return false
	}

	return true
}

// I wasted too much time on this
@(private = "file")
debug_matrix_print :: proc(
	n: u32,
	has_edge: proc(i, j, n: u32, data: rawptr) -> u8,
	data: rawptr,
) {
	if n == 0 {return}

	sb: strings.Builder
	strings.builder_init(&sb)
	defer strings.builder_destroy(&sb)

	strings.write_string(&sb, "\n  | ")
	for i in 0 ..< n do strings.write_string(&sb, fmt.tprintf("%d ", i))
	strings.write_byte(&sb, '\n')
	for i in 0 ..< n * 2 + 4 do strings.write_string(&sb, "-" if i != 2 else "+")
	strings.write_byte(&sb, '\n')
	for i in 0 ..< n {
		strings.write_string(&sb, fmt.tprintf("%d| ", i))
		for j in 0 ..< n {
			strings.write_string(&sb, fmt.tprintf("%d ", has_edge(i, j, n, data)))
		}
		strings.write_byte(&sb, '\n')
	}

	log.info(strings.to_string(sb))
}
