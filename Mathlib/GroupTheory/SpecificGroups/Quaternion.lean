/-
Copyright (c) 2021 Julian Kuelshammer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Julian Kuelshammer
-/
import Mathlib.GroupTheory.SpecificGroups.Cyclic
import Mathlib.GroupTheory.SpecificGroups.Dihedral

/-!
# Quaternion Groups

We define the (generalised) quaternion groups `QuaternionGroup n` of order `4n`, also known as
dicyclic groups, with elements `a i` and `xa i` for `i : ZMod n`. The (generalised) quaternion
groups can be defined by the presentation
$\langle a, x | a^{2n} = 1, x^2 = a^n, x^{-1}ax=a^{-1}\rangle$. We write `a i` for
$a^i$ and `xa i` for $x * a^i$. For `n=2` the quaternion group `QuaternionGroup 2` is isomorphic to
the unit integral quaternions `(Quaternion ℤ)ˣ`.

## Main definition

`QuaternionGroup n`: The (generalised) quaternion group of order `4n`.

## Implementation notes

This file is heavily based on `DihedralGroup` by Shing Tak Lam.

In mathematics, the name "quaternion group" is reserved for the cases `n ≥ 2`. Since it would be
inconvenient to carry around this condition we define `QuaternionGroup` also for `n = 0` and
`n = 1`. `QuaternionGroup 0` is isomorphic to the infinite dihedral group, while
`QuaternionGroup 1` is isomorphic to a cyclic group of order `4`.

## References

* https://en.wikipedia.org/wiki/Dicyclic_group
* https://en.wikipedia.org/wiki/Quaternion_group

## TODO

Show that `QuaternionGroup 2 ≃* (Quaternion ℤ)ˣ`.

-/


/-- The (generalised) quaternion group `QuaternionGroup n` of order `4n`. It can be defined by the
presentation $\langle a, x | a^{2n} = 1, x^2 = a^n, x^{-1}ax=a^{-1}\rangle$. We write `a i` for
$a^i$ and `xa i` for $x * a^i$.
-/
inductive QuaternionGroup (n : ℕ) : Type
  | a : ZMod (2 * n) → QuaternionGroup n
  | xa : ZMod (2 * n) → QuaternionGroup n
  deriving DecidableEq

namespace QuaternionGroup

variable {n : ℕ}

/-- Multiplication of the dihedral group.
-/
private def mul : QuaternionGroup n → QuaternionGroup n → QuaternionGroup n
  | a i, a j => a (i + j)
  | a i, xa j => xa (j - i)
  | xa i, a j => xa (i + j)
  | xa i, xa j => a (n + j - i)

/-- The identity `1` is given by `aⁱ`.
-/
private def one : QuaternionGroup n :=
  a 0

instance : Inhabited (QuaternionGroup n) :=
  ⟨one⟩

/-- The inverse of an element of the quaternion group.
-/
private def inv : QuaternionGroup n → QuaternionGroup n
  | a i => a (-i)
  | xa i => xa (n + i)

/-- The group structure on `QuaternionGroup n`.
-/
instance : Group (QuaternionGroup n) where
  mul := mul
  mul_assoc := by
    rintro (i | i) (j | j) (k | k) <;> simp only [(· * ·), mul] <;> ring_nf
    congr
    calc
      -(n : ZMod (2 * n)) = 0 - n := by rw [zero_sub]
      _ = 2 * n - n := by norm_cast; simp
      _ = n := by ring
  one := one
  one_mul := by
    rintro (i | i)
    · exact congr_arg a (zero_add i)
    · exact congr_arg xa (sub_zero i)
  mul_one := by
    rintro (i | i)
    · exact congr_arg a (add_zero i)
    · exact congr_arg xa (add_zero i)
  inv := inv
  inv_mul_cancel := by
    rintro (i | i)
    · exact congr_arg a (neg_add_cancel i)
    · exact congr_arg a (sub_self (n + i))

@[simp]
theorem a_mul_a (i j : ZMod (2 * n)) : a i * a j = a (i + j) :=
  rfl

@[simp]
theorem a_mul_xa (i j : ZMod (2 * n)) : a i * xa j = xa (j - i) :=
  rfl

@[simp]
theorem xa_mul_a (i j : ZMod (2 * n)) : xa i * a j = xa (i + j) :=
  rfl

@[simp]
theorem xa_mul_xa (i j : ZMod (2 * n)) : xa i * xa j = a ((n : ZMod (2 * n)) + j - i) :=
  rfl

@[simp]
theorem a_zero : a 0 = (1 : QuaternionGroup n) := by
  rfl

theorem one_def : (1 : QuaternionGroup n) = a 0 :=
  rfl

private def fintypeHelper : ZMod (2 * n) ⊕ ZMod (2 * n) ≃ QuaternionGroup n where
  invFun i :=
    match i with
    | a j => Sum.inl j
    | xa j => Sum.inr j
  toFun i :=
    match i with
    | Sum.inl j => a j
    | Sum.inr j => xa j
  left_inv := by rintro (x | x) <;> rfl
  right_inv := by rintro (x | x) <;> rfl

/-- The special case that more or less by definition `QuaternionGroup 0` is isomorphic to the
infinite dihedral group. -/
def quaternionGroupZeroEquivDihedralGroupZero : QuaternionGroup 0 ≃* DihedralGroup 0 where
  toFun
    | a j => DihedralGroup.r j
    | xa j => DihedralGroup.sr j
  invFun
    | DihedralGroup.r j => a j
    | DihedralGroup.sr j => xa j
  left_inv := by rintro (k | k) <;> rfl
  right_inv := by rintro (k | k) <;> rfl
  map_mul' := by rintro (k | k) (l | l) <;> simp

