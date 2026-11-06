using Primes
using GaloisFields

# Find the index of elem in vec; returns length(vec) if not found.
function findindex(vec::Vector{T}, elem::T)::Integer where T
	res = findfirst(==(elem), vec)
	res !== nothing ? res : length(vec)
end

# Vector minus its last element.
function init(lst::Vector{T})::Vector{T} where T
	lst[1:end-1]
end

"""
	primitiveroots(prime) -> Vector{Integer}

Return all primitive roots of the cyclic group (Z/prime Z)*.
"""
function primitiveroots(prime::Integer)::Vector{Integer}
	filter(a -> isprimitiveroot(prime, a), 2:prime) |> collect
end

"""
	isprimitiveroot(prime, alpha) -> Bool

Return `true` if `alpha` is a primitive root modulo `prime`.
"""
function isprimitiveroot(prime::Integer, alpha::Integer)::Bool
	not_one = all(powermod(alpha, i, prime) != prime - 1 for i in 1:((prime - 1) ÷ 2 - 1))
	last_one = powermod(alpha, (prime - 1) ÷ 2, prime) == prime - 1
	not_one && last_one
end

"""
	welch(prime) -> Vector{Vector{Integer}}

Return all Welch construction Costas arrays of order `prime - 1`.
For each primitive root alpha of `prime`, the array is
[alpha^1 mod prime, alpha^2 mod prime, ..., alpha^(prime-1) mod prime].
"""
function welch(prime::Integer)::Vector{Vector{Integer}}
	primitiveroots(prime) .|> root -> [powermod(root, k, prime) for k in 1:prime-1]
end

"""
	lempel(prime) -> Vector{Vector{Integer}}

Return all Lempel construction Costas arrays of order `prime - 2`.
For each Welch sequence w, the Lempel sequence is the permutation
L[j] = position of (prime + 1 - w[j]) in w, for j = 1,...,prime-2.
This is the Lempel-Golomb construction restricted to GF(prime) with beta = alpha.
"""
function lempel(prime::Integer)::Vector{Vector{Integer}}
	welch(prime) .|> lst -> init(lst) .|> n -> findindex(lst, prime + 1 - n)
end

# --- Lempel-Golomb construction ---
#
# The Lempel-Golomb (LG) construction generalises Welch and Lempel to any
# prime power q = p^m.  Given two primitive roots alpha and beta of GF(q),
# the array of order q - 2 is defined by
#
#   c[j] = log_beta(1 - alpha^j)  for j = 1, ..., q - 2
#
# where log_beta is the discrete logarithm base beta in GF(q)*.
#
# For q = p (prime, m = 1) we use modular integer arithmetic.
# For q = p^m (m >= 2) we use GaloisFields.jl for field arithmetic.
#
# The values c[j] land in {1, ..., q-2}: since alpha is a primitive root,
# {alpha^j : j = 1..q-2} = GF(q)* \ {1}, so {1 - alpha^j} = GF(q)* \ {1},
# and log_beta maps GF(q)* \ {1} onto {1, ..., q-2} (the exponent q-1 = beta^0
# corresponds to 1, which is excluded).

# Return (p, m) if n = p^m for prime p and integer m >= 1, else nothing.
function _prime_power(n::Int)::Union{Tuple{Int,Int}, Nothing}
	n < 2 && return nothing
	f = factor(n)
	length(f) == 1 || return nothing
	p, m = first(f)
	(Int(p), m)
end

# Compute the LG array for prime field GF(p) with integer primitive roots alpha, beta.
# Returns c[j] = log_beta(1 - alpha^j mod p) for j = 1,...,p-2.
function _lempelgolomb_prime(p::Int, alpha::Int, beta::Int)::Vector{Int}
	# Discrete log table: beta_log[x] = k means beta^k ≡ x mod p
	beta_log = zeros(Int, p)
	bpow = 1
	for k in 1:p-1
		bpow = (bpow * beta) % p
		beta_log[bpow] = k
	end
	[beta_log[mod(1 - powermod(alpha, j, p), p)] for j in 1:p-2]
end

# Compute all distinct LG arrays for GF(p^m) using GaloisFields.jl (m >= 2).
# GaloisField(p, m) returns (Type, generator) for extension fields.
function _lempelgolomb_gf(p::Int, m::Int)::Vector{Vector{Int}}
	F, g = GaloisField(p, m)
	q = p^m
	ord = q - 1   # order of GF(q)*

	# pow_tab[k] = g^k for k = 1..ord (so pow_tab[ord] = g^ord = one(F))
	pow_tab = Vector{F}(undef, ord)
	pw = one(F)
	for k in 1:ord
		pw = pw * g
		pow_tab[k] = pw
	end

	# Discrete log table: dlog[x] = k means g^k = x, for k in 1..ord
	dlog = Dict{F, Int}()
	for k in 1:ord
		dlog[pow_tab[k]] = k
	end

	# Primitive root exponents: k in 1..ord with gcd(k, ord) == 1
	prim_exps = filter(k -> gcd(k, ord) == 1, 1:ord)

	# For each pair of primitive roots alpha = g^a, beta = g^b,
	# compute c[j] = log_beta(1 - alpha^j) = log_g(1 - alpha^j) / b (mod ord)
	result = Vector{Vector{Int}}()
	for a in prim_exps, b in prim_exps
		b_inv = invmod(b, ord)
		seq = Vector{Int}(undef, q - 2)
		valid = true
		for j in 1:q-2
			x = one(F) - pow_tab[mod(a * j, ord)]   # 1 - alpha^j; exponent a*j is in 1..ord-1
			lx = get(dlog, x, 0)                     # log_g(x); 0 means x not found (= zero(F))
			lx == 0 && (valid = false; break)
			seq[j] = mod(lx * b_inv, ord)            # log_beta(x) in 1..ord-1 = 1..q-2
		end
		valid && push!(result, seq)
	end
	unique(result)
end

const _LG_CACHE = Dict{Int, Vector{Vector{Int}}}()

"""
	lempelgolomb(q) -> Vector{Vector{Int}}

Return all Lempel-Golomb construction Costas arrays of order `q - 2`,
where `q` must be a prime power.  For each pair of primitive roots
(alpha, beta) of GF(q), the array is defined by

    c[j] = log_beta(1 - alpha^j)  for j = 1, ..., q - 2

Returns an empty vector if `q` is not a prime power.
The Lempel construction corresponds to the subset of results where beta = alpha.
Results are cached per `q`.
"""
function lempelgolomb(q::Integer)::Vector{Vector{Int}}
	q_int = Int(q)
	haskey(_LG_CACHE, q_int) && return _LG_CACHE[q_int]
	pp = _prime_power(q_int)
	result = if pp === nothing
		Vector{Vector{Int}}()
	else
		p, m = pp
		if m == 1
			roots = collect(Int, primitiveroots(p))
			unique([_lempelgolomb_prime(p, a, b) for a in roots for b in roots])
		else
			_lempelgolomb_gf(p, m)
		end
	end
	_LG_CACHE[q_int] = result
	result
end
