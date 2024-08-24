#include "test.hpp"

Test::Test(CString name) : test_name(name)
{
}

Test& Test::operator=(std::initializer_list<bool> checks)
{
	std::cout << test_name << std::endl;
	U64 counter = 0;
	for (auto check : checks) {
		if (check) {
			std::cout << "\t| " << counter << ": passed";
		} else {
			std::cerr << format_err(test_name) << std::endl;
			throw TestFail();
		}
		++counter;
		std::cout << std::endl;
	}
	return *this;
}

Test operator""_test(CString str, U64 length)
{
	static_cast<void>(length);
	return Test(str);
}

Test& Test::operator=(bool passed)
{
	if (passed) {
		std::cout << test_name << ": passed" << std::endl;
	} else {
		std::cerr << format_err(test_name) << std::endl;
		throw TestFail();
	}
	return *this;
}

auto red(String const& str) noexcept -> String
{
	auto const prefix = "\033[31m";
	auto const suffix = "\033[0m";
	return prefix + str + suffix;
}

auto format_err(String const& test_name) noexcept -> String
{
	return test_name + ": " + red("failed");
}
