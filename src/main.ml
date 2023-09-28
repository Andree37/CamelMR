let input_file = Sys.argv.(1)
let target_column_name = Sys.argv.(2)
let mode = if Array.length Sys.argv > 3 then Sys.argv.(3) else "mapreduce"

let () =
    if Array.length Sys.argv < 3 then
        begin
            Printf.printf "Usage: %s <path_to_csv> <target_column_name> (optional)<mode>\n" Sys.argv.(0);
            exit 1;
        end
    else
        let start_time = Unix.gettimeofday () in
        let _ = match mode with
            | "simple" -> Simple_reduce.simple_reduce input_file target_column_name
            | "parallel" -> Parallel_reduce.parallel_reduce input_file target_column_name 20000 (* this value depends on the available ram *)
            | _ -> Map_reduce.map_reduce input_file target_column_name
        in

        let end_time = Unix.gettimeofday () in
        let elapsed_time = end_time -. start_time in
        Printf.printf "\nElapsed time: %.3f seconds\n" elapsed_time;
