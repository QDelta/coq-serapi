(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2016     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016-2018 MINES ParisTech                                  *)
(************************************************************************)
(* Status: Experimental                                                 *)
(************************************************************************)

open Sexplib.Conv

module Future = Ser_future
module Names  = Ser_names
module Univ   = Ser_univ
module Constr = Ser_constr
module Mod_subst = Ser_mod_subst
module Cooking = Ser_cooking

type proofterm = (Constr.constr * Univ.ContextSet.t) Future.computation
  [@@deriving sexp]

(* type work_list =
 *   [%import: Opaqueproof.work_list]
 *   [@@deriving sexp]
 *
 * type cooking_info =
 *   [%import: Opaqueproof.cooking_info]
 *   [@@deriving sexp]
*)

type _opaque =
  | Indirect of Mod_subst.substitution list * Cooking.cooking_info list * Names.DirPath.t * int (* subst, discharge, lib, index *)
[@@deriving sexp]

type opaque = [%import: Opaqueproof.opaque]

let sexp_of_opaque x = sexp_of__opaque (Obj.magic x)
let opaque_of_sexp x = Obj.magic (_opaque_of_sexp x)

module Map = Ser_cMap.Make(Int.Map)(Ser_int)
type _opaquetab = {
  opaque_val : proofterm Map.t;
  opaque_len : int;
  opaque_dir : Names.DirPath.t;
} [@@deriving sexp]

type opaquetab = [%import: Opaqueproof.opaquetab]
let sexp_of_opaquetab x = sexp_of__opaquetab (Obj.magic x)
let opaquetab_of_sexp x = Obj.magic (_opaquetab_of_sexp x)
