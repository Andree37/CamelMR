let find_column_index headers column_name =
  try 
      let indexed_headers = List.mapi (fun i col -> (i, col)) headers in
      let (index, _) = List.find (fun (_, col) -> col = column_name) indexed_headers in
      Some index
  with Not_found -> None
                      
let extract_types str =
  let re = Str.regexp "<\\(I[^>]+\\)>" in
  let results = ref [] in
  let _ = try 
      while true do
        let _ = Str.search_forward re str (if List.length !results = 0 then 0 else Str.match_end ()) in
        results := (Str.matched_group 1 str) :: !results
      done
    with Not_found -> ()
  in
  List.rev !results

let analyze_csv input_file supported_column_name children_column_name =
  let ic = open_in input_file in
  let csv = Csv.of_channel ic in
  
  let headers = Csv.next csv in
  
  let supported_idx = match find_column_index headers supported_column_name with
    | Some idx -> idx
    | None -> failwith ("Column name \"" ^ supported_column_name ^ "\" not found in CSV.")
  in

  let children_idx = match find_column_index headers children_column_name with
    | Some idx -> idx
    | None -> failwith ("Column name \"" ^ children_column_name ^ "\" not found in CSV.")
  in
  
  let supported_counter = ref 0 in
  let unsupported_counter = ref 0 in
  let unsupported_types_counter = Hashtbl.create 100 in  
  let supported_types_counter = Hashtbl.create 100  in

  let analyze_row row =
    let supported_str = List.nth row supported_idx in
    let children_str = List.nth row children_idx in
    let node_types = extract_types children_str in
    
    match String.lowercase_ascii supported_str with
    | "true" -> 
        incr supported_counter;
        List.iter (fun t ->
            if List.mem t Supported_types.supported_types then (
                let prev_count = try Hashtbl.find supported_types_counter t with Not_found -> 0 in
                Hashtbl.replace supported_types_counter t (prev_count + 1)
            )
          ) node_types
    | "false" ->
        incr unsupported_counter;
        List.iter (fun t ->
            if not (List.mem t Supported_types.supported_types) then (
                let prev_count = try Hashtbl.find unsupported_types_counter t with Not_found -> 0 in
                Hashtbl.replace unsupported_types_counter t (prev_count + 1)
            )
          ) node_types
    | _ -> ()
  in

  Csv.iter ~f:analyze_row csv;

  Printf.printf "Supported Actions: %d\n" !supported_counter;
  Printf.printf "Unsupported Actions: %d\n" !unsupported_counter;
  Printf.printf "Counts of Unsupported Nodes (elements inside Actions):\n";
  Hashtbl.iter (fun key value -> Printf.printf "%s: %d\n" key value) unsupported_types_counter;

  Printf.printf "Counts of Supported Nodes (elements inside Actions):\n";
  Hashtbl.iter (fun key value -> Printf.printf "%s: %d\n" key value) supported_types_counter;

  close_in ic;
