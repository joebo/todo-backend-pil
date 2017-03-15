(default *Todos NIL)
(setq *BaseURL "http://csilo.com:8088")

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

# extracts the id from the route
# todo matching can also be done with
# (match (list ~(chop "GET /todos/") '@ID " " '@Version) Request)
(de id-from-route (Request)
    (format (last (split (cadr (split Request " ")) "/"))))

(de todo-from-route (Request)
    (car (nth *Todos (id-from-route Request))))

(de route (Sock Request Posted)
   (cond
      ((pre? "POST" Request)
         (setq Json (parseJson Posted))
         (ifn (assoc "completed" Json) (conc Json (cons (cons "completed" 'false))))
         (ifn (assoc "url" Json) (conc Json (cons (cons "url" (pack *BaseURL "/todos/" (+ 1 (length *Todos)))))))
         (setq *Todos (append *Todos (list Json)))
         (respondJson Sock Json) )
      ((pre? "DELETE" Request)
         (setq *Todos NIL)
         (respondJson Sock (cons T *Todos)) )
      ((pre? "GET /todos/" Request)
         (respondJson Sock (todo-from-route Request)) )
      (T (respondJson Sock (cons T *Todos))) ) )
