(**
CoLoR, a Coq library on rewriting and termination.
See the COPYRIGHTS and LICENSE files.

- Sebastien Hinderer, 2004-04-02
- Adam Koprowski, 2007-03-29, Added [mult_gt_0] and [mult_lt_compat_lr]


useful definitions and lemmas on natural numbers
*)

Set Implicit Arguments.

Require Import LogicUtil.
Require Export Arith.
Require Export Omega.

(***********************************************************************)
(** implicit arguments *)

Implicit Arguments lt_S_n [n m].
Implicit Arguments lt_n_S [n m].
Implicit Arguments le_S [n m].
Implicit Arguments gt_le_S [n m].
Implicit Arguments le_lt_n_Sm [n m].
Implicit Arguments lt_le_weak [n m].
Implicit Arguments le_plus_minus [n m].
Implicit Arguments le_plus_minus_r [n m].

(***********************************************************************)
(** tactics *)

Ltac absurd_arith := elimtype False; omega.

(***********************************************************************)
(** relations and morphisms *)

Add Relation nat le
  reflexivity proved by le_refl
  transitivity proved by le_trans
    as le_rel.

Add Relation nat lt
  transitivity proved by lt_trans
    as lt_rel.

Lemma ge_refl : forall x, x >= x.

Proof.
intro. omega.
Qed.

Lemma ge_trans : forall x y z, x >= y -> y >= z -> x >= z.

Proof.
intros. omega.
Qed.

Add Relation nat ge
  reflexivity proved by ge_refl
  transitivity proved by ge_trans
    as ge_rel.

Add Relation nat gt
  transitivity proved by gt_trans
    as gt_rel.

(***********************************************************************)
(** boolean function for equality *)

Fixpoint beq_nat (x y : nat) {struct x} :=
  match x, y with
    | 0, 0 => true
    | S x', S y' => beq_nat x' y'
    | _, _ => false
  end.

Lemma beq_nat_ok : forall x y, beq_nat x y = true <-> x = y.

Proof.
induction x; destruct y; simpl; split; intro; try (refl || discriminate).
apply (f_equal S). exact (proj1 (IHx _) H).
apply (proj2 (IHx y)). inversion H. refl.
Defined.

Require Import EqUtil.

Ltac case_beq_nat := case_beq beq_nat beq_nat_ok.

Lemma eq_nat_dec_refl : forall n, eq_nat_dec n n = left (n<>n) (refl_equal n).

Proof.
intro. generalize (eq_nat_dec n n). destruct s.
rewrite (UIP_refl eq_nat_dec e). refl. irrefl.
Qed.

(***********************************************************************)
(** boolean functions for > and >= *)

Fixpoint bgt_nat (x y : nat) {struct x} :=
  match x, y with
    | 0, _ => false
    | S _, 0 => true
    | S x', S y' => bgt_nat x' y'
  end.

Lemma bgt_nat_ok : forall x y, bgt_nat x y = true <-> x > y.

Proof.
induction x; destruct y; simpl; split; intro;
  try (refl || discr || absurd_arith || omega).
rewrite IHx in H. omega. apply lt_S_n in H.  rewrite IHx. hyp.
Qed.

Ltac check_gt := rewrite <- bgt_nat_ok; check_eq.

Fixpoint bge_nat (x y : nat) {struct x} :=
  match x, y with
    | 0, 0 => true
    | 0, _ => false
    | S _, 0 => true
    | S x', S y' => bge_nat x' y'
  end.

Lemma bge_nat_ok : forall x y, bge_nat x y = true <-> x >= y.

Proof.
induction x; destruct y; simpl; split; intro;
  try (refl || discr || absurd_arith || omega).
rewrite IHx in H. omega. apply le_S_n in H. rewrite IHx. hyp.
Qed.

Ltac check_ge := rewrite <- bge_nat_ok; check_eq.

(***********************************************************************)
(** unicity of eq, le and lt proofs *)

Lemma eq_unique : forall (n m : nat) (h1 h2 : n = m), h1 = h2.

Proof.
intros. apply UIP. apply eq_nat_dec.
Qed.

Scheme le_ind_dep := Induction for le Sort Prop.

Lemma le_unique : forall n m (h1 h2 : n <= m), h1 = h2.

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
   apply (@eq_dep_eq _ eq_nat_dec (le n) m1); auto.
 intros; apply (@eq_dep_eq _ eq_nat_dec (le n) m); auto.
Qed.

Lemma lt_unique : forall n m (h1 h2 : n < m), h1 = h2.

Proof.
intros n m. unfold lt. intros. apply le_unique.
Qed.

Lemma lt_Sn_nS : forall m n (H : m < n), lt_S_n (lt_n_S H) = H.

Proof.
  intros. apply lt_unique.
Qed.

