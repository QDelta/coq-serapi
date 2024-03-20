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
(* Status: Very Experimental                                            *)
(************************************************************************)

(* open Sexplib *)
(* open Sexplib.Std *)
(* open Ppx_hash_lib.Std.Hash.Builtin *)
(* open Ppx_compare_lib.Builtin *)

(* module UVars = Ser_uvars *)

type t =
  [%import: CPrimitives.t]
  [@@deriving sexp,yojson,hash,compare]

type const =
  [%import: CPrimitives.const]
  [@@deriving sexp,yojson,hash,compare]

(* GADTs ... *)
module PTP = struct

  type 'a t = 'a CPrimitives.prim_type

  [@@@ocaml.warning "-27"]

  (* Non-GADT version *)
  type 'a _t =
    | PT_int63
    | PT_float64
    | PT_array
  [@@deriving sexp,yojson,hash,compare]
end

module Prim_type_ = SerType.Pierce1(PTP)
type 'a prim_type = 'a Prim_type_.t
  [@@deriving sexp,yojson,hash,compare]

module OOTP = struct

  type ptype =
    | PT_int63
    | PT_float64
    | PT_array
  [@@deriving sexp,yojson,hash,compare]

  (* op_or_type *)
  type _t =
    | OT_op of t
    | OT_type of ptype
    | OT_const of const
  [@@deriving sexp,yojson,hash,compare]

  type t = CPrimitives.op_or_type
end

module Op_or_type_ = SerType.Pierce(OOTP)
type op_or_type = Op_or_type_.t
  [@@deriving sexp,yojson,hash,compare]
