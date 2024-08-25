#pragma once
#include <cstdint>
#include <string>
#include <vector>
#define fn [[nodiscard, gnu::const]] auto
#define let auto const
#define var auto

template <class T> using Vec = std::vector<T>;
using Bool = bool;
using Int = int;
using UInt = unsigned int;
using Size = std::size_t;
namespace ra = std::ranges;
namespace vi = std::ranges::views;
using U64 = std::uint64_t;
using U32 = std::uint32_t;
using U16 = std::uint16_t;
using U8 = std::uint8_t;
using I64 = std::int64_t;
using I32 = std::int32_t;
using I16 = std::int16_t;
using I8 = std::int8_t;

using Char = char;
using String = std::string;
