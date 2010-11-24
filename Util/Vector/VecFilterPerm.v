(**
CoLoR, a Coq library on rewriting and termination.
See the COPYRIGHTS and LICENSE files.

- Frederic Blanqui, 2009-09-09

vector filtering with permutations
*)

Set Implicit Arguments.

Require Import VecUtil ListUtil NatUtil LogicUtil ListRepeatFree.

(***********************************************************************)
(** filters are lists of bounded natural numbers *)

Definition nat_lts n := list (nat_lt n).

Lemma in_map_val : forall n (l : nat_lts n) i, In i (map (@val n) l) -> i<n.

Proof.
intros. destruct (in_map_elim H). destruct H0. subst. destruct x. simpl. hyp.
Qed.

Implicit Arguments in_map_val [n l i].

(***********************************************************************)
(** filtering function *)

Fixpoint Vfilter A n (l : nat_lts n) (v : vector A n) : vector A (length l) :=
  match l as l return vector A (length l) with
    | nil => Vnil
    | x :: l' => Vcons (Vnth v (prf x)) (Vfilter l' v)
  end.

(***********************************************************************)
(** properties *)

Lemma Vfilter_eq_notin : forall A n (l : nat_lts n) i (vi : vector A i) t u
  j (vj : vector A j) (e : i+S j=n), (forall hi : i<n, ~In (mk_nat_lt hi) l) ->
  Vfilter l (Vcast (Vapp vi (Vcons t vj)) e)
  = Vfilter l (Vcast (Vapp vi (Vcons u vj)) e).

Proof.
induction l; simpl; intros. refl. apply Vcons_eq. split.
repeat rewrite Vnth_cast. repeat rewrite Vnth_app.
destruct a as [k h]. simpl val. simpl prf. case (le_gt_dec i k); intro.
repeat rewrite Vnth_cons. case (lt_ge_dec 0 (k-i)); intro. refl.
assert (k=i). omega. subst k. ded (H h). firstorder.
refl. apply IHl. firstorder.
Qed.

Lemma Vfilter_app : forall A n (l1 l2 : nat_lts n) (v : vector A n),
  Vfilter (l1 ++ l2) v = Vcast (Vapp (Vfilter l1 v) (Vfilter l2 v))
                               (sym_eq (length_app l1 l2)).

Proof.
induction l1; simpl; intros. rewrite Vcast_refl. refl.
apply Vtail_eq. rewrite (IHl1 l2 v). apply Vcast_pi.
Qed.

Lemma Vfilter_app_eq : forall A n (l l1 l2 : nat_lts n) (v : vector A n)
  (e : length l1+length l2 = length l),
  l=l1++l2 -> Vfilter l v = Vcast (Vapp (Vfilter l1 v) (Vfilter l2 v)) e.

Proof.
intros. subst l. rewrite Vfilter_app. apply Vcast_pi.
Qed.

Implicit Arguments Vfilter_app_eq [A n l l1 l2 v].

Lemma Vfilter_eq_in : forall A n (v : vector A n) (l : nat_lts n)
  (rf : repeat_free (map (@val n) l)) i, In i (map (@val n) l) ->
  exists hi : i<n, exists l1, exists l2,
    exists e : length l1+S(length l2)=length l,
      Vfilter l v
      = Vcast (Vapp (Vfilter l1 v) (Vcons (Vnth v hi) (Vfilter l2 v))) e.

Proof.
intros A n v l rf i i_in_map_l. destruct (in_map_elim i_in_map_l) as [x hx].
destruct hx as [i_in_l i_val]. destruct (in_elim i_in_l) as [l1 [l2 hl]].
subst. destruct x as [i hi]. rewrite map_app in rf.
simpl in *. destruct (repeat_free_app_cons rf) as [h1 h2].
assert (e : length l1+S(length l2)=length(l1++mk_nat_lt hi::l2)).
rewrite length_app. refl. exists hi. exists l1. exists l2. exists e.
rewrite Vfilter_app. simpl. apply Vcast_pi.
Qed.

Implicit Arguments Vfilter_eq_in [A n v l i].

Lemma Vfilter_map : forall A B (f : A -> B) n (v : vector A n) (l : nat_lts n),
  Vfilter l (Vmap f v) = Vmap f (Vfilter l v).

Proof.
induction l; simpl; intros. refl. rewrite IHl. rewrite Vnth_map. refl.
Qed.

Lemma Vin_filter_elim_in : forall A n (l : nat_lts n) (v : vector A n) x,
  Vin x (Vfilter l v) -> Vin x v.

Proof.
induction l; simpl; intros. contradiction. destruct H. subst. apply Vnth_in.
apply IHl. hyp.
Qed.

Lemma Vin_filter_elim_nth : forall A n (l : nat_lts n) (v : vector A n) x,
  Vin x (Vfilter l v) -> exists i, exists hi : i<n,
    In (mk_nat_lt hi) l /\ Vnth v hi = x.

Proof.
induction l; simpl; intros. contradiction. destruct a. simpl prf in H.
destruct H. exists i. exists l0. auto. destruct (IHl _ _ H). destruct H0.
exists x0. exists x1. intuition.
Qed.

Lemma Vin_filter_intro : forall A n (l : nat_lts n) (v : vector A n)
  i (hi : i<n), In (mk_nat_lt hi) l -> Vin (Vnth v hi) (Vfilter l v).

Proof.
induction l; simpl; intros. hyp. destruct a. simpl prf. destruct H.
left. apply Vnth_eq. inversion H. subst. refl.
right. apply IHl. hyp.
Qed.