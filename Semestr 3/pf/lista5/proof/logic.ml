(* type formula = False | Var of string | Imp of formula * formula

   let rec string_of_formula = function
   | False -> "F"
   | Var s -> s
   | Imp (f1, f2) -> "(" ^ (string_of_formula f1) ^ " -> " ^ (string_of_formula f2) ^ ")"
   (* match (f1, f2) with
   | (Var v1, Var v2) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (Var v1, False) | (False, Var v1) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (False, False) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (f1, f2) -> "(" ^ (string_of_formula f1) ^ " -> " ^ (string_of_formula f2) ^ ")" *)

   let pp_print_formula fmtr f =
   Format.pp_print_string fmtr (string_of_formula f)

   type verdict = { assump : formula list; concl : formula }

   type theorem = 
   | Assumption of verdict
   | ImpInsert of verdict * theorem
   | ImpErase of verdict * theorem * theorem
   | Contradiction of verdict * theorem

   let get_verdict thm = match thm with
   | Assumption f -> f
   | ImpInsert (v, _) | ImpErase (v, _, _) | Contradiction (v, _) -> v

   let assumptions thm = (get_verdict thm).assump
   let consequence thm = (get_verdict thm).concl

   let pp_print_theorem fmtr thm =
   let open Format in
   pp_open_hvbox fmtr 2;
   begin match assumptions thm with
    | [] -> ()
    | f :: fs ->
      pp_print_formula fmtr f;
      fs |> List.iter (fun f ->
          pp_print_string fmtr ",";
          pp_print_space fmtr ();
          pp_print_formula fmtr f);
      pp_print_space fmtr ()
   end;
   pp_open_hbox fmtr ();
   pp_print_string fmtr "⊢";
   pp_print_space fmtr ();
   pp_print_formula fmtr (consequence thm);
   pp_close_box fmtr ();
   pp_close_box fmtr ()

   let by_assumption f =
   Assumption { assump=[f]; concl=f }

   let imp_i f thm =
   let premise = get_verdict thm
   in ImpInsert ({assump=(List.filter ((<>) f) premise.assump); concl=(Imp (f, premise.concl))}, thm)

   let imp_e th1 th2 =
   let premise1 = get_verdict th1 in 
   let premise2 = get_verdict th2 in
   match premise1.concl with
   | False | Var _ -> failwith "th1 conclusion is not implication"
   | Imp (phi, psi) -> if phi <> premise2.concl then failwith "th1 conclusion's premise is not th2 premise conclusion" else  
      ImpErase ({assump=(premise1.assump @ premise2.assump); concl=(psi)}, th1, th2)

   let bot_e f thm =
   match get_verdict thm with
   | {assump=ass; concl=False}-> (Contradiction ({assump=ass; concl=f}, thm))
   | _ -> failwith "thm conclusion is not False"


   let taut = (imp_i (Var "p") (by_assumption (Var "p")))
   let taut2 = (imp_i (Var "p") (imp_i (Var "q") (by_assumption (Var "p"))))

   let imppqr = Imp (Var "p", Imp (Var "q", Var "r"))
   let imppq = Imp (Var "p", Var "q")
   let imppr = Imp (Var "p", Var "r")
   let taut3 = (imp_i (imppqr) (imp_i imppq (by_assumption imppr)))   *)



type formula = False | Var of string | Imp of formula * formula

let rec string_of_formula f =
  match f with
    False -> "⊥"
  | Var str -> str
  | Imp (f1, f2) -> let str1 = string_of_formula f1 in
    (match f1 with
       Imp (_, _) -> "(" ^ str1 ^ ")"
     | _ -> str1) ^ " ⇒ " ^ string_of_formula f2
;;
(* match (f1, f2) with
   | (Var v1, Var v2) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (Var v1, False) | (False, Var v1) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (False, False) -> (string_of_formula f1) ^ " -> " ^ (string_of_formula f2)
   | (f1, f2) -> "(" ^ (string_of_formula f1) ^ " -> " ^ (string_of_formula f2) ^ ")" *)

let pp_print_formula fmtr f =
  Format.pp_print_string fmtr (string_of_formula f)

type theorem = { assump : formula list; concl : formula }

let assumptions thm = thm.assump
let consequence thm = thm.concl

let pp_print_theorem fmtr thm =
  let open Format in
  pp_open_hvbox fmtr 2;
  begin match assumptions thm with
    | [] -> ()
    | f :: fs ->
      pp_print_formula fmtr f;
      fs |> List.iter (fun f ->
          pp_print_string fmtr ",";
          pp_print_space fmtr ();
          pp_print_formula fmtr f);
      pp_print_space fmtr ()
  end;
  pp_open_hbox fmtr ();
  pp_print_string fmtr "⊢";
  pp_print_space fmtr ();
  pp_print_formula fmtr (consequence thm);
  pp_close_box fmtr ();
  pp_close_box fmtr ()

let by_assumption f =
  { assump=[f]; concl=f }

let imp_i f thm =
  { assump=(List.filter ((<>) f) thm.assump); concl=(Imp (f, thm.concl)) }

let imp_e th1 th2 =
  match th1.concl with
  | False | Var _ -> failwith "th1 conclusion is not implication"
  | Imp (phi, psi) -> if phi <> th2.concl then failwith "th1 conclusion's premise is not th2 premise conclusion" else  
      { assump = th1.assump @ th2.assump; concl = psi}

let bot_e f thm =
  match thm with
  | {assump=ass; concl=False} -> {assump=ass; concl=f}
  | _ -> failwith "thm conclusion is not False"
