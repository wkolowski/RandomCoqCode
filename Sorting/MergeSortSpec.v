Require Import MergeSort.
(*Require Import InsertionSort.*)

Set Implicit Arguments.

Theorem Sorted_ghms :
  forall (n : nat) (A : LinDec)
    (s : Sort A) (split : Split A)
      (l : list A), Sorted A (@ghms n A (@sort A s) split l).
Proof.
  intros. functional induction @ghms n A (@sort A s) split l.
    destruct s; cbn in *. apply Sorted_sort.
    apply Sorted_merge; cbn; assumption.
Qed.

Theorem ghms_perm :
  forall (n : nat) (A : LinDec)
    (s : Sort A) (split : Split A)
      (l : list A), perm A l (@ghms n A (@sort A s) split l).
Proof.
  intros. functional induction @ghms n A (@sort A s) split l.
    apply sort_perm.
    rewrite perm_split_app. rewrite e0; cbn.
      rewrite <- merge_perm; cbn. apply perm_app; assumption.
Qed.

Theorem Permutation_ghms :
  forall (n : nat) (A : LinDec) (s : Sort A) (split : Split A) (l : list A),
    Permutation (@ghms n A (@sort A s) split l) l.
Proof.
  intros. functional induction @ghms n A (@sort A s) split l.
    apply Permutation_sort.
    rewrite <- (@Permutation_app_split _ _ l). rewrite e0; cbn.
      rewrite <- Permutation_merge. cbn. apply Permutation_app; assumption.
Qed.

Instance Sort_ghms
  (n : nat) (A : LinDec) (sort : Sort A) (split : Split A) : Sort A :=
{
    sort := @ghms n A sort split
}.
Proof.
  apply Sorted_ghms.
  intros. apply perm_Permutation. rewrite <- ghms_perm. reflexivity.
Defined.