/-- If `0 < n`, then `QuaternionGroup n` is a finite group.
-/
instance [NeZero n] : Fintype (QuaternionGroup n) :=
  Fintype.ofEquiv _ fintypeHelper

instance : Nontrivial (QuaternionGroup n) :=
  ⟨⟨a 0, xa 0, by simp [← a_zero]⟩⟩

/-- If `0 < n`, then `QuaternionGroup n` has `4n` elements.
-/
theorem card [NeZero n] : Fintype.card (QuaternionGroup n) = 4 * n := by
  rw [← Fintype.card_eq.mpr ⟨fintypeHelper⟩, Fintype.card_sum, ZMod.card, two_mul]
  ring

@[simp]
theorem a_one_pow (k : ℕ) : (a 1 : QuaternionGroup n) ^ k = a k := by
  induction k with
  | zero => rw [Nat.cast_zero]; rfl
  | succ k IH =>
    rw [pow_succ, IH, a_mul_a]
    congr 1
    norm_cast

theorem a_one_pow_n : (a 1 : QuaternionGroup n) ^ (2 * n) = 1 := by
  simp

@[simp]
theorem xa_sq (i : ZMod (2 * n)) : xa i ^ 2 = a n := by simp [sq]

@[simp]
theorem xa_pow_four (i : ZMod (2 * n)) : xa i ^ 4 = 1 := by
  calc xa i ^ 4
      = a (n + n)  := by simp [pow_succ, add_sub_assoc, sub_sub_cancel]
    _ = a ↑(2 * n) := by simp [Nat.cast_add, two_mul]
    _ = 1          := by simp

/-- If `0 < n`, then `xa i` has order 4.
-/
@[simp]
theorem orderOf_xa [NeZero n] (i : ZMod (2 * n)) : orderOf (xa i) = 4 := by
  change _ = 2 ^ 2
  haveI : Fact (Nat.Prime 2) := Fact.mk Nat.prime_two
  apply orderOf_eq_prime_pow
  · intro h
    simp only [pow_one, xa_sq] at h
    injection h with h'
    apply_fun ZMod.val at h'
    apply_fun (· / n) at h'
    simp only [ZMod.val_natCast, ZMod.val_zero, Nat.zero_div, Nat.mod_mul_left_div_self,
      Nat.div_self (NeZero.pos n), reduceCtorEq] at h'
  · norm_num

/-- In the special case `n = 1`, `Quaternion 1` is a cyclic group (of order `4`). -/
theorem quaternionGroup_one_isCyclic : IsCyclic (QuaternionGroup 1) := by
  apply isCyclic_of_orderOf_eq_card
  · rw [Nat.card_eq_fintype_card, card, mul_one]
    exact orderOf_xa 0

/-- If `0 < n`, then `a 1` has order `2 * n`.
-/
@[simp]
theorem orderOf_a_one : orderOf (a 1 : QuaternionGroup n) = 2 * n := by
  rcases eq_zero_or_neZero n with hn | hn
  · subst hn
    simp_rw [mul_zero, orderOf_eq_zero_iff']
    intro n h
    rw [one_def, a_one_pow]
    apply mt a.inj
    haveI : CharZero (ZMod (2 * 0)) := ZMod.charZero
    simpa using h.ne'
  apply (Nat.le_of_dvd
    (NeZero.pos _) (orderOf_dvd_of_pow_eq_one (@a_one_pow_n n))).lt_or_eq.resolve_left
  intro h
  have h1 : (a 1 : QuaternionGroup n) ^ orderOf (a 1) = 1 := pow_orderOf_eq_one _
  rw [a_one_pow] at h1
  injection h1 with h2
  rw [← ZMod.val_eq_zero, ZMod.val_natCast, Nat.mod_eq_of_lt h] at h2
  exact absurd h2.symm (orderOf_pos _).ne

/-- If `0 < n`, then `a i` has order `(2 * n) / gcd (2 * n) i`.
-/
theorem orderOf_a [NeZero n] (i : ZMod (2 * n)) :
    orderOf (a i) = 2 * n / Nat.gcd (2 * n) i.val := by
  conv_lhs => rw [← ZMod.natCast_zmod_val i]
  rw [← a_one_pow, orderOf_pow, orderOf_a_one]

theorem exponent : Monoid.exponent (QuaternionGroup n) = 2 * lcm n 2 := by
  rw [← normalize_eq 2, ← lcm_mul_left, normalize_eq]
  norm_num
  rcases eq_zero_or_neZero n with hn | hn
  · subst hn
    simp only [lcm_zero_left, mul_zero]
    exact Monoid.exponent_eq_zero_of_order_zero orderOf_a_one
  apply Nat.dvd_antisymm
  · apply Monoid.exponent_dvd_of_forall_pow_eq_one
    rintro (m | m)
    · rw [← orderOf_dvd_iff_pow_eq_one, orderOf_a]
      refine Nat.dvd_trans ⟨gcd (2 * n) m.val, ?_⟩ (dvd_lcm_left (2 * n) 4)
      exact (Nat.div_mul_cancel (Nat.gcd_dvd_left (2 * n) m.val)).symm
    · rw [← orderOf_dvd_iff_pow_eq_one, orderOf_xa]
      exact dvd_lcm_right (2 * n) 4
  · apply lcm_dvd
    · convert Monoid.order_dvd_exponent (a 1)
      exact orderOf_a_one.symm
    · convert Monoid.order_dvd_exponent (xa (0 : ZMod (2 * n)))
      exact (orderOf_xa 0).symm

end QuaternionGroup
