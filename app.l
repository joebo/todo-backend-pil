(default *Todos NIL)

(de respondJson (Sock Json)
   (use Data
      (ifn Json
         (setq Data "[]")
         (setq Data (in (pipe (printJson Json)) (line T))) )
      (out Sock
         (prinl "HTTP/1.0 200 OK^M")
         (prinl "access-control-allow-origin: *^M")
         (prinl "access-control-allow-headers: accept, content-type^M")
         (prinl "access-control-allow-methods: GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH^M")
         (prinl "Content-Length: " (+ 1 (length Data)) "^M")
         (prinl "^M")
         (prinl Data) ) ) )

(de route (Sock Request Posted)
   (cond
      ((pre? "POST" Request)
         (setq Json (parseJson Posted))
         (setq *Todos (append *Todos (list Json)))
         (respondJson Sock Json) )
      ((pre? "DELETE" Request)
         (setq *Todos NIL)
         (respondJson Sock (cons T *Todos)) )
      (T (respondJson Sock (cons T *Todos))) ) )
