let rec fix f x = f (fix f) x

let fib_f fib n =
  if n <= 1 then n
  else fib (n - 1) + fib (n - 2)

let fib = fix fib_f

(* Zadanie 1 *)

let rec fix_with_limit limit f x = 
  if limit > 0 then f (fix_with_limit (limit - 1) f) x
  else failwith "Max recursion depth"

let fix_memo f =
  let ht = Hashtbl.create 10 in 
  let rec fix ht f =
    fun x -> try (Hashtbl.find ht x) with
      | Not_found -> let result = f (fix ht f) x 
        in Hashtbl.add ht x result ; result
  in f (fix ht f)

(* Zadanie 2 *)


(* Zadanie 3 *)

let create_counter () = 
  let cnt = ref 0
  in let next () =
       let r = !cnt in 
       cnt := r + 1;
       r
  in let reset () = 
       cnt := 0
  in (next, reset)

let next, rest = create_counter ()

(* Zadanie 4 *)

type 'a stream = Stream of 'a * (unit -> 'a stream)

let shd = function
  | Stream (hd, tl) -> hd

let stl = function
  | Stream (hd, tl) -> tl ()

let rec lfrom k = Stream (k, fun () -> lfrom (k + 1))

let rec sfilter p (Stream (hd, tl)) = 
  if p hd then (Stream (hd, fun () -> sfilter p (tl()))) else sfilter p (tl()) 

let rec smap f (Stream (hd, tl))
  = Stream (f hd, fun () -> smap f (tl()))

let rec liebniz_gen k sign acc = 
  Stream (4. *. (acc +. (sign *. (1.0 /.  k))), 
          fun () -> liebniz_gen (k +. 2.) (-. sign) (acc +. (sign *. (1.0 /.  k))))

let leibniz = liebniz_gen 1. 1. 0.

let sum_pref n s = 
  let rec iter acc n (Stream (hd, tl)) =
    if n == 0 then acc else iter (acc +. hd) (n - 1) (tl())
  in iter 0. n s

let approx_leibniz n = sum_pref n leibniz

let rec fold_three f s = 
  let x1 = shd s in 
  let xs = stl s in
  let x2 = shd xs in
  let x3 = shd (stl xs) in
  Stream (f x1 x2 x3, fun () -> fold_three f xs)

let rec stake n s = 
  if n == 0 then shd s else stake (n - 1) (stl s)

let euler_transform x y z = z -. (((y -. z) *. (y -. z))  /. (x -. (2.0 *. y) +. z))
(* let rec s = fun () -> Stream (1., fun () -> Stream (3., fun () -> Stream (3.1, fun () -> fold_three euler_transform (s ())))) *)

let pi_e = fold_three euler_transform leibniz 


(* Zadanie 5 *)

type 'a dllist = 'a dllist_data lazy_t
and 'a dllist_data =
  { prev : 'a dllist
  ; elem : 'a
  ; next : 'a dllist
  }

let prev = function
  | lazy (dll) -> dll.prev

let elem = function
  | lazy (dll) -> dll.elem

let next = function
  | lazy (dll) -> dll.next


let rec of_list xs =
  let rec dll = List.map (fun x -> lazy {prev = get_previous dll x; elem = x; next = get_next dll x}) xs
  in (List.hd (Lazy.force dll))
and get_previous dll x =
  let dll = Lazy.force dll in 
  if (elem (List.hd dll)) == x then (List.hd (List.rev dll)) else
    let rec iter prev xs = 
      let y = List.hd xs 
      in if (elem y) == x then prev else iter y (List.tl xs)
    in iter (List.hd dll) (List.tl dll)
and get_next dll x =
  let dll = Lazy.force dll in
  if (elem (List.hd (List.rev dll))) == x then List.hd dll else
    let rec iter xs =
      let y = List.hd xs
      in if (elem y) == x then (List.hd (List.tl xs)) else iter (List.tl xs)
    in iter (List.rev dll)  
