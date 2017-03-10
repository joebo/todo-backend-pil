(load "@lib/json.l")

(de http (Sock Forked)
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
      (load "app.l")
      (route Sock Request Posted)
      (close Sock)
      (if Forked (bye)) ) )

(de server-fork (P)
   (setq Port (port P))
   (loop
      (setq Sock (listen Port))
      (NIL (fork) (close Port))
      (close Sock) )
   (http Sock T) )

(de server-nofork (P)
   (setq Port (port P))
   (loop
      (setq Sock (listen Port))
      (http Sock)
      (close Sock) ) )

# (server-fork 8088)
