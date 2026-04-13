# TODO: documentation
con <- file("stdin", open = "r")
n <- as.integer(readLines(con, n = 1))
perm <- as.integer(strsplit(trimws(readLines(con, n = 1)), "\\s+")[[1]])
close(con)

iscostas <- function(perm) {
    n <- length(perm)
    if (length(unique(perm)) != n) return(FALSE)
    for (k in seq_len(n - 1)) {
        diffs <- perm[(k + 1):n] - perm[1:(n - k)]
        if (length(unique(diffs)) != length(diffs)) return(FALSE)
    }
    TRUE
}

cat(if (iscostas(perm)) 1 else 0, "\n", sep = "")
