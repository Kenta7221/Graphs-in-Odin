package main

main :: proc() {
    dag: Dag
    init_dag(&dag, 6, 100)

    print_dag(&dag)

    delete_dag(&dag)
}
