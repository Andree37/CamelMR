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


let reduce_group key values = 
  key, (List.fold_left (+) 0 values)

let parallel_reduce table = 
  let grouped = Hashtbl.fold (fun k v acc -> (k, v)::acc) table [] in
  Parmap.parmap ~ncores:4 (fun (k, vs) -> reduce_group k vs) (Parmap.L grouped)


let compare_by_value (_, v1) (_, v2) = 
  v2 - v1
  
