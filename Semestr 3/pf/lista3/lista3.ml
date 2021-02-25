(* Zadanie 1 *)

let rec fold_right f acc = function
  | x :: xs -> f x (fold_right f acc xs)
  | [] -> acc

let rec fold_left f acc = function 
  | x :: xs -> fold_left f (f acc x) xs
  | [] -> acc

let length xs = fold_left (fun a b -> a + 1) 0 xs

let rev xs = fold_left (fun xs x -> x :: xs) [] xs

let map f xs = fold_right (fun x xs -> (f x) :: xs) [] xs

let append xs ys = fold_right (fun x xs -> x :: xs) ys xs

let rev_append xs ys = fold_left (fun xs x -> x :: xs) ys xs

let filter f xs = fold_right (fun x xs -> if f x then x :: xs else xs) [] xs

let rev_map f xs = fold_left (fun xs x -> (f x) :: xs) [] xs

(* Zadanie 2 *)

let list_to_num xs = 
  let rec iter res = function
    | [] -> res
    | x :: xs -> iter (res * 10 + x) xs
  in iter 0 xs

let fold_list_to_num xs = fold_left (fun acc x -> (acc * 10 + x)) 0 xs

(* Zadanie 3 *)

let polynomial p x = 
  let rec iter acc = function
    | [] -> acc
    | hd :: tl -> iter (acc *. x +. hd) tl
  in iter 0. p

let fold_polynomial p x = fold_left (fun acc hd -> (acc *. x +. hd)) 0. p

(* Zadanie 4 *)

let rec polynomial_rev_rec p x =
  match p with
  | [] -> 0.
  | hd :: tl -> (polynomial_rev_rec tl x) *. x +. hd

let fr_polynomial_rev p x = fold_right (fun hd acc -> acc *. x +. hd) 0. p

let polynomial_rev_iter p x =
  let rec iter acc xpow = function
    | [] -> acc
    | hd :: tl -> iter (acc +. xpow *. hd) (xpow *. x) tl
  in iter 0. 1. p

let fl_polynomial_rev p x = fst (fold_left (fun (acc, xpow) hd ->  ((acc +. xpow *. hd), (xpow *. x))) (0., 1.) p)

(* Zadanie 5 *)

let for_all pred xs = 
  try fold_left (fun acc x -> if acc && (pred x) then true else raise (Failure "")) true xs with
    Failure _ -> false

let mult_list xs =
  try fold_left (fun acc x -> if x == 0 then raise (Failure "") else acc * x) 0 xs with
    Failure _ -> 0

let sorted = function
  | [] -> true
  | x :: xs ->            
    try snd (fold_left (fun acc x -> if (fst acc) <= x then (x, true) else raise (Failure "")) (x, true) xs)
    with Failure _ -> false  

(* Zadanie 6 *)

let rec fold_left_cps f acc xs k = 
  match xs with
  | [] -> k acc
  | x :: xs -> f acc x (fun v -> fold_left_cps f v xs k)

(* fold_left_cps (fun a b k -> a * b) *)

let  fold_left_with_cps f acc xs = 
  fold_left_cps (fun a b k -> k (f a b)) acc xs (fun x -> x)


(* Zadanie 7 *)

let for_all_cps pred xs =
  fold_left_cps (fun acc x k -> if pred x then k acc else false) true xs (fun x -> x) 

let mult_list_cps xs = 
  fold_left_cps (fun acc x k -> if x == 0 then 0 else k (acc * x)) 1 xs (fun x -> x)

let sorted_cps = function
  | [] -> true
  | x :: xs -> 
    fold_left_cps (fun acc x k -> if (fst acc) <= x then k (x, true) else false) 
      (x, true) xs (fun x -> snd x)

(* Zadanie 8 *)

open Procc

let mapp f =
  let rec echo k =
    recv (fun v ->
        send (f v) (fun () ->
            echo k))
  in echo

let filterr pred = 
  let rec echo k =
    recv (fun v ->
        if pred v then send v (fun () -> echo k) else echo k)
  in echo

let rec nats_from n k = 
  send n (fun () ->
      nats_from (n + 1) k)

let rec sieve k =
  recv (fun n -> 
      send n (fun () -> ((filterr (fun x -> (x mod n) != 0)) <|>> sieve) k))