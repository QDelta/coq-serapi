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

module Univ = Ser_univ

type family =
  [%import: Sorts.family]
  [@@deriving sexp,yojson,hash,compare]

module BijectQVar = struct
  open Sexplib.Std
  open Ppx_hash_lib.Std.Hash.Builtin
  open Ppx_compare_lib.Builtin
  type t = Sorts.QVar.t
  type _t = [%import: Sorts.QVar.repr] [@@deriving sexp,yojson,hash,compare]
  let of_t = Sorts.QVar.repr
  let to_t = Sorts.QVar.of_repr
end

module QVar = struct
  module Self = SerType.Biject(BijectQVar)
  include Self

  module Set = Ser_cSet.Make(Sorts.QVar.Set)(Self)
end

module Quality = struct
  type constant = [%import: Sorts.Quality.constant] [@@deriving sexp,yojson,hash,compare]
  module Self = struct
    type t = [%import: Sorts.Quality.t] [@@deriving sexp,yojson,hash,compare]
  end
  include Self
  module Set = Ser_cSet.Make(Sorts.Quality.Set)(Self)
end

module PierceSpec = struct
  type t = Sorts.t
  type _t =
    | SProp
    | Prop
    | Set
    | Type of Univ.Universe.t
    | QSort of QVar.t * Univ.Universe.t
  [@@deriving sexp,yojson,hash,compare]
end

include SerType.Pierce(PierceSpec)

type relevance =
  [%import: Sorts.relevance]
  [@@deriving sexp,yojson,hash,compare]

module QConstraint = struct
  type kind =
    [%import: Sorts.QConstraint.kind]
    [@@deriving sexp,yojson,hash,compare]

  type t =
    [%import: Sorts.QConstraint.t]
    [@@deriving sexp,yojson,hash,compare]
end

module QConstraints = Ser_cSet.Make(Sorts.QConstraints)(QConstraint)
