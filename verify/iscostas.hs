import Data.List (nub)

-- TODO: documentation

iscostas :: [Int] -> Bool
iscostas perm =
    length (nub perm) == n &&
    all checkShift [1 .. n - 1]
  where
    n = length perm
    checkShift k =
        let diffs = zipWith (-) (drop k perm) perm
        in length (nub diffs) == length diffs

main :: IO ()
main = do
    _ <- getLine
    line2 <- getLine
    let perm = map read (words line2) :: [Int]
    putStrLn $ if iscostas perm then "1" else "0"
