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
(* let is_zero f =  *)
let rec cnum_of_int = function
  | 0 -> zero
  | n -> succ (cnum_of_int (n - 1))
let is_zero f = 
  let g x = x + 1 
  in if (f.cnum g 0) = 0 then ctrue else cfalse
let int_of_cnum f = f.cnum (fun x -> x + 1) 0

let one = succ zero
let two = succ one
let three = succ two
let four = succ three
let five = succ four

let func x = x * 2