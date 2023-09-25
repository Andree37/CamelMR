let pair_equal (a1, b1) (a2, b2) = String.equal a1 a2 && Int.equal b1 b2

(* Custom Alcotest checkers based on the helper function *)
let pair_testable = Alcotest.testable (Fmt.Dump.pair Fmt.string Fmt.int) pair_equal
let pair_list_testable = Alcotest.list pair_testable

let map_test () =
    let input = [["1"; "TypeA"; "5"]; ["2"; "TypeB"; "10"]; ["3"; "TypeA"; "2"]] in
    let expected_output = [("TypeA", 1); ("TypeB", 1); ("TypeA", 1)] in

    let map_fn = Map_reduce.create_map_function 1 in
    let mapped_output = List.map map_fn input in

    Alcotest.(check pair_list_testable) "equal lists" expected_output mapped_output

let group_test () =
    let input = [("TypeA", 5); ("TypeB", 10); ("TypeA", 7)] in
    let grouped = Map_reduce.group_by_key input in
    Alcotest.(check (list int)) "TypeA values" [7; 5] (Hashtbl.find grouped "TypeA");
    Alcotest.(check (list int)) "TypeB values" [10] (Hashtbl.find grouped "TypeB")

let reduce_test () =
    let table = Hashtbl.create 10 in
    Hashtbl.add table "TypeA" [5; 7];
    Hashtbl.add table "TypeB" [10];
    let reduced = Map_reduce.parallel_reduce table in
    Alcotest.(check bool) "TypeA reduced correctly" true (List.mem ("TypeA", 12) reduced);
    Alcotest.(check bool) "TypeB reduced correctly" true (List.mem ("TypeB", 10) reduced)

let () =
    Alcotest.run "CamelMR test suite" [
        "map_test",    [ "mapping", `Quick, map_test ];
        "group_test",  [ "grouping", `Quick, group_test ];
        "reduce_test", [ "reduction", `Quick, reduce_test ];
    ]
