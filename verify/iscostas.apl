⍝ TODO: implement reading from stdin

Costas ← {
	v ← ⍵
	n ← ≢v
	diffs ← {2-/⍣⍵⊢v}¨⍳n-1
	uniq ← ⊢=⍥≢∪
	(∧/uniq¨diffs) ∧ uniq v
}
