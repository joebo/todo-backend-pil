http://www.todobackend.com/ implementation for PicoLisp

# Versions
1. server-nofork - (DONE) is the non-persistent version. It requires a single process since it's not using the PicoLisp database
1. server-fork - (IN PROGRESS) is the version that persists to the database. It can fork and support concurrent connections

# Starting
        pil server.l -'server-nofork 8088' +