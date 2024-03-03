(local fennel (require :fennel))

(fn dirname [s]
  (let [split (string.find (string.reverse s) "/")]
    (if split
      (string.sub s 1 (- 0 split))
      "")))

(fn extend-tbl [tbl data]
  (each [ky vl (pairs tbl)]
        (when (not (?. data ky))
          (tset data ky vl)))
  data)

(fn usage []
  "Usage:\n  fnlate FILENAME\n")

(fn proc-str [st env ctx]
  (local
    public-env
    {:load (fn [filename]
            (let [envdir (. env :dirname)]
              (with-open [file (io.open (.. envdir filename))]
                (proc-str (file:read "*all")
                          (extend-tbl env {:dirname (.. envdir (dirname filename))})
                          ctx))))

    :def (fn [name val]
           (tset ctx name val)
           "")

    :.def (fn [name]
            (. ctx name))

    :log (fn [...]
           (each [i x (ipairs [...])]
                 (io.stderr:write x " "))
           (io.stderr:write "\n"))
    : env
    })
  (var sout "")
  (var spos 1)
  (var slen (string.len st))
  (var within-prepro-tags? false)
  (while (< spos slen)
    (if within-prepro-tags?
      (let [tagidx (string.find st "%s%?>" spos)]
        (if tagidx
          (let [script (string.sub st spos (- tagidx 1))
                seval (fennel.eval script {:env public-env})]
            (if seval
              (set sout (.. sout seval))
              (io.stderr:write "Error: failed to evaluate pre-processor expressions" script "\n"))
            (set spos (+ 1 (string.find st ">" tagidx)))
            (set within-prepro-tags? false))
          (do
            (io.stderr:write "Warning: preprocessor tag not closed before end of file.\n")
            (set sout
                 (.. sout (string.sub st spos slen)))
            (set spos slen))))
      (let [tagidx (string.find st "<%?%s" spos)]
        (if tagidx
          (let [schunk (string.sub st spos (- tagidx 1))]
            (set sout
                 (.. sout schunk))
            (set within-prepro-tags? true)
            (set spos (+ 2 tagidx)))
          (do
            (set sout (.. sout (string.sub st spos slen)))
            (set spos slen))
          ))))
  sout)

(let [filename (. arg 1)]
  (if (not filename)
    (do
      (io.stderr:write "No input file provided\n")
      (io.stderr:write (usage)))
    (with-open [fin (io.open filename)]
      (print (proc-str (fin:read "*all")
                       {:dirname (dirname filename)}
                       {})))))
