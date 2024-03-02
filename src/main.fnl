(local fennel (require :fennel))

(fn proc-str [st ctx]
  (local context (or ctx {}))
  (local
    preproc-env
    {:env
     {:load
      (fn [filename]
        (with-open [file (io.open filename)]
          (proc-str (file:read "*all") context)))
      :def
      (fn [name val]
        (tset context name val)
        ""
        )
      :.def
      (fn [name]
        (. context name))
      : context
      }})

  (var sout "")
  (var spos 1)
  (var slen (string.len st))
  (var within-prepro-tags? false)
  (while (< spos slen)
    (if within-prepro-tags?
      (let [tagidx (string.find st "%s%?>" spos)]
        (if tagidx
          (let [script (string.sub st spos (- tagidx 1))
                seval (fennel.eval script preproc-env)]
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

(print (proc-str (io.stdin:read "*all")))
