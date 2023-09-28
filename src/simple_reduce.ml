let find_column_index headers column_name =
  try 
      let indexed_headers = List.mapi (fun i col -> (i, col)) headers in
      let (index, _) = List.find (fun (_, col) -> col = column_name) indexed_headers in
      Some index
  with Not_found -> None

let simple_reduce input_file target_column_name =
  let ic = open_in input_file in
  let csv = Csv.of_channel ic in

  let headers = Csv.next csv in
  match find_column_index headers target_column_name with
  | None -> 
      Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
      exit 1;
  | Some idx ->  
      let lines_read = ref 0 in
      let count_table = Hashtbl.create 100 in
      Csv.iter ~f:(fun row ->
          incr lines_read;

          let column_value = List.nth row idx in
          let count = Hashtbl.find_opt count_table column_value in
          match count with
          | Some n -> Hashtbl.replace count_table column_value (n+1)
          | None -> Hashtbl.add count_table column_value 1;
      ) csv;


      let sorted_results = 
          Hashtbl.to_seq count_table 
          |> List.of_seq
          |> List.sort (fun (_, v1) (_, v2) -> v2 - v1) 
      in
      List.iter (fun (k, v) -> Printf.printf "Type: %s, Count: %d\n" k v) sorted_results;
      Printf.printf "Read %d lines\n" !lines_read;
