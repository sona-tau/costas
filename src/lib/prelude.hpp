#pragma once
#include <cstdint>
#include <vector>
#define fn [[nodiscard, gnu::const]] auto

template <class T> using Vec = std::vector<T>;
using Bool = bool;
using Int = int;
using UInt = unsigned int;
using Size = std::size_t;
// namespace ra = std::ranges;
namespace vi = std::ranges::views;
using U64 = std::uint64_t;
using U32 = std::uint32_t;
using I32 = std::int32_t;
typedef std::int64_t I64;
