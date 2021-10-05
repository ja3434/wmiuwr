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


(* Zadanie 3 *)

let reverse xs =
  let rec iter res = function
    | [] -> res
    | hd :: tl -> (iter (hd :: res) tl) in
  iter [] xs

let merge_iter cmp xs ys = 
  let rec iter xs ys res =
    match xs with
      [] -> (reverse ys) @ res
    | hdx :: tlx ->  
      match ys with
        [] -> (reverse xs) @ res 
      | (hdy :: tly) when cmp hdx (List.hd ys) -> 
        iter tlx ys (hdx :: res)
      | (hdy :: tly) -> iter xs tly (hdy :: res) in
  (reverse (iter xs ys []))

let rec merge cmp xs ys =
  match xs with
    [] -> ys
  | hdx :: tlx ->
    match ys with
      [] -> xs
    | (hdy :: tly) when (cmp hdx (List.hd ys)) -> hdx :: (merge cmp tlx ys)
    | (hdy :: tly) -> hdy :: (merge cmp xs tly)

let gen_pesimistic ?(f = fun x -> x) range = 
  let rec iter xs = function
    | 0 -> xs
    | (n : int) -> iter ((f n) :: xs) (n - 1) in
  iter [] range 

let time f x =
  let t = Sys.time() in
  let fx = f x in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t);
  fx

let test_merge range =
  let xs = gen_pesimistic range in
  let ys = gen_pesimistic range in
  time (merge (<) xs) ys

let test_merge_iter range =
  let xs = gen_pesimistic range in
  let ys = gen_pesimistic range in
  time (merge_iter (<) xs) ys

let halve xs =
  let rec iter xs crawl sth = 
    match crawl with
      [] -> (sth, xs)
    | [x] -> (sth, xs)
    | st :: nd :: tl -> iter (List.tl xs) tl ((List.hd xs) :: sth) in
  let sth, ndh = iter xs xs [] in
  ((reverse sth), ndh)

let rec mergesort_generic merge cmp = function
  | [] -> []
  | [x] -> [x]
  | xs -> let sth, ndh = halve xs in 
    merge cmp (mergesort_generic merge cmp sth) (mergesort_generic merge cmp ndh)

let mergesort = mergesort_generic merge (<)
let mergesort_with_iter_merge = mergesort_generic merge_iter (<)

let test_mergesort = mergesort [6;4;2;624;4;446;46;3;2346234;623;3246;23;6;3462;346]
let test_mergesort_with_iter_merge = mergesort_with_iter_merge [6;4;2;624;4;446;46;3;2346234;623;3246;23;6;3462;346]

let range = 10000
let mergesort_test = gen_pesimistic ~f:(fun x -> range - x) range
let pesimistic_mergesort_test = gen_pesimistic range

let merge_no_reverse cmp xs ys = 
  let rec iter xs ys res =
    match xs with
      [] -> if ys == [] then res else iter xs (List.tl ys) ((List.hd ys) :: res)
    | hdx :: tlx -> 
      match ys with
        [] -> iter tlx ys (hdx :: res)
      | hdy :: tly -> 
        if cmp hdx hdy
        then iter tlx ys (hdx :: res)
        else iter xs tly (hdy :: res) in
  iter xs ys []


(* Zadanie 4 *)

let rec map f = function
  | [] -> []
  | hd :: tl -> (f hd) :: (map f tl)

let rec perm =
  let rec iter res pref = function
    | [] -> res
    | hd :: tl -> 
      let perms = map (fun ys -> hd :: ys) (perm (pref@tl)) in
      iter (res @ perms) (pref @ [hd]) tl in function
    | [] -> [[]]
    | xs -> iter [] [] xs

let rec flatmap f = function
  | [] -> []
  | hd :: tl -> (f hd) @ (flatmap f tl)

let rec perm_flat = 
  let rec iter res x pref = function
    | [] -> (pref@[x]) :: res
    | hd :: tl -> 
      iter ((pref@(x :: hd :: tl)) :: res) x (pref@[hd]) tl in function
    | [] -> [[]]
    | hd :: tl -> 
      flatmap (iter [] hd []) (perm_flat tl)


(* Zadanie 5 *)

let suffixes xs =
  let rec iter res = function
    | [] -> [] :: res
    | hd :: tl -> iter ((hd :: tl) :: res) tl in
  reverse (iter [] xs)

let prefixes xs = reverse (map reverse (suffixes (reverse xs)))

(* Zadanie 6 *)

type 'a clist = { clist : 'z. ('a -> 'z -> 'z) -> 'z -> 'z }

let cnil = { clist = fun f z -> z }
let ccons x xs = { clist = fun f z -> f x (xs.clist f z) }
let map g xs = { clist = fun f z -> xs.clist (fun a z -> f (g a) z) z } 
let append xs ys = { clist = fun f z -> xs.clist f (ys.clist f z) }
let clist_to_list xs = xs.clist (fun x xs -> x :: xs) [] 
(* let prod xs ys = fun f z -> { clist = fun f z -> xs.clist ( ) z }  *)

let prod xs ys = { clist = fun f z -> xs.clist (fun a z -> ys.clist (fun b zz -> f (a, b) zz) z) z }

(* 'a clist -> 'b clist -> ('b -> 'a) clist *)
(* let list_pow xs ys = { clist= fun f x -> } *)

(* let pow f1 f2 = { cnum = fun f x -> (f2.cnum (mul f1) one).cnum f x } *)

let ccar xs = List.hd (clist_to_list xs)

(* Zadanie 7 *)

type cbool = { cbool : 'a. 'a -> 'a -> 'a }
type cnum = { cnum : 'a. ('a -> 'a) -> 'a -> 'a }

let even n =
  { cbool = fun tt ff -> fst (n.cnum (fun (a, b) -> (b, a)) (tt, ff))}

let ctrue = 
  { cbool = fun a b -> a}
let cfalse = 
  { cbool = fun a b -> b}
let cand f1 f2 a b = f1.cbool (f2.cbool a b) b
let cor f1 f2 a b = f1.cbool a (f2.cbool a b)
let cbool_of_bool b = if b then ctrue else cfalse
let bool_of_cbool f = f.cbool true false

let zero = { cnum = fun f x -> x }

let succ fn = { cnum = fun f x -> fn.cnum f (f x) }
let add f1 f2 = { cnum = fun f x -> f1.cnum f (f2.cnum f x) }
let mul f1 f2 = { cnum = fun f x -> f1.cnum (f2.cnum f) x }

let one = succ zero
let pow f1 f2 = { cnum = fun f x -> (f2.cnum (mul f1) one).cnum f x }

let rec cnum_of_int = function
  | 0 -> zero
  | n -> succ (cnum_of_int (n - 1))
let is_zero f = 
  let g x = x + 1 
  in if (f.cnum g 0) = 0 then true else false
let int_of_cnum f = f.cnum (fun x -> x + 1) 0

let two = succ one
let three = succ two
let four = succ three
let five = succ four

let func x = x * 2

let pred n = { cnum = fun f x -> fst (n.cnum (fun (a, b) -> (b, f(b))) (x, x)) }

let ctail xs = { clist = fun f z -> fst (xs.clist (fun a (z1, z2) -> (z2, f a z2)) (z, z)) }

let length xs = xs.clist (fun a z -> z + 1) 0