(de http NIL
   (let Request
      (in Sock
         (line)
         (prinl Request)
         (while (prinl (line))) )
      (out Sock
         (prinl "HTTP/1.0 200 OK^M")
         (prinl "access-control-allow-headers: accept, content-type^M")
         (prinl "access-control-allow-methods: GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH^M")
         (prinl "Content-Length: 2^M")
         (prinl "^M")
         (prin "hi") )
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
