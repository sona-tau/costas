;; TODO: documentation

(defn iscostas [perm]
  (let [n (count perm)
        v (vec perm)]
    (and (= (count (set perm)) n)
         (every? (fn [k]
                   (let [diffs (map (fn [i] (- (v (+ i k)) (v i)))
                                    (range (- n k)))]
                     (= (count (set diffs)) (count diffs))))
                 (range 1 n)))))



(let [_n   (Integer/parseInt (clojure.string/trim (read-line)))
      perm (map #(Integer/parseInt %)
                (clojure.string/split (clojure.string/trim (read-line)) #"\s+"))]
  (println (if (iscostas perm) 1 0)))
