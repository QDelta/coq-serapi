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
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)
(* Status: Very Experimental                                            *)
(************************************************************************)

open Sexplib.Conv

module ST = Safe_typing
module LB = Names.Label

open Serlib

module Names = Ser_names
module Univ = Ser_univ
module Constr = Ser_constr
module Declarations = Ser_declarations
module Entries = Ser_entries
module Safe_typing = Ser_safe_typing

open Names

module Event = struct
  type t =
    | Require of (DirPath.t * string) list * bool option
    | Constant of Label.t * Safe_typing.global_declaration
    | Private_constant of Label.t * Safe_typing.side_effect_declaration
    | Inductive of Label.t * Entries.mutual_inductive_entry
    | Constraints of Univ.Constraint.t
    | Named_assum of Id.t * Constr.types
    | Named_def of Id.t * Entries.section_def_entry
    | Push_context_set of bool * Univ.ContextSet.t
    | Push_section_context of Name.t array * Univ.UContext.t
    | Lib_start of DirPath.t
    | Mod_impl of Label.t * Entries.module_entry * Declarations.inline
    | Mod_start of Label.t
    | Mod_end of Label.t * (Entries.module_struct_entry * Declarations.inline) option
    | Mod_param of MBId.t * Entries.module_struct_entry * Declarations.inline
    | Mod_include of Entries.module_struct_entry * bool * Declarations.inline
    | Mod_type_start of Label.t
    | Mod_type_end of Label.t
    | Mod_type of Label.t * Entries.module_type_entry * Declarations.inline
    | Env_snapshot of int
    | Env_restore of int
    | Other of string
  [@@deriving sexp]
end

let trace = ref []

let sercomp_log_st = Event.(ST.
  { constant = (fun (l, decl) -> trace := (Constant (l, decl))::!trace)
  ; private_constant = (fun (l, decl) -> trace := (Private_constant (l, decl))::!trace)
  ; mind = (fun (l, mind) -> trace := (Inductive (l,mind))::!trace)
  ; constraints = (fun cst -> trace := (Constraints cst)::!trace)
  ; named_assum = (fun (c,u) -> trace := (Named_assum (c,u))::!trace)
  ; named_def = (fun (id,s) -> trace := (Named_def (id,s))::!trace)
  ; push_context_set = (fun (poly,ctx) -> trace := Push_context_set (poly,ctx)::!trace)
  ; push_section_context = (fun (ids,ctx) -> trace := Push_section_context (ids,ctx)::!trace)
  ; lib_start = (fun dp -> trace := (Lib_start dp)::!trace)
  ; mod_impl = (fun (a,b,c) -> trace := Mod_impl (a,b,c)::!trace)
  ; mod_start = (fun lb -> trace := Mod_start lb::!trace)
  ; mod_end = (fun (lb,me) -> trace := Mod_end (lb,me)::!trace)
  ; mod_param = (fun (a,b,c) -> trace := Mod_param (a,b,c)::!trace)
  ; mod_include = (fun (a,b,c) -> trace := Mod_include (a,b,c)::!trace)
  ; mod_type_ = (fun (a,b,c) -> trace := Mod_type (a,b,c)::!trace)
  ; mod_type_start = (fun lb -> trace := Mod_type_start lb::!trace)
  ; mod_type_end = (fun lb -> trace := Mod_type_end lb::!trace)
  ; other = (fun str -> trace := (Other str)::!trace)
  })

let sercomp_log_lib = Event.(Lib.
  { snapshot_env = (fun id -> trace := Env_snapshot id::!trace)
  ; restore_env = (fun id -> trace := Env_restore id::!trace)
  })

let sercomp_log_library = Event.(Library.
  { require = (fun libs export -> trace := (Require(libs,export))::!trace) })

let init () =
  ST.set_trace_ops sercomp_log_st;
  Lib.set_trace_ops sercomp_log_lib;
  Library.set_trace_ops sercomp_log_library

let dump pp =
  List.iter Format.(printf "@[%a@]@\n%!" pp) List.(rev_map Event.sexp_of_t !trace)

let env_map = ref Int.Map.empty

(* XXX: We are using the global env, for now that should be good, but
   beware. *)
let replay (e : Event.t) =
  match e with
  | Require (modrefl,exports) ->
    let lib_resolver = Loadpath.try_locate_absolute_library in
    Library.require_library_from_dirpath ~lib_resolver modrefl exports
  | Constant (l, decl) ->
    let _kname = Global.add_constant LB.(to_id l) decl in ()
  | Private_constant (l, decl) ->
    let _kname = Global.add_private_constant LB.(to_id l) decl in ()
  | Inductive (l, mind) ->
    let _kname = Global.add_mind LB.(to_id l) mind in ()
  | Constraints c ->
    Global.add_constraints c
  | Named_assum (c,u) ->
    Global.push_named_assum (c,u)
  | Named_def (id,c) ->
    Global.push_named_def (id, c)
  | Push_context_set (poly,ctx) ->
    Global.push_context_set poly ctx
  | Push_section_context (ids,ctx) ->
    Global.push_section_context (ids,ctx)
  | Lib_start dp ->
    ignore (Global.start_library dp)
  | Mod_impl (a,b,c)->
    ignore (Global.add_module LB.(to_id a) b c)
  | Mod_start lb ->
    ignore (Global.start_module LB.(to_id lb))
  | Mod_end (a,b)->
    (* XXX This is wrong // *)
    let fs = Summary.freeze_summaries ~marshallable:false in
    ignore (Global.end_module fs LB.(to_id a) b)
  | Mod_param (a,b,c)->
    ignore (Global.add_module_parameter a b c)
  | Mod_include (a,b,c)->
    ignore (Global.add_include a b c)
  | Mod_type (a,b,c)->
    ignore (Global.add_modtype LB.(to_id a) b c)
  | Mod_type_start lb ->
    ignore (Global.start_modtype LB.(to_id lb))
  | Mod_type_end lb ->
    (* XXX This is wrong // *)
    let fs = Summary.freeze_summaries ~marshallable:false in
    ignore (Global.end_modtype fs LB.(to_id lb))
  (* Open section *)
  | Env_snapshot id ->
    let env = Summary.(project_from_summary (freeze_summaries ~marshallable:false) Global.global_env_summary_tag) in
    env_map := Int.Map.add id env !env_map;
    Global.open_section ()
  | Env_restore id ->
    let env = Int.Map.find id !env_map in
    let fs = Summary.freeze_summaries ~marshallable:false in
    let fs = Summary.modify_summary fs Global.global_env_summary_tag env in
    (* Summary.unfreeze_summaries fs; *)
    Global.close_section fs
  | Other _ ->
    ()
