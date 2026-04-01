#pragma once
#include <cstdint>
#include <string>
#include <vector>
#include <stdfloat>
#define fn [[nodiscard, gnu::const]] auto
#define let auto const
#define var auto

template <class T> using Vec = std::vector<T>;
template <class T> using Ptr = T*;
template <class T> using Ref = T&;
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
#if __STDCPP_FLOAT64_T__ == 1
    #warning "64-bit float type required"
    using F64 = std::float64_t;
    using F32 = std::float32_t;
    using F16 = std::float16_t;
    using BF16 = std::bfloat16_t;
    using F128 = std::float128_t;
#else
    using F64 = _Float64;
    using F32 = _Float32;
    using F16 = _Float16;
    // using BF16 = __STDCPP_BFLOAT16_T__;
    using F128 = long double;
#endif

using Char = char;
using String = std::string;
using CString = const char *;
