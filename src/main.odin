package main

import "core:encoding/endian"
import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:strconv"
import "core:strings"

import g "../graph"

User :: struct {
	ops: g.GraphOps,
	n:   u32,
	s:   u32,
}

main :: proc() {
	user, edges, e_target := handle_user_flag()
	defer {
		user.ops.destroy(user.ops.data)
		delete(edges)
	}

	rep := cast(g.GraphRep)rand.uint32_range(0, len(g.GraphRep))
	#partial switch rep {
	case g.GraphRep.Matrix:
		m := g.mat_init(user.n, e_target, edges)
		user.ops = g.GraphOps {
			data           = &m,
			get_edge       = g.mat_get_edge,
			set_edge       = g.mat_set_edge,
			has_edge       = g.mat_has_edge,
			get_neighbours = g.mat_get_neighbours,
			destroy        = g.mat_destroy,
		}
	case g.GraphRep.Neighbour:
		nl := g.neigh_list_init(user.n, e_target, edges)
		user.ops = g.GraphOps {
			data           = &nl,
			get_edge       = g.neigh_list_get_edge,
			set_edge       = g.neigh_list_set_edge,
			has_edge       = g.neigh_list_has_edge,
			get_neighbours = g.neigh_list_get_neighbours,
			destroy        = g.neigh_list_destroy,
		}
	case g.GraphRep.Edge:
		el := g.edge_list_init(user.n, e_target, edges)
		user.ops = g.GraphOps {
			data           = &el,
			get_edge       = g.edge_list_get_edge,
			set_edge       = g.edge_list_set_edge,
			has_edge       = g.edge_list_has_edge,
			get_neighbours = g.edge_list_get_neighbours,
			destroy        = g.edge_list_destroy,
		}
	}

	g.matrix_print(user.n, user.ops.get_edge, user.ops.data)
}

@(private = "file")
handle_user_flag :: proc() -> (User, [][2]u32, u32) {
	user: User

	if len(os.args) < 2 {
		fmt.eprintln("Unsufficient amount of arguments")
		os.exit(1)
	}

	if os.args[1] != "--generate" && os.args[1] != "--user-provided" {
		fmt.eprintln("Provided flag does not exist")
		os.exit(1)
	}

	if os.args[1] == "--generate" {
		fmt.print("Nodes> ")
		n_str := read_line()
		defer delete(n_str)

		fmt.print("Saturation> ")
		s_str := read_line()
		defer delete(s_str)

		tmp: uint
		tmp, _ = strconv.parse_uint(n_str)
		user.n = cast(u32)tmp

		tmp, _ = strconv.parse_uint(s_str)
		user.s = cast(u32)tmp

		edges, e_target := g.dag_generate_edges(user.n, user.s)

		return user, edges, e_target
	}

	fmt.print("Nodes> ")
	n_str := read_line()
	defer delete(n_str)

	tmp: uint
	tmp, _ = strconv.parse_uint(n_str)
	user.n = cast(u32)tmp

	e_target: u32 = 0
	edges := make([dynamic][2]u32)

	for i in 0 ..< user.n {
		fmt.printf("%d> ", i)
		line := read_line()
		defer delete(line)

		if len(line) == 0 do break

		parts := strings.split(line, " ")
		defer delete(parts)

		for val_str in parts {
			val, _ := strconv.parse_uint(val_str)
			e_target += 1
			append_elem(&edges, [2]u32{i, cast(u32)val})
		}
	}

	return user, edges[:], e_target
}

@(private = "file")
read_line :: proc() -> string {
	buf: [256]byte
	n, err := os.read(os.stdin, buf[:])
	if err != nil do return ""
	s := strings.clone(string(buf[:n]))
	return strings.trim_right(s, "\r\n")
}
