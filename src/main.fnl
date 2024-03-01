(local fennel (require :fennel))

(local sin (io.stdin:read "*all"))
(var sout "")
(var spos 1)
(var sinlen (string.len sin))
(var within-prepro-tags? false)

(while (< spos sinlen)
  (if within-prepro-tags?
    (let [tagidx (string.find sin "%s%?>" spos)]
      (if tagidx
        (let [script (string.sub sin spos (- tagidx 1))
              seval (fennel.eval script)]
          (if seval
            (set sout (.. sout seval))
            (io.stderr:write "Error: failed to evaluate pre-processor expressions" script))
          (set spos (+ 1 (string.find sin ">" tagidx)))
          (set within-prepro-tags? false))
        (do
          (io.stderr:write "Warning: preprocessor tag not closed before end of file.")
          (set sout
               (.. sout (string.sub sin spos sinlen)))
          (set spos sinlen))))
    (let [tagidx (string.find sin "<%?%s" spos)]
      (if tagidx
        (let [schunk (string.sub sin spos (- tagidx 1))]
          (set sout
               (.. sout schunk))
          (set within-prepro-tags? true)
          (set spos (+ 2 tagidx)))
        (do
          (set sout (.. sout (string.sub sin spos sinlen)))
          (set spos sinlen))
        ))))

(print sout)
