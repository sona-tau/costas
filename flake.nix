{
    description = "A Nix-flake-based C/C++ development environment";

    inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

    outputs = { self, nixpkgs }:
        let
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit system; };
            });
    in
    {
        devShells = forEachSupportedSystem ({ pkgs }: {
                default = pkgs.mkShell {
                    venvDir = "venv";
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
                        # Python dependencies
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
                    ] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);
                };
        });
    };
}
