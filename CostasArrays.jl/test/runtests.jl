using CostasArrays
using Test

@testset "CostasArrays" begin

	@testset "iscostas" begin
		@test iscostas([1, 2, 3]) == false   # constant differences
		@test iscostas([3, 2, 1]) == false   # constant differences
		@test iscostas([2, 1]) == true
		@test iscostas([1, 3, 2]) == true    # all order-3 perms except [1,2,3] and [3,2,1]
		@test iscostas([1, 3, 4, 2]) == true # known order-4 Costas array
		@test iscostas([1, 2, 4, 3]) == true # known order-4 Costas array
	end

	@testset "welch" begin
		# Welch(p) gives arrays of order p-1
		ws5 = welch(5)
		@test length(ws5) == 2 # 2 primitive roots mod 5
		@test all(length(w) == 4 for w in ws5)
		@test all(iscostas(w) for w in ws5)

		ws7 = welch(7)
		@test length(ws7) == 2 # 2 primitive roots mod 7
		@test all(iscostas(w) for w in ws7)
	end

	@testset "lempel" begin
		# Lempel(p) gives arrays of order p-2
		ls5 = lempel(5)
		@test length(ls5) == 2
		@test all(length(l) == 3 for l in ls5)
		@test all(iscostas(l) for l in ls5)

		ls7 = lempel(7)
		@test length(ls7) == 2
		@test all(length(l) == 5 for l in ls7)
		@test all(iscostas(l) for l in ls7)
	end

	@testset "lempelgolomb" begin
		# lempelgolomb(8): GF(2^3), arrays of order 6
		lg8 = lempelgolomb(8)
		@test length(lg8) > 0
		@test all(length(a) == 6 for a in lg8)
		@test all(iscostas(a) for a in lg8)

		# lempelgolomb(9): GF(3^2), arrays of order 7
		lg9 = lempelgolomb(9)
		@test length(lg9) > 0
		@test all(length(a) == 7 for a in lg9)
		@test all(iscostas(a) for a in lg9)

		# non-prime-power returns empty
		@test lempelgolomb(6) == []
	end

	@testset "classify - Welch" begin
		for p in [5, 7, 11]
			for w in welch(p)
				@test classify(w) == Welch
			end
		end
	end

	@testset "classify - WelchShift" begin
		w = first(welch(7))   # order-6 Welch array
		s = collect(Int, circshift(w, 1))
		@test s != collect(Int, w)
		@test classify(s) == WelchShift
	end

	@testset "classify - Lempel" begin
		for p in [5, 7, 11]
			for l in lempel(p)
				@test classify(l) == Lempel
			end
		end
	end

	@testset "classify - LempelGolomb (GF(8))" begin
		welch_kinds = (Welch, WelchShift, WelchOrbit, WelchShiftOrbit)
		for a in lempelgolomb(8)
			c = classify(a)
			@test c in welch_kinds || c == LempelGolomb
		end
	end

	@testset "classify - LempelGolomb (GF(9))" begin
		for a in lempelgolomb(9)
			c = classify(a)
			@test c == LempelGolomb || c == LempelGolombOrbit
		end
	end

	@testset "classify - order counts" begin
		# Order 6: Welch(7) family + LG(GF(8)) + sporadic
		arrays6 = opencostas(joinpath(DATADIR, "costas_6x6.txt"))
		counts6 = Dict(k => 0 for k in instances(CostasKind))
		for a in arrays6
			counts6[classify(a)] += 1
		end
		@test counts6[Welch] == 2    # 2 primitive roots mod 7
		@test counts6[Lempel] == 0   # 6 + 2 = 8 not prime
		@test counts6[Sporadic] > 0

		# Order 7: LG(GF(9)) only among constructions
		arrays7 = opencostas(joinpath(DATADIR, "costas_7x7.txt"))
		counts7 = Dict(k => 0 for k in instances(CostasKind))
		for a in arrays7
			counts7[classify(a)] += 1
		end
		@test counts7[Welch] == 0        # 7 + 1 = 8 not prime
		@test counts7[Lempel] == 0       # 7 + 2 = 9 not prime
		@test counts7[LempelGolomb] == 8
	end

	@testset "symmetry - d4orbit" begin
		perm = first(welch(5))
		orbit = d4orbit(perm)
		@test length(orbit) == 8
		@test all(iscostas(o) for o in orbit)
	end

end
