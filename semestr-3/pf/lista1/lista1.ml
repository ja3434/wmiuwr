(* Zadanie 1 *)

let a1 f g x = x |> g |> f
let ff (a : 'a -> 'b) (b : 'c -> 'a) = fun x -> a (b x)

let a2 a b = a
let a3 a b = if a = b then a else a

(* Zadanie 2 *);;
let rec x y = x y;;

(* Nie mozna bo etykieta b nie zostala nigdzie nalozona to jak ma byc sciagnieta? *)

(* Zadanie 3 *);;


let hd s = s 0
let tl s = fun x -> s (x + 1)
let add value s = fun x -> s x + value
let map f s = fun x -> x |> s |> f
let map2 f s1 s2 = 
  fun x -> let a = s1 x and b = s2 x in f a b
let replace n a s =
  fun x -> if x mod n = 0 then a else s x
let take n s =
  fun x -> n*x |> s
let rec scan f a s = 
  fun x -> 
  if x = 0 then f a (s 0)
  else f ((scan f a s) (x - 1)) (s x)
let rec tabulate ?(l=0) r s =
  if l = r then [s r]
  else s l :: tabulate ~l:(l + 1) r s
let s1 x = x + 1
let s2 x = x * x

(* Zadanie 4 *)

let ctrue a b = a
let cfalse a b = b
let cand f1 f2 a b = f1 (f2 a b) b
let cor f1 f2 a b = f1 a (f2 a b)
let cbool_of_bool b = if b then ctrue else cfalse
let bool_of_cbool f = f true false


(* Zadanie 5 *)

let zero f x = x
let succ fn = fun f x -> fn f (f x)
let add f1 f2 = fun f x -> f1 f (f2 f x)
let mul f1 f2 = fun f x -> (f1 (f2 f)) x
let is_zero f = 
  let g x = x + 1 
  in if (f g 0) = 0 then ctrue else cfalse
let rec cnum_of_int = function
  | 0 -> zero
  | n -> succ (cnum_of_int (n - 1))

let int_of_cnum f = f (fun x -> x + 1) 0

let one = succ zero
let two = succ one
let three = succ two
let four = succ three
let five = succ four

let func x = x * 2

(* Zadanie 6 *)