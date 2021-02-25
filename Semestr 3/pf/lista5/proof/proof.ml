open Logic

type context = (string * formula) list
type goalDesc = context * formula

type proof = 
  | Whole of goalDesc
  | Leaf of theorem
  | ImpInsert of theorem * proof
  | ImpErase of theorem * proof * proof
  | Contradiction of theorem * proof

type goal = Goal of (goalDesc list) * (goalDesc list) * proof

let rec numGoals pf =
  match pf with
  | Whole _ -> 1
  | Leaf _ -> 0
  | ImpInsert (_, pf) | Contradiction (_, pf) -> numGoals pf 
  | ImpErase (_, pf1, pf2) -> (numGoals pf1) + (numGoals pf2)

let qed pf =
  if (numGoals pf) <> 0 then failwith "proof not finished" else
    match pf with
    | Whole _ -> failwith "proof not finished"
    | Leaf thm | ImpInsert (thm, _) | ImpErase (thm, _, _) | Contradiction (thm, _) -> thm

let rec goals pf =
  match pf with
  | Whole gd -> [gd]
  | Leaf _ -> []
  | ImpInsert (_, pf) | Contradiction (_, pf) -> goals pf
  | ImpErase (_, pf1, pf2) -> (goals pf1) @ (goals pf2) 

let proof g f =
  Whole (g, f)

let goal (Goal (bef, aft, pf)) = 
  if aft == [] then failwith "Goal is empty" else (List.hd aft)  

let focus n pf =
  let add_goal (Goal (bef, aft, pf)) gl =
    Goal (bef, gl::aft, pf)
  in let goal = List.fold_left add_goal (Goal ([], [], pf)) (goals pf) in

  let unfocus gl =
    (* TODO: zaimplementuj *)
    failwith "not implemented"

let next gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let prev gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let intro name gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let apply f gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let apply_thm thm gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let apply_assm name gl =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let pp_print_proof fmtr pf =
  let ngoals = numGoals pf
  and goals = goals pf
  in if ngoals = 0
  then Format.pp_print_string fmtr "No more subgoals"
  else begin
    Format.pp_open_vbox fmtr (-100);
    Format.pp_open_hbox fmtr ();
    Format.pp_print_string fmtr "There are";
    Format.pp_print_space fmtr ();
    Format.pp_print_int fmtr ngoals;
    Format.pp_print_space fmtr ();
    Format.pp_print_string fmtr "subgoals:";
    Format.pp_close_box fmtr ();
    Format.pp_print_cut fmtr ();
    goals |> List.iteri (fun n (_, f) ->
        Format.pp_print_cut fmtr ();
        Format.pp_open_hbox fmtr ();
        Format.pp_print_int fmtr (n + 1);
        Format.pp_print_string fmtr ":";
        Format.pp_print_space fmtr ();
        pp_print_formula fmtr f;
        Format.pp_close_box fmtr ());
    Format.pp_close_box fmtr ()
  end

let pp_print_goal fmtr gl =
  let (g, f) = goal gl
  in
  Format.pp_open_vbox fmtr (-100);
  g |> List.iter (fun (name, f) ->
      Format.pp_print_cut fmtr ();
      Format.pp_open_hbox fmtr ();
      Format.pp_print_string fmtr name;
      Format.pp_print_string fmtr ":";
      Format.pp_print_space fmtr ();
      pp_print_formula fmtr f;
      Format.pp_close_box fmtr ());
  Format.pp_print_cut fmtr ();
  Format.pp_print_string fmtr (String.make 40 '=');
  Format.pp_print_cut fmtr ();
  pp_print_formula fmtr f;
  Format.pp_close_box fmtr ()
