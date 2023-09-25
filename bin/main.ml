let input_file = Sys.argv.(1)
let target_column_name = Sys.argv.(2)

let find_column_index headers column_name =
    try 
        let indexed_headers = List.mapi (fun i col -> (i, col)) headers in
        let (index, _) = List.find (fun (_, col) -> col = column_name) indexed_headers in
        Some index
    with Not_found -> None

let create_map_function target_index = 
    fun line ->
        let ty = List.nth line target_index in 
        (ty, 1)
    
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


let compare_by_value (_, v1) (_, v2) = 
    v2 - v1
    

let () =
    if Array.length Sys.argv < 3 then
        begin
            Printf.printf "Usage: %s <path_to_csv> <target_column_name>\n" Sys.argv.(0);
            exit 1;
        end
    else
        let ic = open_in input_file in
        let csv = Csv.of_channel ic in

        (* Get headers and find the target column index *)
        let headers = Csv.next csv in
        match find_column_index headers target_column_name with
        | None -> 
            Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
            exit 1;
        | Some idx ->
            let map_function = create_map_function idx in
            let mapped_values = Parmap.parmap ~ncores:4 map_function (Parmap.L (Csv.input_all csv)) in
            let grouped = group_by_key mapped_values in
            let reduced: (string * int) list = parallel_reduce grouped in

            let sorted_results = List.sort compare_by_value reduced in
            List.iter (fun (k, v) -> Printf.printf "Type: %s, Sum: %d\n" k v) sorted_results;
