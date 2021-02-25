open Logic

type context = (string * formula) list
type goalDesc = context * formula

type proof = 
  | Assumption of theorem
  | ImpInsert of theorem * proof
  | ImpErase of theorem * proof * proof
  | Contradiction of theorem * proof
  | Whole of goalDesc

type goal (* = TODO: tu wpisz swoją definicję *)

let qed pf =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let numGoals pf =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let goals pf =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let proof g f =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let goal pf =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

let focus n pf =
  (* TODO: zaimplementuj *)
  failwith "not implemented"

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
