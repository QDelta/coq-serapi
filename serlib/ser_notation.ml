(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2016     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(************************************************************************)
(* Coq serialization API/Plugin                                         *)
(* Copyright 2016 MINES ParisTech                                       *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

open Sexplib.Std
open Ppx_hash_lib.Std.Hash.Builtin
open Ppx_compare_lib.Builtin

(* module Ppextend = Ser_ppextend
 * module Notation_term = Ser_notation_term *)

module NumTok = Ser_numTok
module Constrexpr = Ser_constrexpr

type level =
  [%import: Notation.level]
  [@@deriving sexp,yojson,hash,compare]

type numnot_option =
  [%import: Notation.numnot_option]
  [@@deriving sexp,yojson,hash,compare]

