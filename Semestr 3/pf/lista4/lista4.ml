(* Zadanie 1 *)

type 'a btree = Leaf | Node of 'a btree * 'a * 'a btree

let is_balanced bt = 
  let rec check = function
    | Leaf -> 0
    | Node (rt, x, lt) -> 
      let left_weight = check lt
      in if left_weight == -1 then -1 else
        let right_weight = check rt
        in if right_weight == -1 then -1 else
        if abs (left_weight - right_weight) <= 1 then left_weight + right_weight + 1 else -1
  in if check bt == -1 then false else true

let rec preorder = function
  | Leaf -> []
  | Node (lt, x, rt) ->
    x :: ((preorder lt) @ (preorder rt)) 
let bt = Node ((Node ((Node (Leaf, 3, Leaf)), 2, Leaf)), 
               1, 
               (Node (Node (Leaf, 5, Leaf), 4, Node (Leaf, 6, Leaf))))

let reverse xs =
  let rec iter res = function
    | [] -> res
    | hd :: tl -> (iter (hd :: res) tl) in
  iter [] xs

let halve xs =
  let rec iter xs crawl sth = 
    match crawl with
      [] -> (sth, xs)
    | [x] -> (sth, xs)
    | st :: nd :: tl -> iter (List.tl xs) tl ((List.hd xs) :: sth) in
  let sth, ndh = iter xs xs [] in
  ((reverse sth), ndh)

let rec bt_of_list = function
  | [] -> Leaf
  | x :: xs ->
    let (sth, ndh) = (halve xs)
    in Node (bt_of_list sth, x, bt_of_list ndh)


(* Zadanie 2 *)

type 'a place = PNil | Place of 'a list * 'a list

let findNth xs n = 
  let rec iter xs n = match xs, n with
    | [], 0 -> PNil
    | [], n -> failwith "n too big"
    | xs, 0 -> Place ([], xs)
    | x :: xs, n -> match (iter xs (n - 1)) with 
      | PNil -> Place ([x], [])
      | Place (bef, aft) -> Place (x :: bef, aft)
  in match iter xs n with
  | PNil -> PNil
  | Place (bef, aft) -> Place (reverse bef, aft)

let collapse = function
  | PNil -> []
  | Place (bef, aft) -> List.rev_append bef aft

let add x = function
  | PNil -> Place ([], [x])
  | Place (bef, aft) -> Place (bef, x :: aft)

let del = function
  | PNil -> failwith "empty place"
  | Place (_, []) -> failwith "nothing at this place"
  | Place (bef, aft) -> Place (bef, List.tl aft)

let next = function
  | PNil -> failwith "empty place"
  | Place (_, []) -> failwith "nothing next to this place"
  | Place (bef, aft) -> let x = List.hd aft 
    in Place (x :: bef, List.tl aft)

let prev = function
  | PNil -> failwith "empty place"
  | Place ([], _) -> failwith "nothing next to this place"
  | Place (bef, aft) -> let x = List.hd bef 
    in Place (List.tl bef, x :: aft)


(* Pierwszy element -- drzewo ukorzenione w aktualnym wierzcholku po usunieciu synow (czyli ojciec jest nowym synem) 
   Drugi element -- prawe poddrzewo
   Trzeci element -- lewe poddrzewo *)
type 'a btplace = 'a btree * 'a btree * 'a btree

