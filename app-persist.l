# persisent version -- uses PicoLisp database

(class +Todo +Entity)
(rel nr (+Need +Key +Number))
(rel title (+String))
(rel completed (+Bool))
(rel order (+Number))

(dm toObj> NIL
   (filter
      prog
      (list
         (cons "title" (: title))
         (if (: order) (cons "order" @))
         (cons "completed" (if (: completed) 'true 'false))
         (cons "url" (pack *BaseURL "/todos/" (: nr))) ) ) )


# guards against NIL entities
(de toObj (Entity)
    (if Entity (toObj> Entity)) )

(de respondJson (Sock Obj)
   (use Data
      (ifn Obj
         (setq Data "[]")
         (setq Data (in (pipe (printJson Obj)) (line T))) )
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
    (db 'nr '(+Todo) (id-from-route Request)) )

(de todos NIL
    (mapcar 'toObj> (collect 'nr '(+Todo))) )

# merges updates into a todo
(de patch-todo (Patch Todo)
    (for X Patch  (put!> Todo (intern (car X)) (cdr X)))
    Todo )


(de route (Sock Request Posted)
   (use Json Todo
      (respondJson Sock 
         (cond
            ((pre? "POST" Request)
               (setq Json (parseJson Posted))
               (setq Todo (new! '(+Todo)
                     'nr (genKey 'nr '+Todo)
                     'title (cdr (assoc "title" Json))
                     'completed (= 'true (cdr (assoc "completed" Json)))
                     'order (cdr (assoc "order" Json))))
               (toObj Todo))
            ((pre? "DELETE" Request)
               (mapc 'lose!> (collect 'nr '(+Todo)))
               (cons T (todos)) )
            ((pre? "GET /todos/" Request)
               (toObj (todo-from-route Request)) )
            ((pre? "PATCH /todos/" Request)
               (setq Json (parseJson Posted))
               (toObj (patch-todo Json (todo-from-route Request))) )
            (T (cons T (todos))) ) ) ) )
 

