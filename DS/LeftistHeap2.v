Require Export LinDec.
Require Import Sorting.Sort.

Set Implicit Arguments.

Inductive RSTree (A : Type) : Type :=
    | empty : RSTree A
    | node : nat -> A -> RSTree A -> RSTree A -> RSTree A.

Arguments empty {A}.
Arguments node {A} _ _ _.

Definition right_spine {A : Type} (t : RSTree A) : nat :=
match t with
    | empty => 0
    | node n _ _ _ => n
end.

Inductive Elem {A : Type} (x : A) : RSTree A -> Prop :=
    | Elem_root : forall (n : nat) (l r : RSTree A),
        Elem x (node n x l r)
    | Elem_left : forall (n : nat) (v : A) (l r : RSTree A),
        Elem x l -> Elem x (node n v l r)
    | Elem_right : forall  (n : nat) (v : A) (l r : RSTree A),
        Elem x r -> Elem x (node n v l r).

Inductive isHeap {A : LinDec} : RSTree A -> Prop :=
    | isHeap_empty : isHeap empty
    | isHeap_node :
        forall  (n : nat) (v : A) (l : RSTree A) (r : RSTree A),
          (forall x : A, Elem x l -> v ≤ x) -> isHeap l ->
          (forall x : A, Elem x r -> v ≤ x) -> isHeap r ->
            isHeap (node n v l r).

Lemma isHeap_inv_l :
  forall (A : LinDec) (n : nat) (v : A) (l r : RSTree A),
    isHeap (node n v l r) -> isHeap l.
Proof.
  inversion 1; eauto.
Qed.

Lemma isHeap_inv_r :
  forall (A : LinDec) (n : nat) (v : A) (l r : RSTree A),
    isHeap (node n v l r) -> isHeap r.
Proof.
  inversion 1; eauto.
Qed.

Lemma isHeap_inv_leq :
  forall (A : LinDec) (n : nat) (v : A) (l r : RSTree A),
    isHeap (node n v l r) -> forall x : A,
      Elem x (node n v l r) -> v ≤ x.
Proof.
  do 2 inversion 1; subst; auto.
Qed.

Hint Resolve isHeap_inv_l isHeap_inv_r : core.

Inductive LeftBiased {A : LinDec} : RSTree A -> Prop :=
    | LeftBiased_empty : LeftBiased empty
    | LeftBiased_node :
        forall (v : A) (l r : RSTree A),
          right_spine r <= right_spine l ->
          LeftBiased l -> LeftBiased r ->
            LeftBiased (node (S (right_spine r)) v l r).

Hint Constructors RSTree Elem isHeap LeftBiased : core.

