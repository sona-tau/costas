{
	description = "A Nix-flake-based C/C++ development environment";

	inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

	outputs = { self, nixpkgs }:
	let
		supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
		forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
			pkgs = import nixpkgs { inherit system; };
		});

		pkgs-for-data = import nixpkgs { system = "x86_64-linux"; };

		mkDataFile = { name, sha256 }: pkgs-for-data.fetchurl {
			url = "https://github.com/sona-tau/costas/releases/download/v2026.04/${name}";
			inherit sha256;
		};

		costasData = pkgs-for-data.stdenvNoCC.mkDerivation {
			name = "costas-arrays-data";
			dontUnpack = true;
			dontBuild = true;

			srcs = map mkDataFile [
				{ name = "classes_10x10.txt"; sha256 = "sha256-J2so4e4W2LthfhTU91+3o31RIBUZklP9cMyYIWHhqD0="; }
				{ name = "classes_11x11.txt"; sha256 = "sha256-csXqgDhumSn3frdw8YxRffrUNxT7Tq1dDk4CAhc2T+Y="; }
				{ name = "classes_12x12.txt"; sha256 = "sha256-pDzUt0nWqZPzYgU8D5Ph+zGN/AjDTYPUZFpG8PBNBkI="; }
				{ name = "classes_13x13.txt"; sha256 = "sha256-CAfCHcH1wE5uzMateekmrFNe1fl7m6ibiO2XNj3swrk="; }
				{ name = "classes_14x14.txt"; sha256 = "sha256-aKrQ7CLGXEQqo/BiCBlrzpNRhhS5O7oWz+ZL0VZpkiI="; }
				{ name = "classes_15x15.txt"; sha256 = "sha256-lCoEhTtf6/C2fNKsZ3sy2a5nLuaJ7ZuC1RjVCXFB6Wk="; }
				{ name = "classes_16x16.txt"; sha256 = "sha256-CvfZeCKGhUEwlxCJeNqwx/RKdsQqZe9JhyU4SsXmJYY="; }
				{ name = "classes_17x17.txt"; sha256 = "sha256-+mzv+ZkhcfK/EDF2wJfW8+iDVx2cWAidgWT2BSeye0A="; }
				{ name = "classes_18x18.txt"; sha256 = "sha256-POihksxpJrhrOayOc4kcinuY5hTHFDj0d9TDSR/Cwm4="; }
				{ name = "classes_19x19.txt"; sha256 = "sha256-4mynOOhzJeVb1M+jYgpDyFWPpyN1GwDuK9JIaw0aUdQ="; }
				{ name = "classes_1x1.txt"; sha256 = "sha256-a4ayc/80/OGda4BO/1o/V0etpOqiLx1JwB5S3beHW0s="; }
				{ name = "classes_20x20.txt"; sha256 = "sha256-T2aHl3mCWpq9QsQ40DSdKhOy2+1RfDnLn01xPF6k/PQ="; }
				{ name = "classes_2x2.txt"; sha256 = "sha256-9xmY/jY7nCkRbIC17s8zov7co7YVlyQ4RIWAS3FlECk="; }
				{ name = "classes_3x3.txt"; sha256 = "sha256-wsfLUTr+awsySdMrcMsq7/fzVPB7zfR80kzcYmnVP9M="; }
				{ name = "classes_4x4.txt"; sha256 = "sha256-gbMVtouK/eoFC83sT65+IvrIqqiNWtkpb/ixRgbrI2I="; }
				{ name = "classes_5x5.txt"; sha256 = "sha256-i7YVKTRzcqKiGSa8DB3VI6LRy6tnF+vOBVvpogQFKCY="; }
				{ name = "classes_6x6.txt"; sha256 = "sha256-deaRubinysrOROugNwqO/ePmf0xuAv5xVqvsX0uk/CQ="; }
				{ name = "classes_7x7.txt"; sha256 = "sha256-E4DQJ94drVmRRt/hd5UNATJYZNfigsWi3WasJ1RTRIk="; }
				{ name = "classes_8x8.txt"; sha256 = "sha256-XcwYrVroMh1bBCk9aGNBM/zDx8ROuFdSfx63+S6NGCg="; }
				{ name = "classes_9x9.txt"; sha256 = "sha256-nduXyHLEZ8nKts+SkFbUXknPx7bvccoHLhAtURCzGAc="; }
				{ name = "costas_10x10.txt"; sha256 = "sha256-dQliOGfKitE2j1igRhFog7wxU71B3aKOyakT4Pbw8B8="; }
				{ name = "costas_10x11.txt"; sha256 = "sha256-LmRzgIa3CKB1dSwKuI9bp0YZcoTf9kdTAmk+ITgOv48="; }
				{ name = "costas_11x11.txt"; sha256 = "sha256-lwuEMG8bZdY2kHkmPWRR8FgB8NMq9FUjrh2dKDdiLRM="; }
				{ name = "costas_11x12.txt"; sha256 = "sha256-Pvp8FPs/+2Gs9fdYFueuj3PIU2eHo6XGXJh2slwROWc="; }
				{ name = "costas_12x12.txt"; sha256 = "sha256-/QmSFSD7r75cBqTod4HTBiFEUxpoxfYGrJve39EMMg8="; }
				{ name = "costas_12x13.txt"; sha256 = "sha256-RcL0jNFQg5V37nMDwgCe06rAKI8iw+0g9sPbkP2V5Ck="; }
				{ name = "costas_13x13.txt"; sha256 = "sha256-+KXCL3Ab7gftT9bxKv12DuSenJVBhZk0C9LGQd3AQFo="; }
				{ name = "costas_13x14.txt"; sha256 = "sha256-QpfiqnkojSIlegaq97e4sbu5GLv2IvX4LSYzExVxLCs="; }
				{ name = "costas_14x14.txt"; sha256 = "sha256-UnEwcgt2+lmxKsSzrtxo0KFs9MTAl8hIF0aUl71wW4Q="; }
				{ name = "costas_1x1.txt"; sha256 = "sha256-a4ayc/80/OGda4BO/1o/V0etpOqiLx1JwB5S3beHW0s="; }
				{ name = "costas_2x2.txt"; sha256 = "sha256-LKTKp0/ZCLh6Fd/myqbIXmmaqddUaGkNIFiPlitKqcg="; }
				{ name = "costas_2x3.txt"; sha256 = "sha256-1HNeOiZeFu7gP1lxi5tdAwGcB9i2xR+Q2jpmbuwTqzU="; }
				{ name = "costas_3x3.txt"; sha256 = "sha256-tpKbAzslzwiPscgD/ZOS0FMZyboJ0BV41MHr2ROpkJI="; }
				{ name = "costas_3x4.txt"; sha256 = "sha256-At56UfQc2IMMbdGV5FThO0JAoncObtj/jXHhgVKsZS4="; }
				{ name = "costas_4x4.txt"; sha256 = "sha256-XE0j8eheErruBZ+DE/FWMbBnM0Puj8RH1pw94Biw2bw="; }
				{ name = "costas_4x5.txt"; sha256 = "sha256-wbAd42hmt2EVrfzlUU7yhaGOa7iOeszD1hXFnQ/dAW8="; }
				{ name = "costas_5x5.txt"; sha256 = "sha256-Tn9iEiygy0traDKoild44BPb9f/lxZir3GdkaAqGHAI="; }
				{ name = "costas_5x6.txt"; sha256 = "sha256-F5yoXYZN+QTrA0T3iXKPdwWAuX+W8Z7atPYBFGgkHDg="; }
				{ name = "costas_6x6.txt"; sha256 = "sha256-r4IHApQfr2xiGmFoffgbXkFqShY9h1U1qI8yNX2o21A="; }
				{ name = "costas_6x7.txt"; sha256 = "sha256-hrEbklZCwihQnb6yZ757OCirSvncRCaZh0A1DR/asro="; }
				{ name = "costas_7x7.txt"; sha256 = "sha256-ZkI544jhnxdBuxN8h2zQ0tVhQXtRLogfAZgZm4NAKns="; }
				{ name = "costas_7x8.txt"; sha256 = "sha256-wbFSrnPQ+boQ2r7uD2YuYJ2oLjHD9hwxI0mWBvgj03Y="; }
				{ name = "costas_8x8.txt"; sha256 = "sha256-uefrE7ao/wBqT5EMacrzIJOMBEQjXqbXQ2K6dldZNFo="; }
				{ name = "costas_8x9.txt"; sha256 = "sha256-p0fZ34X2KVCU9BdASF3TRzAgYFDzQvCF1jVO7LCPzOg="; }
				{ name = "costas_9x10.txt"; sha256 = "sha256-jnk2gnEq6LJHGwX+t4PjtiyM1rMfmNivHSi0MjdAOeY="; }
				{ name = "costas_9x9.txt"; sha256 = "sha256-o+LlP+m8fFsB9lOvD2+Znm0HJldFRhK7m4ClfIDjxPE="; }
				{ name = "SHA256SUMS"; sha256 = "sha256-7w0ltijVHEg9oJ8N5SbxxupBJnn29xZVejpvrsH/29Y="; }
			];

			installPhase = ''
				mkdir -p $out
				for src in $srcs; do
					name=$(basename $src | cut -d- -f2-)
					cp $src $out/$name
				done
			'';
		};
	in {
		packages = forEachSupportedSystem ({ pkgs }: {
			costas-data = costasData;
		});

		devShells = forEachSupportedSystem ({ pkgs }: {
			default = pkgs.mkShell {
				venvDir = "venv";
				COSTAS_DATA = costasData;

				packages = with pkgs; [
					ccache
					clang
					clang-tools
					cmake
					codespell
					conan
					cppcheck
					dash
					doxygen
					git-lfs
					gtest
					julia-bin
					lcov
					llvmPackages_12.openmp
					vcpkg
					vcpkg-tool
					z3
					ihaskell
					# Python dependencies
					codebraid
					python312
					python312Packages.ipykernel
					python312Packages.jupyter-core
					python312Packages.jupyterlab
					python312Packages.matplotlib
					python312Packages.nbformat
					python312Packages.numpy
					python312Packages.pip
					python312Packages.venvShellHook
					python312Packages.z3-solver
					sage

					# For tests:
					clojure
					gfortran
					gnuapl
					go
					haskell.compiler.ghcHEAD
					deno
					octave
					R
					rustc
				] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);
			};
		});
	};
}
