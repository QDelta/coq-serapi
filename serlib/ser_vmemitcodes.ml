(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016-2019 MINES ParisTech                                  *)
(* Written byo: Emilio J. Gallego Arias                                  *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

open Sexplib.Std
open Ppx_hash_lib.Std.Hash.Builtin
open Ppx_compare_lib.Builtin

module Names = Ser_names
module CPrimitives = Ser_cPrimitives
module Mod_subst = Ser_mod_subst
module Vmvalues = Ser_vmvalues
module Vmbytecodes = Ser_vmbytecodes

[@@@ocaml.warning "-37"]

type _reloc_info =
  | Reloc_annot of Vmvalues.annot_switch
  | Reloc_const of Vmvalues.structured_constant
  | Reloc_getglobal of Names.Constant.t
  | Reloc_proj_name of Names.Projection.Repr.t
  | Reloc_caml_prim of CPrimitives.t
 [@@deriving sexp,yojson,hash,compare]

let hash_fold_array = hash_fold_array_frozen

type _patches = {
  reloc_infos : (_reloc_info * int array) array;
} [@@deriving sexp,yojson,hash,compare]

type _emitcodes = string
 [@@deriving sexp,yojson,hash,compare]

type _to_patch = _emitcodes * _patches * Vmbytecodes.fv
 [@@deriving sexp,yojson,hash,compare]

module PierceToPatch = struct

  type t = Vmemitcodes.to_patch
  type _t = _to_patch
   [@@deriving sexp,yojson,hash,compare]

end

module B = SerType.Pierce(PierceToPatch)

type to_patch = B.t
let sexp_of_to_patch = B.sexp_of_t
let to_patch_of_sexp = B.t_of_sexp
let to_patch_of_yojson = B.of_yojson
let to_patch_to_yojson = B.to_yojson
(* let hash_to_patch = B.hash *)
let hash_fold_to_patch = B.hash_fold_t
let compare_to_patch = B.compare

type body_code =
  [%import: Vmemitcodes.body_code]
  [@@deriving sexp,yojson,hash,compare]
