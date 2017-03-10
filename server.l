(load "@lib/json.l")

(de respondJson (Sock Json)
   (use Data
	(if Json (setq Data (in (pipe (printJson Json)) (line T))))
	(out Sock
	     (prinl "HTTP/1.0 200 OK^M")
	     (prinl "access-control-allow-origin: *^M")
	     (prinl "access-control-allow-headers: accept, content-type^M")
	     (prinl "access-control-allow-methods: GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH^M")
	     (prinl "Content-Length: " (+ 1 (length Data)) "^M")
	     (prinl "^M")
	     (prinl Data) )) )
(de http NIL
   (use (Request HeaderLine Header ContLen Posted Json)
      (in Sock
         (setq Request (line T))
         (prinl Request)
         (while (setq HeaderLine (line))
            (setq HeaderParts (split HeaderLine " "))
            (setq Header (lowc (pack (car HeaderParts))))
            (if (= Header "content-length:")
               (setq ContLen (format (cdr HeaderParts))) ) )
         (when (pre? "POST" Request)
            (setq Posted (pack (ht:Read ContLen))) ) )
      (cond
         ((pre? "POST" Request)
            (setq Json (parseJson Posted))
            (respondJson Sock Json) )
         (T (respondJson Sock NIL)) )
      (close Sock)
      (bye) ) )

(de server (P)
   (setq Port (port P))
   (loop
      (setq Sock (listen Port))
      (NIL (fork) (close Port))
      (close Sock) )
   (http) )

(server 8088)
