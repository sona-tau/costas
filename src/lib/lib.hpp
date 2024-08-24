#pragma once
#include "prelude.hpp"

fn is_primitive_root(UInt p, Int a) noexcept -> Bool;

fn primitive_roots(UInt p) noexcept -> Vec<UInt>;

fn seq(UInt p, UInt a) noexcept -> Vec<UInt>;
