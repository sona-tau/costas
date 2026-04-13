
// TODO: documentation

const text = await new Response(Deno.stdin.readable).text();
const lines = text.trim().split("\n");
const n = parseInt(lines[0]);
const perm = lines[1].trim().split(/\s+/).map(Number);

function iscostas(perm) {
    const n = perm.length;
    if (new Set(perm).size !== n) return false;
    for (let k = 1; k < n; k++) {
        const seen = new Set();
        for (let i = 0; i < n - k; i++) {
            const d = perm[i + k] - perm[i];
            if (seen.has(d)) return false;
            seen.add(d);
        }
    }
    return true;
}

console.log(iscostas(perm) ? 1 : 0);