Lemma lt_nS_Sn : forall m n (H : S m < S n), lt_n_S (lt_S_n H) = H.

Proof.
  intros. apply lt_unique.
Qed.

(***********************************************************************)
(** max *)

Require Import Max.

Implicit Arguments max_r [n m].
Implicit Arguments max_l [n m].
Implicit Arguments le_trans [n m p].

Require Import Compare.

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

Lemma le_max_intro_l : forall x y z, x <= y -> x <= max y z.

Proof.
intros. eapply le_trans. apply H. apply le_max_l.
Qed.

Lemma lt_max_intro_l : forall x y z, x < y -> x < max y z.

Proof.
intros. eapply lt_le_trans. eexact H. apply le_max_l.
Qed.

Lemma le_max_intro_r : forall x y z, x <= z -> x <= max y z.

Proof.
intros. eapply le_trans. apply H. apply le_max_r.
Qed.

Lemma lt_max_intro_r : forall x y z, x < z -> x < max y z.

Proof.
intros. rewrite max_comm. apply lt_max_intro_l. assumption.
Qed.

Lemma le_max_elim_l : forall x y z, max x y <= z -> x <= z.

Proof.
intros. eapply le_trans. 2: apply H. apply le_max_l.
Qed.

Lemma le_max_elim_r : forall x y z, max x y <= z -> y <= z.

Proof.
intros. eapply le_trans. 2: apply H. apply le_max_r.
Qed.

Lemma max_ge_compat : forall x y x' y',
  x >= x' -> y >= y' -> max x y >= max x' y'.

Proof.
intros. destruct (max_dec x' y'); rewrite e; unfold ge.
rewrite max_comm. apply le_max_intro_r. assumption.
apply le_max_intro_r. assumption.
Qed.

Lemma max_gt_compat : forall x y x' y',
  x > x' -> y > y' -> max x y > max x' y'.

Proof.
intros. destruct (le_ge_dec x y); destruct (le_ge_dec x' y');
  do 2 first
    [ rewrite max_r; [idtac | assumption] 
    | rewrite max_l; [idtac | assumption]
    ]; omega.
Qed.
 
Lemma max_lt : forall x y z, max y z < x <-> y < x /\ z < x.

Proof.
intuition. eapply le_lt_trans. apply le_max_l. apply H.
eapply le_lt_trans. apply le_max_r. apply H. apply max_case; hyp.
Qed.

Lemma gt_max : forall x y z, x > max y z <-> x > y /\ x > z.

Proof.
exact max_lt.
Qed.

Lemma max_0_r : forall x, max x 0 = x.

Proof.
destruct x; refl.
Qed.

(***********************************************************************)
(** min *)

Require Import Min.

Lemma elim_min_l : forall x y z, x <= z -> min x y <= z.

Proof.
intros. eapply le_trans. apply le_min_l. exact H.
Qed.

Lemma elim_min_r : forall x y z, y <= z -> min x y <= z.

Proof.
intros. eapply le_trans. apply le_min_r. exact H.
Qed.

(***********************************************************************)
(** decidability results on orderings *)

Require Import RelMidex.

Lemma ge_dec : rel_dec ge.

Proof.
intros i j. destruct (le_lt_dec j i); intuition.
Defined. 

Lemma gt_dec : rel_dec gt.

Proof.
intros i j. destruct (le_gt_dec i j); auto with arith.
Defined.

Lemma lt_ge_dec : forall x y, {x < y} + {x >= y}.

Proof.
intros. destruct (lt_eq_lt_dec x y); auto; try destruct s; auto with *.
Defined.

(***********************************************************************)
(** Euclidian division *)

Require Import Euclid.

Lemma mult_is_not_O : forall m n, m * n <> 0 <-> m <> 0 /\ n <> 0.

Proof.
intuition. subst. apply H. refl. subst. apply H. apply mult_0_r.
destruct (mult_is_O _ _ H0); auto.
Qed.

Lemma mult_lt_r_elim : forall x x' y, x * y < x' * y -> x < x'.

Proof.
induction x; induction y; simpl; intros. rewrite mult_0_r in H. omega.
rewrite mult_succ_r in H. omega. repeat rewrite mult_0_r in H. omega.
simpl in *. repeat rewrite mult_succ_r in H. omega.
Qed.

