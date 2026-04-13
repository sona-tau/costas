#!/usr/bin/env bash

set -euo pipefail

# This checks whether a certain command exists and exits when it does not.
check_command() {
	CMD="$1"
	if ! command -v "$CMD" > /dev/null 2>&1; then
		echo "$CMD could not be found"
		exit 1
	fi
	echo "- $CMD found"
}

echo "Checking dependencies:"
check_command gum

if [ $# -ne 1 ]; then
	gum log -l "error" "Usage: $0 <source-file>"
	echo "Example: $0 iscostas.py"
	exit 1
fi

# The first CLI argument is always the source file
SOURCE="$1"
EXT="${SOURCE##*.}"

# BUILD_DIR is the directory where compilation artifacts get put.
# the command "trap" executes a piece of bash when the currntly running script
# receives a signal. In this case EXIT
# The prefix check guards against rm -rf'ing your important files.
BUILD_DIR=$(mktemp -d)
trap '[ -n "${BUILD_DIR:-}" ] && [[ "$BUILD_DIR" == /tmp/* ]] && rm -rf "$BUILD_DIR"' EXIT

# Interpreted languages run directly & compiled languages are built once here.
case "$EXT" in
	jl)
		check_command julia
		COMMAND="julia $SOURCE"
		;;
	py|sage)
		check_command python3
		COMMAND="python3 $SOURCE"
		;;
	js)
		check_command deno
		COMMAND="deno run $SOURCE"
		;;
	R)
		check_command Rscript
		COMMAND="Rscript $SOURCE"
		;;
	m)
		check_command octave
		COMMAND="octave $SOURCE"
		;;
	clj)
		check_command clojure
		COMMAND="clojure $SOURCE"
		;;
	c)
		check_command clang
		gum log -l info -t ansic "Compiling $SOURCE"
		clang "$SOURCE" -o "$BUILD_DIR/iscostas"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	cc)
		check_command clang++
		gum log -l info -t ansic "Compiling $SOURCE"
		clang++ "$SOURCE" -o "$BUILD_DIR/iscostas"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	rs)
		check_command rustc
		gum log -l info -t ansic "Compiling $SOURCE"
		rustc "$SOURCE" -o "$BUILD_DIR/iscostas"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	go)
		check_command go
		gum log -l info -t ansic "Compiling $SOURCE"
		go build -o "$BUILD_DIR/iscostas" "$SOURCE"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	hs)
		check_command ghc
		gum log -l info -t ansic "Compiling $SOURCE"
		# ghc also emits .hi and .o files; direct them into BUILD_DIR too
		ghc "$SOURCE" -outputdir "$BUILD_DIR" -o "$BUILD_DIR/iscostas"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	f90)
		check_command gfortran
		gum log -l info -t ansic "Compiling $SOURCE"
		gfortran "$SOURCE" -o "$BUILD_DIR/iscostas"
		COMMAND="$BUILD_DIR/iscostas"
		;;
	*)
		gum log -l error -t ansic "Unrecognised extension: .$EXT"
		exit 1
		;;
esac
gum log -l info -t ansic "$(gum style --faint "All dependencies found")"

PASS=0
FAIL=0
TOTAL_TESTS=27 # positive tests
TOTAL_TESTS=$((TOTAL_TESTS + 11)) # negative tests

BAR_WIDTH=30

# Redraws the progress bar in-place on the current line (no trailing newline)
_BLOCKS='▏▎▍▌▋▊▉█'
draw_progress() {
	local done=$((PASS + FAIL))
	local total=$TOTAL_TESTS
	local width=$BAR_WIDTH

	# compute how muwh fill is needed
	local eighths=$(( done * width * 8 / total ))
	local filled=$(( eighths / 8 ))
	local partial=$(( eighths % 8 ))

	local bar=""
	local i=0

	# solid filled cells
	while [ $i -lt $filled ]; do
		bar="${bar}█"
		i=$((i + 1))
	done

	# Partial cells
	local remaining=$width
	if [ $partial -gt 0 ] && [ $filled -lt $width ]; then
		local edge
		edge="${_BLOCKS:$(( partial - 1)):1}"
		bar="${bar}${edge}"
		remaining=$(( width - filled - 1 ))
	else
		remaining=$(( width - filled ))
	fi

	# Fill epmty cells
	local j=0
	while [ $j -lt $remaining ]; do
		bar="${bar}·"
		j=$(( j + 1 ))
	done

	# Percent
	local pct=$(( done * 100 / total ))

	# Color the bar
	local bar_color='\033[38;5;240m'
	if   [ $done -eq 0 ]; then
		bar_color='\033[38;5;240m'
	elif [ "$FAIL" -gt 0 ]; then
		bar_color='\033[38;5;167m' # muted red
	elif [ $done -eq $total ]; then
		bar_color='\033[38;5;71m' # muted green
	else
		bar_color='\033[38;5;110m' # muted blue
	fi

	printf '\r\033[K'
	# Bar
	printf "  ${bar_color}${bar}\033[0m"
	# Percentage (right-aligned)
	printf '  \033[2m%3d%%\033[0m' "$pct"
	# Fraction
	printf '  \033[2m%d/%d\033[0m' "$done" "$total"
	# pass count
	printf '  \033[38;5;71m✓ %d\033[0m' "$PASS"
	# fail count
	if [ "$FAIL" -gt 0 ]; then
		printf '  \033[38;5;167m✗ %d\033[0m' "$FAIL"
		
	fi
}

