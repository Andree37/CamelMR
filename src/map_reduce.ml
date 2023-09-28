let find_column_index headers column_name =
  let rec aux headers idx =
    match headers with
    | [] -> None
    | hd :: _ when hd = column_name -> Some idx
    | _ :: tl -> aux tl (idx + 1)
  in
  aux headers 0



let create_map_function target_index line =
  (List.nth line target_index, 1)

let add_to_hashtbl table (k, v) =
  try
    let existing = Hashtbl.find table k in
    Hashtbl.replace table k (existing + v)
  with Not_found ->
    Hashtbl.add table k v

let parallel_map input_file map_function =
  let ic = open_in input_file in
  let csv = Csv.of_channel ic in
  let table = Hashtbl.create 100 in
  
  Csv.iter ~f:(fun row ->
    add_to_hashtbl table (map_function row)
  ) csv;
  
  table

let compare_by_value (_, v1) (_, v2) = 
  v2 - v1
  
let map_reduce input_file target_column_name =
  let headers = Csv.next (Csv.of_channel (open_in input_file)) in
  match find_column_index headers target_column_name with
  | None -> 
    Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
    exit 1;
  | Some idx ->
    let mapped_table = parallel_map input_file (create_map_function idx) in
    let reduced = Hashtbl.fold (fun k v acc -> (k, v) :: acc) mapped_table [] in
    let sorted_results = List.sort compare_by_value reduced in
    List.iter (fun (k, v) -> Printf.printf "Type: %s, Sum: %d\n" k v) sorted_results;
    Printf.printf "Read %d lines\n" (Hashtbl.length mapped_table);
