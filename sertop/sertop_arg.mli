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
(* Copyright 2016-2018 MINES ParisTech -- Dual License LGPL 2.1 / GPL3+ *)
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

open Cmdliner

val prelude         : string Term.t
val require_lib     : string option Term.t
val str_pp          : bool Term.t
val de_bruijn       : bool Term.t
val body            : bool Term.t
val async           : string option Term.t
val quick           : bool Term.t
val async_full      : bool Term.t
val deep_edits      : bool Term.t
val async_workers   : int Term.t
val error_recovery  : bool Term.t
val implicit_stdlib : bool Term.t
val printer         : Sertop_ser.ser_printer Term.t
val debug           : bool Term.t
val print0          : bool Term.t
val length          : bool Term.t
val rload_path      : Loadpath.vo_path list Term.t
val load_path       : Loadpath.vo_path list Term.t
val ml_include_path : string list Term.t
val no_init         : bool Term.t
val topfile         : string option Term.t
val no_prelude      : bool Term.t

(* Kernel checking options *)
val set_impredicative_set : bool Term.t
val disallow_sprop  : bool Term.t
val indices_matter  : bool Term.t

(* sertop options *)
type comp_mode = | C_parse | C_stats | C_print | C_sexp | C_check | C_vo | C_env
val comp_mode : comp_mode Term.t

type comp_input = | I_vernac | I_sexp
val comp_input : comp_input Term.t

(* debug options *)
val omit_loc : bool Term.t
val omit_att : bool Term.t
val exn_on_opaque : bool Term.t
val omit_env : bool Term.t