Implicit Arguments mult_lt_r_elim [x x' y].

Lemma eucl_div_unique : forall b q1 r1 q2 r2,
  b > r1 -> b > r2 -> q1 * b + r1 = q2 * b + r2 -> q1 = q2 /\ r1 = r2.

Proof.
intros.
assert ((q1-q2)*b=r2-r1). rewrite mult_minus_distr_r. omega.
assert ((q2-q1)*b=r1-r2). rewrite mult_minus_distr_r. omega.
destruct (le_gt_dec r1 r2).
(* r1 <= r2 *)
destruct (eq_nat_dec r1 r2).
(* r1 = r2 *)
subst. rewrite minus_diag in H2. rewrite minus_diag in H3.
destruct (mult_is_O _ _ H2); destruct (mult_is_O _ _ H3); intuition; omega.
(* r1 < r2 *)
assert (r2 - r1 < b). omega. rewrite <- H2 in H4.
rewrite <- (mult_1_l b) in H4 at -1. ded (mult_lt_r_elim H4).
assert (q1=q2). omega. intuition. subst q2. omega.
(* r1 > r2 *)
assert (r1 - r2 < b). omega. rewrite <- H3 in H4.
rewrite <- (mult_1_l b) in H4 at -1. ded (mult_lt_r_elim H4).
assert (q1=q2). omega. intuition. subst q2. omega.
Qed.

Implicit Arguments eucl_div_unique [b q1 r1 q2 r2].

(***********************************************************************)
(** iteration of a function *)

Section iter.

Variables (A : Type) (f : A -> A).

Fixpoint iter n x :=
  match n with
    | 0 => x
    | S n' => iter n' (f x)
  end.

Lemma iter_com : forall n x, iter n (f x) = f (iter n x).

Proof.
induction n; simpl; intros. refl. rewrite IHn. refl.
Qed.

End iter.

(***********************************************************************)
(** natural numbers strictly smaller than n *)

Definition dom_lt n := { i | i < n }.

Section nat_lt.

Variable n : nat.

Inductive nat_lt : Type := mk_nat_lt : forall i, i<n -> nat_lt.

Definition val (x : nat_lt) := let (i,_) := x in i.
Definition prf (x : nat_lt) := let (_,h) as x return val x < n := x in h.

End nat_lt.

(***********************************************************************)
(** arithmetical lemmas *)

Lemma le_lt_S : forall i k, i <= k -> i < S k.

Proof.
auto with arith.
Qed.

Lemma i_lt_n : forall n i j : nat, n = i + S j -> i < n.

Proof.
intros. omega.
Qed.

Implicit Arguments i_lt_n [n i j].

Lemma S_neq_O : forall n, S n = O -> False.

Proof.
intros. discriminate.
Qed.

Lemma plus_reg_l_inv : forall n1 n2 p2, n2=p2 -> n1+n2=n1+p2.

Proof.
intros. omega.
Qed.

Lemma plus_reg_r_inv : forall n1 p1 n2, n1=p1 -> n1+n2=p1+n2.

Proof.
intros. omega.
Qed.

Lemma plus_minus_eq : forall v p, v+p-p=v.

Proof.
intros. omega.
Qed.

Lemma le_minus_plus : forall v p, p<=v -> v-p+p=v.

Proof.
intros. omega.
Qed.

Implicit Arguments le_minus_plus [v p].

Lemma plus_1_S : forall n, n+1 = S n.

Proof.
intro. omega.
Qed.

Lemma lt_from_le : forall x y, 0 < y -> x <= y-1 -> x < y.

Proof.
intros. omega.
Qed.

Lemma le_from_lt : forall x y, x < y+1 -> x <= y.

Proof.
intros. omega.
Qed.

Lemma lt_pm : forall n k x, n < x -> x <= n+k -> x-n-1 < k.

Proof.
intros. omega.
Qed.

Implicit Arguments lt_pm [n k x].

Lemma le_plus : forall k l, k <= k+l.

Proof.
intros. omega.
Qed.

Lemma misc1 : forall x k, S k = x+2+k-x-1.

Proof.
intros. omega.
Qed.

Lemma misc2 : forall x k, k = x+2+k-(x+1)-1.

Proof.
intros. omega.
Qed.

Lemma mult_gt_0 : forall i j, i > 0 -> j > 0 -> i * j > 0.

Proof.
destruct i; destruct j; intros; solve [absurd_arith | simpl; auto with arith].
Qed.

Lemma mult_lt_compat_lr : forall i j k l,
  i <= j -> j > 0 -> k < l -> i * k < j * l.

Proof.
  destruct i; intros.
  rewrite mult_0_l. apply mult_gt_0. assumption.
  destruct l. absurd_arith. auto with arith.
  simpl. destruct j. absurd_arith.
  simpl. apply plus_lt_le_compat. assumption.
  apply mult_le_compat; omega. 
Qed.

Lemma S_add_S : forall n1 n2 n, n1 + S n2 = n -> S n1 + S n2 = S n.

Proof.
intros. subst n. reflexivity.
Qed.

Implicit Arguments S_add_S [n1 n2 n].

Lemma gt_plus : forall l k, l > k -> exists m, l = (m + 1) + k.

Proof.
induction 1. exists 0. omega. destruct IHle. exists (S x). omega.
Qed.

Implicit Arguments gt_plus [l k].
