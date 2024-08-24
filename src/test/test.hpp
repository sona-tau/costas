#pragma once
#include <string>
#include <cstdint>
#include <iostream>
#include <exception>
#include <format>
using CString = const char *;
using U64 = std::uint64_t;
using String = std::string;

enum class TestFail {};

auto red(String const& in) noexcept -> String;

auto format_err(String const& test_name) noexcept -> String;

class Test {
    String test_name;

    public:
    Test(CString name);

    Test& operator = (auto f) {
        if (f()) {
            std::cout << test_name << ": passed" << std::endl;
        } else {
            std::cerr << test_name << ": failed" << std::endl;
            throw TestFail();
        }
        return *this;
    }


    Test& operator = (std::initializer_list<bool> checks);

    Test& operator = (bool passed);
};

Test operator ""_test(CString str, U64 length);
