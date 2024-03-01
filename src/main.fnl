(local fennel (require :fennel))
(with-open [fout (io.open :out.html :w)
            fin (io.open :in.html)]
  (var sin (fin:read "*all"))
  (var sout "")
  (var spos 1)
  (var sinlen (string.len sin))
  (var within-prepro-tag false)

  (while (< spos sinlen)
    (if within-prepro-tag
      (let [tagidx (string.find sin "%s%?>" spos)]
        (if tagidx
          (let [script (string.sub sin spos (- tagidx 1))
                seval (fennel.eval script)]
            (if seval
              (set sout (.. sout seval))
              (print "Error: failed to evaluate pre-processor expressions" script))
            (set spos (+ 1 (string.find sin ">" tagidx)))
            (set within-prepro-tag false))
          (do
            (print "Warning: preprocessor tag not closed before end of file.")
            (set sout
                 (.. sout (string.sub sin spos sinlen)))
            (set spos sinlen))))
      (let [tagidx (string.find sin "<%?%s" spos)]
        (if tagidx
          (let [schunk (string.sub sin spos (- tagidx 1))]
            (set sout
                 (.. sout schunk))
            (set within-prepro-tag true)
            (set spos (+ 2 tagidx)))
          (do
            (set sout (.. sout (string.sub sin spos sinlen)))
            (set spos sinlen))
          ))))
  
  (print sout)
  )
