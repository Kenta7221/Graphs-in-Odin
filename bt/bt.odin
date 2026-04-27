package binary_tree

// Binary tree is implemented only for purposes of testing.
// Creating the graph as binary tree we can check whether the
// implementation of BFS and DFS for graphs is correct.

Node :: struct {
    value: u32,
    left:  ^Node,
    right: ^Node,
}

BinaryTree :: struct {
    root: ^Node,
}

bt_init :: proc(n: u32) -> BinaryTree {
    if n == 0 do return BinaryTree{}

    nodes := make([]^Node, n)
    defer delete(nodes)

    for i in 0..<n {
        node := new(Node)
        node^ = Node{value = i}
        nodes[i] = node
    }

    for i in 0..<n {
        left  := 2*i + 1
        right := 2*i + 2
        if left  < n do nodes[i].left  = nodes[left]
        if right < n do nodes[i].right = nodes[right]
    }

    return BinaryTree{root = nodes[0]}
}

bt_destroy :: proc(node: ^Node) {
    if node == nil do return
    bt_destroy(node.left)
    bt_destroy(node.right)
    free(node)
}

bfs :: proc(root: ^Node) -> [dynamic]u32 {
    result := make([dynamic]u32)
    if root == nil do return result

    queue := make([dynamic]^Node)
    defer delete(queue)

    append(&queue, root)

    for len(queue) > 0 {
        node := queue[0]
        ordered_remove(&queue, 0)
        append(&result, node.value)

        if node.left  != nil do append(&queue, node.left)
        if node.right != nil do append(&queue, node.right)
    }

    return result
}

dfs :: proc(node: ^Node, result: ^[dynamic]u32) {
    if node == nil do return
    append(result, node.value)
    dfs(node.left,  result)
    dfs(node.right, result)
}