Ltac lh x :=
  let t := fresh "t" in
  let H := fresh "H" in
  let H' := fresh "H" in
    destruct x as [t H H']; destruct t;
    try inversion H; try inversion H'; subst; cbn.

Definition getMin {A : LinDec} (t : RSTree A) : option A :=
match t with
    | empty => None
    | node _ v _ _ => Some v
end.

Definition singleton' {A : Type} (x : A)
  : RSTree A := node 1 x empty empty.

Ltac elem :=
  intros; unfold singleton' in *; cbn in *; subst; repeat
match goal with
    | |- Elem ?x (node ?x _ _) => constructor
    | H : Elem _ empty |- _ => inv H
    | H : Elem _ (node _ empty empty) |- _ => inv H
    | H : Elem _ _ /\ Elem _ _ |- _ => destruct H
    | H : Elem _ _ \/ Elem _ _ |- _ => destruct H
end; auto.

Definition balance {A : Type} (v : A) (l r : RSTree A) : RSTree A :=
  if right_spine r <=? right_spine l
  then node (S (right_spine r)) v l r
  else node (S (right_spine l)) v r l.

Ltac balance := unfold balance in *;
match goal with
    | H : context [right_spine ?r <=? right_spine ?l] |- _ =>
        destruct (@leqb_spec natle (right_spine r) (right_spine l))
    | |- context [right_spine ?r <=? right_spine ?l] =>
        destruct (@leqb_spec natle (right_spine r) (right_spine l))
end.

Fixpoint size {A : Type} (t : RSTree A) : nat :=
match t with
    | empty => 0
    | node _ _ l r => S (size l + size r)
end.

Lemma size_swap :
  forall (A : Type) (n : nat) (v : A) (l r : RSTree A),
    size (node n v r l) = size (node n v l r).
Proof.
  intros. cbn. lia.
Qed.

Lemma size_balance:
  forall (A : Type) (n : nat) (v : A) (l r : RSTree A),
    size (balance v l r) = size (node n v l r).
Proof.
  intros. balance.
    trivial.
    cbn. lia.
Qed.

Lemma Elem_balance :
  forall (A : Type) (n : nat) (x v : A) (l r : RSTree A),
    Elem x (balance v l r) <-> Elem x (node n v l r).
Proof.
  intros. balance; split; intro; inv H.
Qed.

Theorem isHeap_balance :
  forall (A : LinDec) (n : nat) (v : A) (l r : RSTree A),
    (forall x : A, Elem x l -> v ≤ x) ->
    (forall x : A, Elem x r -> v ≤ x) ->
      isHeap l -> isHeap r -> isHeap (balance v l r).
Proof.
  intros; balance; constructor; elem.
Qed.

Theorem LeftBiased_balance :
  forall (A : LinDec) (v : A) (l r : RSTree A),
    LeftBiased l -> LeftBiased r ->
      LeftBiased (balance v l r).
Proof.
  intros. balance; constructor; cbn in *; dec.
Qed.

Require Import Recdef.

Definition sum_of_sizes {A : Type} (p : RSTree A * RSTree A) : nat :=
  size (fst p) + size (snd p).

Function merge' {A : LinDec} (p : RSTree A * RSTree A)
  {measure sum_of_sizes p} : RSTree A :=
match p with
    | (empty, t2) => t2
    | (t1, empty) => t1
    | (node _ v l r as t1, node _ v' l' r' as t2) =>
        if v <=? v'
        then balance v l (merge' (r, t2))
        else balance v' l' (merge' (t1, r'))
end.
Proof.
  1-2: intros; cbn; lia.
Defined.

Arguments merge' [x] _.

Lemma Elem_merge' :
  forall (A : LinDec) (x : A) (t1 t2 : RSTree A),
    Elem x (merge' (t1, t2)) -> Elem x t1 \/ Elem x t2.
Proof.
  intros. remember (t1, t2) as p. revert x t1 t2 Heqp H.
  functional induction @merge' A p; inv 1; intros.
    rewrite Elem_balance in H. inv H. edestruct IHr; eauto.
    rewrite Elem_balance in H. inv H. edestruct IHr; eauto.
    Unshelve. all: auto.
Qed.

Lemma Elem_merge'_v2 :
  forall (A : LinDec) (x : A) (t1 t2 : RSTree A),
    Elem x t1 \/ Elem x t2 -> Elem x (merge' (t1, t2)).
Proof.
  intros. remember (t1, t2) as p. revert x t1 t2 Heqp H.
  functional induction @merge' A p; inv 1;
  elem; rewrite Elem_balance.
    inv H. apply Elem_right.
      eapply IHr; try ((left + right); eauto); reflexivity.
    apply Elem_right.
      eapply IHr; try ((left + right); eauto); reflexivity.
    apply Elem_right.
      eapply IHr; try ((left + right); eauto); reflexivity.
    inv H. apply Elem_right.
      eapply IHr; try ((left + right); eauto); reflexivity.
    Unshelve. all: auto.
Qed.

Theorem merge'_spec :
  forall (A : LinDec) (x : A) (t1 t2 : RSTree A),
    Elem x (merge' (t1, t2)) <-> Elem x t1 \/ Elem x t2.
Proof.
  split; intros. elem.
    apply Elem_merge'. assumption.
    apply Elem_merge'_v2. assumption.
Qed.

Arguments Elem_merge' [A x t1 t2] _.

Theorem size_merge':
  forall (A : LinDec) (t1 t2 : RSTree A),
    size (merge' (t1, t2)) = size t1 + size t2.
Proof.
  intros. remember (t1, t2) as p. revert t1 t2 Heqp.
  functional induction @merge' A p; inv 1.
    erewrite size_balance. cbn. rewrite (IHr r (node _ v' l' r') eq_refl).
      cbn. lia.
    erewrite size_balance. cbn. rewrite (IHr (node _ v l r) r' eq_refl).
      cbn. lia.
    Unshelve. all: auto.
Qed.

Theorem isHeap_merge' :
  forall (A : LinDec) (t1 t2 : RSTree A),
    isHeap t1 -> isHeap t2 -> isHeap (merge' (t1, t2)).
Proof.
  intros. remember (t1, t2) as p. revert t1 t2 Heqp H H0.
  functional induction @merge' A p; do 3 inv 1; apply isHeap_balance; elem.
    destruct (leqb_spec v v'); inv e0. destruct (Elem_merge' H); auto.
      eapply leq_trans with v'. auto. inv H0.
    eapply (IHr _ _ eq_refl); auto.
    destruct (leqb_spec v v'), (Elem_merge' H); inv e0.
      eapply leq_trans with v. dec. inv H0.
    eapply (IHr _ _ eq_refl); auto.
Qed.

Theorem LeftBiased_merge' :
  forall (A : LinDec) (t1 t2 : RSTree A),
    LeftBiased t1 -> LeftBiased t2 -> LeftBiased (merge' (t1, t2)).
Proof.
  intros. remember (t1, t2) as p. revert t1 t2 Heqp H H0.
  functional induction @merge' A p; do 3 inv 1; cbn in *;
  apply LeftBiased_balance; try eapply IHr; auto.
Qed.

Definition insert' {A : LinDec} (x : A) (t : RSTree A) : RSTree A :=
  merge' ((singleton' x), t).

Definition deleteMin {A : LinDec} (t : RSTree A)
  : option A * RSTree A :=
match t with
    | empty => (None, empty)
    | node _ v l r => (Some v, merge' (l, r))
end.

Theorem deleteMin_spec :
  forall (A : LinDec) (m : A) (t t' : RSTree A),
    isHeap t -> deleteMin t = (Some m, t') ->
      forall x : A, Elem x t' -> m ≤ x.
Proof.
  destruct t; cbn; inversion 1; inversion 1; subst; cbn.
  intros. destruct (Elem_merge' H0); auto.
Qed.

Theorem size_deleteMin:
  forall (A : LinDec) (m : A) (t t' : RSTree A),
    deleteMin t = (Some m, t') -> size t = S (size t').
Proof.
  destruct t; cbn; inversion 1; subst. rewrite size_merge'. trivial.
Qed.

Theorem Elem_deleteMin :
  forall (A : LinDec) (m : A) (t t' : RSTree A),
    deleteMin t = (Some m, t') -> Elem m t.
Proof.
  destruct t; cbn; inversion 1. constructor.
Qed.

Theorem isHeap_deleteMin :
  forall (A : LinDec) (m : A) (t t' : RSTree A),
    isHeap t -> deleteMin t = (Some m, t') ->
      isHeap t'.
Proof.
  destruct t; cbn; inversion 1; inversion 1; subst.
  apply isHeap_merge'; assumption.
Qed.

Theorem LeftBiased_deleteMin :
  forall (A : LinDec) (m : A) (t t' : RSTree A),
    LeftBiased t -> deleteMin t = (Some m, t') ->
      LeftBiased t'.
Proof.
  destruct t; cbn; do 2 inversion 1; subst.
  apply LeftBiased_merge'; assumption.
Qed.

(* Leftist heapsort *)
Function fromList {A : LinDec} (l : list A) : RSTree A :=
match l with
    | [] => empty
    | h :: t => insert' h (fromList t)
end.

Function toList {A : LinDec} (t : RSTree A)
  {measure size t} : list A :=
match deleteMin t with
    | (None, _) => []
    | (Some m, t') => m :: toList t'
end.
Proof.
  destruct t; cbn; inversion 1; inversion 1; subst.
  rewrite size_merge'. lia.
Defined.

Arguments toList [x] _.

Definition leftistHeapsort (A : LinDec) (l : list A)
  : list A := toList (fromList l).