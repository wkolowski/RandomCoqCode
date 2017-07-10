Add Rec LoadPath "/home/zeimer/Code/Coq".

Require Import InsertionSort.
Require Import SelectionSort.
Require Import QuickSort.
Require Import MergeSort2.

Require Import HybridSorts.

Set Implicit Arguments.

Time Eval compute in insertionSort natle testl.
Time Eval compute in ssFun natle testl.
Time Eval compute in qsFun natle testl.
Time Eval compute in msFun2 natle testl.

Fixpoint cycle {A : Type} (n : nat) (l : list A) : list A :=
match n with
    | 0 => []
    | S n' => l ++ cycle n' l
end.

Time Compute insertionSort natle (cycle 200 testl). (* 0.304 *)
(*Time Compute ssFun natle (cycle 200 testl).*)
(*Time Compute qs natle (cycle 200 testl).       
Time Compute qs2 natle (cycle 200 testl).      *)
Time Compute hqs natle 2048 (cycle 200 testl).
Time Compute msFun2 natle (cycle 200 testl).        (* 0.872 *)



