let input_file = Sys.argv.(1)

(* Map function: Extract type and value *)
let map line = 
    let ty = List.nth line 1 in
    let value = int_of_string (List.nth line 2) in
    (ty, value)

(* Group by key *)
let group_by_key kv_pairs = 
    let table = Hashtbl.create 100 in
    List.iter (fun (k, v) ->
        let existing_values = try Hashtbl.find table k with Not_found -> [] in
        Hashtbl.replace table k (v :: existing_values)
    ) kv_pairs;
    table
(* Parallel reduce function: Sum the values for each type *)
let reduce_group key values = 
    key, (List.fold_left (+) 0 values)

let parallel_reduce table = 
    let grouped = Hashtbl.fold (fun k v acc -> (k, v)::acc) table [] in
    Parmap.parmap ~ncores:4 (fun (k, vs) -> reduce_group k vs) (Parmap.L grouped)

let () =
    if Array.length Sys.argv < 2 then
        begin
            Printf.printf "Usage: %s <path_to_csv>\n" Sys.argv.(0);
            exit 1;
        end
    else
        let ic = open_in input_file in
        let csv = Csv.of_channel ic in

        let mapped_values = Parmap.parmap ~ncores:4 map (Parmap.L (Csv.input_all csv)) in
        let grouped = group_by_key mapped_values in
        let reduced = parallel_reduce grouped in

        List.iter (fun (k, v) -> Printf.printf "Type: %s, Sum: %d\n" k v) reduced;
