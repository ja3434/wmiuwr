(* Zadanie 1 *)

let sublists l =
  let rec backtrack sl = function
    | [] -> [sl]
    | hd :: tl -> (backtrack (sl @ [hd]) tl) @ backtrack sl tl
  in backtrack [] l


(* Zadanie 2 *)

(* Znalezione tutaj: https://stackoverflow.com/questions/2710233/how-to-get-a-sub-list-from-a-list-in-ocaml *)

let rec super_sublist b e = function
  | [] -> failwith "empty list"
  | hd :: tl ->
      let tail = if e <= 1 then [] else super_sublist (b - 1) (e - 1) tl in
      if b > 0 then tail else hd :: tail   

(* Moje rozwiązanie: *)

let rec sublist b e l = 
  let rec suffix idx l = 
    if idx = 0 then l else suffix (idx - 1) (List.tl l) in 
  let rec prefix idx l = 
    if idx = 0 then [] else (List.hd l) :: (prefix (idx - 1) (List.tl l)) in
  prefix (e - 1) (suffix b l)

let cycle_with_sub sublist_fun xs n = 
  sublist_fun n (n + (List.length xs)) (xs @ xs) 

let super_cycle = cycle_with_sub super_sublist
let cycle = cycle_with_sub sublist
