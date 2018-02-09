Add Rec LoadPath "/home/zeimer/Code/Coq".

Require Import RCCBase.

(* TODO *) Module Type Queue.

Parameter Queue : Type -> Type.

Parameter empty :
  forall {A : Type}, Queue A.

Parameter isEmpty :
  forall {A : Type}, Queue A -> bool.

Parameter snoc :
  forall {A : Type}, A -> Queue A -> Queue A.

Parameter head :
  forall {A : Type}, Queue A -> option A.

Parameter tail :
  forall {A : Type}, Queue A -> option (Queue A).

(* Properties of [isEmpty]. *)
Parameter isEmpty_empty :
  forall A : Type, isEmpty (@empty A) = true.

Parameter isEmpty_snoc :
  forall (A : Type) (x : A) (q : Queue A),
    isEmpty (snoc x q) = false.

Parameter isEmpty_head_true :
  forall (A : Type) (q : Queue A),
    isEmpty q = true (*TODO: <*)-> head q = None.

Parameter isEmpty_head_false :
  forall (A : Type) (q : Queue A),
    isEmpty q = false <-> exists h : A, head q = Some h.

Parameter isEmpty_tail_false :
  forall (A : Type) (q : Queue A),
    isEmpty q = false <-> exists q' : Queue A, tail q = Some q'.

Parameter isEmpty_tail_true :
  forall (A : Type) (q : Queue A),
    isEmpty q = true <-> tail q = None.

(* Properties of [head]. *)
Parameter head_empty :
  forall A : Type, head (@empty A) = None.

Parameter head_singl :
  forall (A : Type) (x : A),
    head (snoc x empty) = Some x.

Parameter head_snoc_false :
  forall (A : Type) (x : A) (q : Queue A),
    isEmpty q = false -> head (snoc x q) = head q.

Parameter head_snoc_true :
  forall (A : Type) (x : A) (q : Queue A),
    isEmpty q = true -> head (snoc x q) = Some x.

(* Properties of tail. *)
Parameter tail_empty :
  forall A : Type, tail (@empty A) = None.

Parameter tail_singl :
  forall (A : Type) (x : A),
    tail (snoc x empty) = Some empty.

Hint Rewrite isEmpty_empty isEmpty_snoc head_empty head_singl
             tail_empty tail_singl : Queue.

End Queue.

(* [fmap] and its properties. *)
(*Parameter fmap :
  forall {A B : Type}, (A -> B) -> Queue A -> Queue B.

Parameter fmap_empty :
  forall (A B : Type) (f : A -> B),
    fmap f (@empty) = @empty B.

Parameter fmap_isEmpty :
  forall (A B : Type) (f : A -> B) (q : Queue A),
    isEmpty (fmap f q) = isEmpty q.

Parameter fmap_snoc :
  forall (A B : Type) (f : A -> B) (x : A) (q : Queue A),
    fmap f (snoc x q) = snoc (f x) (fmap f q).

Parameter fmap_head :
  forall (A B : Type) (f : A -> B) (q : Queue A),
    head (fmap f q) =
    match head q with
        | None => None
        | Some x => Some (f x)
    end.

Parameter fmap_tail :
  forall (A B : Type) (f : A -> B) (q q' : Queue A),
    tail q = Some q' -> tail (fmap f q) = Some (fmap f q').

Parameter fmap_size :
  forall (A B : Type) (f : A -> B) (q : Queue A),
    size (fmap f q) = size q.*)

Module Type SizedQueue (Q : Queue).

Import Q.

Parameter size :
  forall {A : Type}, Queue A -> nat.

Parameter size_empty :
  forall A : Type, size (@empty A) = 0.

Parameter size_snoc :
  forall (A : Type) (x : A) (q : Queue A),
    size (snoc x q) = S (size q).

Parameter size_tail :
  forall (A : Type) (q q' : Queue A),
    tail q = Some q' -> size q' = pred (size q).

Parameter size_isEmpty_true :
  forall (A : Type) (q : Queue A),
    isEmpty q = true <-> size q = 0.

Parameter size_isEmpty_false :
  forall (A : Type) (q : Queue A),
    isEmpty q = false <-> size q <> 0.

End SizedQueue.

Module ConstantSizedQueue_Queue (Q : Queue) : Queue.

Definition Queue (A : Type) := (nat * Q.Queue A)%type.

Definition empty {A : Type} : Queue A := (0, Q.empty).

Definition isEmpty {A : Type} (q : Queue A) : bool :=
  Q.isEmpty (snd q).

Definition snoc {A : Type} (x : A) (q : Queue A) : Queue A :=
  let '(n, q') := q in (S n, Q.snoc x q').

Definition head {A : Type} (q : Queue A) : option A :=
  Q.head (snd q).

Definition tail {A : Type} (q : Queue A) : option (Queue A) :=
  let '(n, q') := q in
match Q.tail q' with
    | None => None
    | Some q'' => Some (pred n, q'')
end.

Ltac sized := repeat
match goal with
    | |- forall q : Queue _, _ => destruct q
    | |- forall _, _ => intro
end;
  compute; autorewrite with Queue; try reflexivity.

Lemma isEmpty_empty : forall A : Type, isEmpty (@empty A) = true.
Proof. sized. Qed.

Lemma isEmpty_snoc :
  forall (A : Type) (x : A) (q : Queue A), isEmpty (snoc x q) = false.
Proof. sized. Qed.

Lemma isEmpty_head_true :
  forall (A : Type) (q : Queue A), isEmpty q = true (*<*)-> head q = None.
Proof. sized. Admitted.

(*  Hint Resolve Q.isEmpty_head_true : wut.
  Check Q.isEmpty_head_true. auto with wut. auto with wut.*)

Lemma isEmpty_head_false :
  forall (A : Type) (q : Queue A),
    isEmpty q = false <-> exists h : A, head q = Some h.
Proof. sized. Admitted.

Lemma isEmpty_tail_false :
  forall (A : Type) (q : Queue A),
    isEmpty q = false <-> (exists q' : Queue A, tail q = Some q').
Proof. sized. Admitted.

Lemma isEmpty_tail_true :
  forall (A : Type) (q : Queue A), isEmpty q = true <-> tail q = None.
Proof. sized. Admitted.

Lemma head_empty :
  forall A : Type, head (@empty A) = None.
Proof. sized. Qed.

Lemma head_singl :
  forall (A : Type) (x : A), head (snoc x empty) = Some x.
Proof. sized. Qed.

Lemma head_snoc_false :
  forall (A : Type) (x : A) (q : Queue A),
    isEmpty q = false -> head (snoc x q) = head q.
Proof. sized. Admitted.

Lemma head_snoc_true :
  forall (A : Type) (x : A) (q : Queue A),
    isEmpty q = true -> head (snoc x q) = Some x.
Proof. sized. Admitted.

Lemma tail_empty :
  forall A : Type, tail (@empty A) = None.
Proof. sized. Qed.

Lemma tail_singl :
  forall (A : Type) (x : A), tail (snoc x empty) = Some empty.
Proof. sized. Qed.

End ConstantSizedQueue_Queue.

(*Module ConstantSizedQueue (Q : Queue)
  : SizedQueue (ConstantSizedQueue_Queue Q).

End ConstantSizedQueue.
 ConstantSizedQueue_Queue.*)