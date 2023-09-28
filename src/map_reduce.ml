let find_column_index headers column_name =
  let rec aux headers idx =
    match headers with
    | [] -> None
    | hd :: _ when hd = column_name -> Some idx
    | _ :: tl -> aux tl (idx + 1)
  in
  aux headers 0

let compare_by_value (_, v1) (_, v2) = 
  v2 - v1

let create_map_function target_index line =
  (List.nth line target_index, 1)

let add_to_hashtbl table (k, v) =
  let open Hashtbl in
  try
    replace table k ((find table k) + v)
  with Not_found ->
    add table k v

let map_reduce input_file target_column_name =
  let ic = open_in input_file in
  let csv = Csv.of_channel ic in
  let headers = Csv.next csv in

  match find_column_index headers target_column_name with
  | None -> 
    Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
    raise (Invalid_argument ("Column name not found"))
  | Some idx ->
    let table = Hashtbl.create 100 in
    Csv.iter ~f:(fun row ->
      add_to_hashtbl table (create_map_function idx row)
    ) csv;

    let reduced = Hashtbl.fold (fun k v acc -> (k, v) :: acc) table [] in
    let sorted_results = List.sort compare_by_value reduced in

    List.iter (fun (k, v) -> Printf.printf "Type: %s, Sum: %d\n" k v) sorted_results;
    Printf.printf "Read %d lines\n" (Hashtbl.length table);
    
    close_in ic;
