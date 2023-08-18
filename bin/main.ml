let () = print_endline "Hello, World!"

type person = {
  first_name : string;
  last_name : string;
  age : int;
}

let richard = {
  first_name = "Richard";
  last_name = "Feynman";
  age = 69;
}

let s = richard.first_name ^ " " ^ richard.last_name ^ " is " ^ string_of_int richard.age ^ " years old";;
print_endline s;;

type colour = Red | Green | Blue;;
let l = [Red; Green; Blue];;
print_endline (string_of_int (List.length l));;

type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree;;
let t =
  Node (Node (Leaf, 1, Leaf), 2, Node (Node (Leaf, 3, Leaf), 4, Leaf));;

let rec total t: int = 
  match t with
  | Leaf -> 0
  | Node (l, v, r) -> (total l) + v + total r;;

let rec flip t = 
  match t with
  | Leaf -> Leaf
  | Node (l, v, r) -> Node((flip r), v, (flip l));;

let all = total t;;
print_endline ("total of " ^ (string_of_int all));;

let flipped = flip t;;
print_endline ("is flipped: " ^ (string_of_bool (flipped = flip t)));;

let list_find_opt p l = 
  match List.find p l with
  | v -> Some v
  | exception Not_found -> None;;


let found = list_find_opt (fun (a) -> a = 0) [0;2;3];;
match found with
| Some v -> print_int v
| None -> print_string "nothing found";;

print_newline

let r = ref(0);;
r := 100;
print_int !r;;

print_newline

let n = 10;;
for k = 0 to n do
  print_int k;
  print_newline ()
done;;

let smallest_power_of_two x =
  let r = ref 1 in
    while !r < x do
      r := !r * 2
    done;
    !r;;

print_string ("smallest power of two of: " ^ string_of_int 2 ^ " :" ^ (string_of_int (smallest_power_of_two 2)));;

print_newline;;

let arr = [|1;2;3|];;
arr.(0);;

arr.(0) <- 0;;

arr;;