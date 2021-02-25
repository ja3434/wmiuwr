module type OrderedType = sig
  type t
  val compare : t -> t -> int
end

module type S = sig
  type key
  type t
  (** permutacja jako funkcja *)
  val apply : t -> key -> key
  (** permutacja identycznościowa *)
  val id : t
  (** permutacja odwrotna *)
  val invert : t -> t
  (** permutacja która tylko zamienia dwa elementy miejscami *)
  val swap : key -> key -> t
  (** złożenie permutacji (jako złożenie funkcji) *)
  val compose : t -> t -> t
  (** porównywanie permutacji *)
  val compare : t -> t -> int
end

module Make(Key : OrderedType) : (S with type key = Key.t) = 
struct
  type key = Key.t
  module MapModule = Map.Make(Key)
  type t = key MapModule.t * key MapModule.t  
  let apply ((map, invmap) : t) k = 
    try (MapModule.find k map) with 
    | Not_found -> k
  let id : t = (MapModule.empty, MapModule.empty)
  let invert ((map, invmap) : t) : t =
    (invmap, map)
  let swap k1 k2 : t = 
    let (map, invmap) = id in 
    (MapModule.add k2 k1 (MapModule.add k1 k2 map), MapModule.add k2 k1 (MapModule.add k1 k2 invmap))
  let compose ((map1, invmap1) : t) ((map2, invmap2) : t) : t =
    let f map x m1_of_x m2_of_x = match m1_of_x with
      | None -> m2_of_x
      | Some y -> match MapModule.find_opt y map with
        | None -> Some y
        | Some z -> Some z
    in (MapModule.merge (f map2) map1 map2, 
        MapModule.merge (f invmap1) invmap2 invmap1)
  let compare ((map1, invmap1) : t) ((map2, invmap2): t) = 
    MapModule.compare Key.compare map1 map2
end

module StringOrder: (OrderedType with type t = string) =
struct
  type t = string
  let compare s1 s2 = if s1 < s2 then -1 else if s1 > s2 then 1 else 0
end

module StringPerm = Make(StringOrder) 
let p = StringPerm.compose (StringPerm.swap "1" "2") (StringPerm.swap "2" "3");;

(* Zadanie 2 *)

let is_generated (type a) (packed : (module S with type t = a)) (perm : a) (generators : (a list)) =
  let module PermModule = (val packed : (S with type t = a)) in
  let module OrderedPerm : (OrderedType with type t = a) =
  struct
    type t = a
    let compare p1 p2 = PermModule.compare p1 p2
  end in
  let module SS = Set.Make(OrderedPerm) in
  let rec flatmap f = function
    | [] -> []
    | x :: xs -> (f x) @ flatmap f xs in
  let saturate xn = 
    let perms = SS.elements xn in
    let inverts = List.map (fun p -> PermModule.invert p) perms in
    let compositions = flatmap (fun p -> (List.map (fun q -> PermModule.compose p q) perms)) perms in
    SS.union xn (SS.union (SS.of_list inverts) (SS.of_list compositions)) in
  let rec iter xn = 
    let xn1 = saturate xn in
    if SS.mem perm xn1 then true else
    if SS.compare xn xn1 == 0 then false else
      iter xn1
  in iter (SS.of_list generators)

(* Zadanie 3 *)

module OrderedList (X : OrderedType) : (OrderedType with type t = X.t list) = 
struct
  type t = X.t list
  let rec compare (xs: t) (ys: t) = 
    match (xs, ys) with
    | ([], []) -> 0
    | ([], _) -> -1
    | (_, []) -> 1
    | (x :: xs, y :: ys) -> let cmp = X.compare x y in 
      if cmp == 0 then compare xs ys else cmp
end

module OrderedPair (X : OrderedType) : (OrderedType with type t = X.t * X.t) =
struct 
  type t = X.t * X.t
  let compare ((a, b): t) ((c, d) : t) =
    let cmp = X.compare a c in
    if cmp == 0 then X.compare b d else cmp 
end

module OrderedOption (X : OrderedType) : (OrderedType with type t = X.t option) = 
struct
  type t = X.t option
  let compare (a: t) (b: t) = 
    match (a, b) with
    | (None, None) -> 0
    | (None, _) -> -1
    | (_, None) -> 1
    | (Some a, Some b) -> X.compare a b
end
