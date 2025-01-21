.POSIX:

SRC := $(shell find src/ -type f -regex ".*\.cpp")
CXX = ccache clang++
LIBS = -lm
CXXWARNS = -pedantic -Werror -Weffc++ -Wno-padded -Ofast
CXXFLAGS = -std=c++2c $(LIBS) $(CXXWARNS) -fopenmp

build/a.out: $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

run: build/a.out
	./build/a.out

format:
	clang-format -i $(shell find src/ -type f)

.PHONY: clean build/a.out

clean:
	rm -f build/*

check:
	cppcheck . --check-level=exhaustive
	clang-tidy $(shell find src/ -type f) -- -std=c++23

test: $(SRC)
	$(CXX) $(CXXFLAGS) -o ./build/a.out $^ -DTEST
	./build/a.out
