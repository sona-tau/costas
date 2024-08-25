#pragma once
#include "prelude.hpp"

fn is_primitive_root(UInt p, Int a) noexcept -> Bool;

fn primitive_roots(UInt p) noexcept -> Vec<UInt>;

fn seq(UInt p, UInt a) noexcept -> Vec<UInt>;

fn lempel(UInt p) noexcept -> Vec<Vec<Char>>;

fn inline mod_mul(I64 a, I64 b, I64 m) noexcept -> I64;

fn mod_pow(I64 base, I64 exp, I64 m) noexcept -> I64;

fn mod_pow_bin(I64 base, I64 exp, I64 m) noexcept -> I64;

fn is_permutation_matrix(Vec<UInt> a) noexcept -> Bool;
