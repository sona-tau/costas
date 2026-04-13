use std::collections::HashSet;
use std::io::{self, BufRead};

// TODO: documentation

fn iscostas(perm: &[i64]) -> bool {
    let n = perm.len();
    let uniq: HashSet<_> = perm.iter().collect();
    if uniq.len() != n {
        return false;
    }
    for k in 1..n {
        let mut seen: u64 = 0;
        for i in 0..n - k {
            let d = (perm[i + k] - perm[i] + n as i64) as u32;
            let bit = 1u64 << d;
            if seen & bit != 0 {
                return false;
            }
            seen |= bit;
        }
    }
    true
}

fn main() {
    let stdin = io::stdin();
    let mut lines = stdin.lock().lines();
    let _n: usize = lines.next().unwrap().unwrap().trim().parse().unwrap();
    let perm: Vec<i64> = lines
        .next()
        .unwrap()
        .unwrap()
        .split_whitespace()
        .map(|x| x.parse().unwrap())
        .collect();
    println!("{}", if iscostas(&perm) { 1 } else { 0 });
}