# This runs a test. The input is of the form:
# positive integer
# a permutation with length equal to that positive integer
run_test() {
	local input="$1"
	local expected="$2"
	local label="$3"

	# This runs the test and captures the output
	actual=$(echo "$input" | $COMMAND 2>/dev/null)

	if [ "$actual" = "$expected" ]; then
		PASS=$((PASS + 1))
	else
		# Clear the progress line, print the failure, then redraw below it
		printf '\r\033[K'
		printf '  \033[31mFAIL\033[0m  %s\n' "$label"
		printf '    input:    %s\n' "$(echo "$input" | tr '\n' '|')"
		printf '    expected: %s  got: %s\n' "$expected" "$actual"
		FAIL=$((FAIL + 1))
	fi
	draw_progress
}

# ---- Positive tests ----
# first and last array from each data file

# Check if the env variable COSTAS_DATA exists
if [ -z "${COSTAS_DATA:-}" ]; then
	gum log -l warn -t ansic "COSTAS_DATA is not set: skipping data file tests"
else
	for n in $(seq 20); do
		f="${COSTAS_DATA}/costas_${n}x${n}.txt"
		# Check if the file f in COSTAS_DATA exists and is non-empty
		[ -s "$f" ] || continue

		first=$(head -1 "$f")
		last=$(tail -1 "$f")

		# This is the length of the permutation
		n=$(echo "$first" | wc -w)

		run_test "$n"$'\n'"$first" 1 "$(basename "$f") first: $first"
		if [ "$first" != "$last" ]; then
			run_test "$n"$'\n'"$last" 1 "$(basename "$f") last: $last"
		fi
	done
fi

# ---- Negative tests ----
# known non-Costas arrays

# Arithmetic progressions: every consecutive difference is +1, so k=1 always fails
run_test "3"$'\n'"1 2 3" 0 "order 3: 1 2 3 (arithmetic progression)"
run_test "4"$'\n'"1 2 3 4" 0 "order 4: 1 2 3 4 (arithmetic progression)"
run_test "5"$'\n'"1 2 3 4 5" 0 "order 5: 1 2 3 4 5 (arithmetic progression)"

# Reverse sequences: every consecutive difference is -1, so k=1 always fails
run_test "3"$'\n'"3 2 1" 0 "order 3: 3 2 1 (reverse)"
run_test "4"$'\n'"4 3 2 1" 0 "order 4: 4 3 2 1 (reverse)"
run_test "5"$'\n'"5 4 3 2 1" 0 "order 5: 5 4 3 2 1 (reverse)"

# Repeated difference at k=1: perm[i+1]-perm[i] collides for two different i
run_test "4"$'\n'"2 1 4 3" 0 "order 4: 2 1 4 3 (k=1 diffs: -1 3 -1)"
run_test "4"$'\n'"1 3 2 4" 0 "order 4: 1 3 2 4 (k=1 diffs: 2 -1 2)"
run_test "5"$'\n'"1 2 4 3 5" 0 "order 5: 1 2 4 3 5 (k=1 diffs: 1 2 -1 2)"

# Non-permutation: duplicate values mean the difference table is immediately invalid
run_test "4"$'\n'"1 1 2 3" 0 "order 4: 1 1 2 3 (duplicate value)"
run_test "4"$'\n'"2 2 2 2" 0 "order 4: 2 2 2 2 (all same)"

printf '\n'

# Summary
TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
	gum log -l info -t ansic "$(gum style --bold "All $TOTAL tests passed")"
	exit 0
else
	gum log -l error -t ansic "$(gum style --bold "$FAIL/$TOTAL tests failed")"
	exit 1
fi
