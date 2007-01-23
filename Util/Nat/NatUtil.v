(**
CoLoR, a Coq library on rewriting and termination.
See the COPYRIGHTS and LICENSE files.

- Sebastien Hinderer, 2004-04-02

useful definitions and lemmas on natural numbers
*)

(* $Id: NatUtil.v,v 1.3 2007-01-23 16:42:56 blanqui Exp $ *)

Set Implicit Arguments.

Require Export LogicUtil.
Require Export Arith.

Implicit Arguments lt_S_n [n m].
Implicit Arguments lt_n_S [n m].

(***********************************************************************)
(** unicity of eq/le/lt proofs *)

Scheme eq_ind_dep := Induction for eq Sort Prop.

Require Export Eqdep.

Implicit Arguments UIP_refl [U x].

Scheme le_ind_dep := Induction for le Sort Prop.

Lemma le_unique : forall n m (h1 h2 : le n m), h1 = h2.

Proof.
intro n.
assert (forall m : nat, forall h1 : le n m, forall p : nat, forall h2 : le n p,
  m=p -> eq_dep nat (le n) m h1 p h2).
 intros m h1; elim h1 using le_ind_dep.
  intros p h2; case h2; intros.
   auto.
   subst n. absurd (S m0 <= m0); auto with arith.
 intros m0 l Hrec p h2. 
  case h2; intros.
   subst n; absurd (S m0 <= m0); auto with arith.
   assert (m0=m1); auto ; subst m0.
   replace l0 with l; auto.
   apply (eq_dep_eq nat (le n)); auto.
 intros; apply (eq_dep_eq nat (le n)); auto.
Qed.

Lemma lt_unique : forall n m (h1 h2 : lt n m), h1 = h2.

Proof.
intros n m. unfold lt. intros. apply le_unique.
Qed.

Lemma eq_nat_dec_refl : forall n, eq_nat_dec n n = left (n<>n) (refl_equal n).

Proof.
induction n; simpl. reflexivity. rewrite IHn. reflexivity.
Qed.

(***********************************************************************)
(** max *)

Require Export Max.

Implicit Arguments max_r [n m].
Implicit Arguments max_l [n m].
Implicit Arguments le_trans [n m p].

Require Export Compare.

Lemma max_assoc : forall a b c, max a (max b c) = max (max a b) c.

Proof.
intros.
case (le_dec b c); intro H.
 rewrite (max_r H).
 case (le_dec a b); intro H'.
  rewrite (max_r (le_trans H' H)).
  rewrite (max_r H'). rewrite (max_r H). reflexivity.
  case (le_dec a c); intro H''; rewrite (max_l H'); reflexivity.
  rewrite (max_l H).
  case (le_dec a b); intro H'.
   rewrite (max_r H').
   apply (sym_equal (max_l H)).
   assert (H'' : c <= max a b). eapply le_trans. apply H. apply le_max_r.
   apply (sym_equal (max_l H'')).
Qed.

Lemma elim_max_l : forall x y z, x <= y -> x <= max y z.

Proof.
intros. eapply le_trans. apply H. apply le_max_l.
Qed.

Lemma elim_max_r : forall x y z, x <= z -> x <= max y z.

Proof.
intros. eapply le_trans. apply H. apply le_max_r.
Qed.

Lemma intro_max_l : forall x y z, max x y <= z -> x <= z.

Proof.
intros. eapply le_trans. 2: apply H. apply le_max_l.
Qed.

Lemma intro_max_r : forall x y z, max x y <= z -> y <= z.

Proof.
intros. eapply le_trans. 2: apply H. apply le_max_r.
Qed.

(***********************************************************************)
(** min *)

Require Export Min.

Lemma elim_min_l : forall x y z, x <= z -> min x y <= z.

Proof.
intros. eapply le_trans. apply le_min_l. exact H.
Qed.

Lemma elim_min_r : forall x y z, y <= z -> min x y <= z.

Proof.
intros. eapply le_trans. apply le_min_r. exact H.
Qed.

(***********************************************************************)
(** minus *)

Require Export Omega.

Lemma plus_minus : forall v p, v+p-p=v.

Proof.
intros. omega.
Qed.
