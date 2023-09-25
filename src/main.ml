let input_file = Sys.argv.(1)
let target_column_name = Sys.argv.(2)

let () =
    if Array.length Sys.argv < 3 then
        begin
            Printf.printf "Usage: %s <path_to_csv> <target_column_name>\n" Sys.argv.(0);
            exit 1;
        end
    else
        let ic = open_in input_file in
        let csv = Csv.of_channel ic in

        let headers = Csv.next csv in
        match Map_reduce.find_column_index headers target_column_name with
        | None -> 
            Printf.printf "Column name \"%s\" not found in CSV.\n" target_column_name;
            exit 1;
        | Some idx ->
            let map_function = Map_reduce.create_map_function idx in
            let mapped_values = Parmap.parmap ~ncores:4 map_function (Parmap.L (Csv.input_all csv)) in
            let grouped = Map_reduce.group_by_key mapped_values in
            let reduced: (string * int) list = Map_reduce.parallel_reduce grouped in

            let sorted_results = List.sort Map_reduce.compare_by_value reduced in
            List.iter (fun (k, v) -> Printf.printf "Type: %s, Sum: %d\n" k v) sorted_results;
