let find_column_index headers column_name =
    try 
        let indexed_headers = List.mapi (fun i col -> (i, col)) headers in
        let (index, _) = List.find (fun (_, col) -> col = column_name) indexed_headers in
        Some index
    with Not_found -> None


let merge_tables tables =
    let merged = Hashtbl.create 100 in
    List.iter (fun table ->
        Hashtbl.iter (fun k v ->
            let current = Hashtbl.find_opt merged k in
            match current with
            | Some n -> Hashtbl.replace merged k (n+v)
            | None -> Hashtbl.add merged k v;
        ) table;
    ) tables;
    merged

let parallel_reduce input_file target_column_name =
    let ic = open_in input_file in
    let csv = Csv.of_channel ic in

    let headers = Csv.next csv in
    match find_column_index headers target_column_name with
    | None -> 
        Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
        exit 1;
    | Some idx ->  
        let batch = ref [] in
        let all_results = ref [] in

        let process_batch batch =
            let count_table = Hashtbl.create 100 in
            List.iter (fun row ->
                let column_value = List.nth row idx in
                let count = Hashtbl.find_opt count_table column_value in
                match count with
                | Some n -> Hashtbl.replace count_table column_value (n+1)
                | None -> Hashtbl.add count_table column_value 1;
            ) batch;
            count_table
        in

        Csv.iter ~f:(fun row ->
            batch := row :: !batch;

            let results = Parmap.parmap ~ncores:4 process_batch (Parmap.L [!batch]) in
            all_results := results @ !all_results;
            batch := [];
            
        ) csv;

        (* Process the last batch if it's not empty *)
        if !batch <> [] then (
            let results = Parmap.parmap ~ncores:4 process_batch (Parmap.L [!batch]) in
            all_results := results @ !all_results;
        );

        let merged_results = merge_tables !all_results in

        let sorted_results = 
            Hashtbl.to_seq merged_results 
            |> List.of_seq
            |> List.sort (fun (_, v1) (_, v2) -> v2 - v1) 
        in

        List.iter (fun (k, v) -> Printf.printf "Type: %s, Count: %d\n" k v) sorted_results;

    