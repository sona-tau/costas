.POSIX:

# SRC = src/*.cpp
SRC := $(shell find src/ -type f -regex ".*\.cpp")
CXX = clang++
LIBS = -lm
CXXWARNS = -pedantic -Werror -Weffc++ -Wno-padded
CXXFLAGS = -std=c++23 $(LIBS) $(CXXWARNS)
BLD=build/

$(BLD)/a.out: $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

run: $(BLD)/a.out
	./$(BLD)/a.out

format:
	clang-format -i src/*

.PHONY: clean

clean:
	rm -f $(BLD)/*
