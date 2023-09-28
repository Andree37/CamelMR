let find_column_index headers column_name =
    try 
        let indexed_headers = List.mapi (fun i col -> (i, col)) headers in
        let (index, _) = List.find (fun (_, col) -> col = column_name) indexed_headers in
        Some index
    with Not_found -> None

let parallel_simple_reduce input_file target_column_name =
  let ic = open_in input_file in
  let csv = Csv.of_channel ic in

  let headers = Csv.next csv in
  match find_column_index headers target_column_name with
  | None -> 
      Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
      exit 1;
  | Some idx ->  
      let count_partition row_list = 
          let local_table = Hashtbl.create 100 in
          List.iter (fun row ->
              let column_value = List.nth row idx in
              let count = Hashtbl.find_opt local_table column_value in
              match count with
              | Some n -> Hashtbl.replace local_table column_value (n+1)
              | None -> Hashtbl.add local_table column_value 1;
          ) row_list;
          local_table
      in

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
      in

      let csv_list = Csv.input_all csv in
      let partitions = Parmap.parmap ~ncores:4 count_partition (Parmap.L csv_list) in
      let merged_results = merge_tables partitions in

      let sorted_results = 
          Hashtbl.to_seq merged_results 
          |> List.of_seq
          |> List.sort (fun (_, v1) (_, v2) -> v2 - v1) 
      in

      List.iter (fun (k, v) -> Printf.printf "Type: %s, Count: %d\n" k v) sorted_results;
      Printf.printf "Read %d lines\n" (List.length csv_list);
