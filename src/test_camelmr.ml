let pair_equal (a1, b1) (a2, b2) = String.equal a1 a2 && Int.equal b1 b2

(* Custom Alcotest checkers based on the helper function *)
let pair_testable = Alcotest.testable (Fmt.Dump.pair Fmt.string Fmt.int) pair_equal
let pair_list_testable = Alcotest.list pair_testable

let map_test () =
    let input = [["1"; "TypeA"; "a"]; ["2"; "TypeB"; "something"]; ["3"; "TypeA"; "other"]] in
    let expected_output = [("TypeA", 1); ("TypeB", 1); ("TypeA", 1)] in

    let map_fn = Map_reduce.create_map_function 1 in
    let mapped_output = List.map map_fn input in

    Alcotest.(check pair_list_testable) "equal lists" expected_output mapped_output

let () =
    Alcotest.run "CamelMR test suite" [
        "map_test",    [ "mapping", `Quick, map_test ];
    ]
