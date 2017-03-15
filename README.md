http://www.todobackend.com/ implementation for PicoLisp

Both versions are passing all tests

# Versions
1. server-nofork - is the non-persistent version. It requires a single process since it's not using the PicoLisp database

        pil server.l -'server-nofork 8088' +

1. server-fork - is the version that persists to the database. It can fork and support concurrent connections

        pil server.l -'server-fork 8088' +

Tested using:
http://www.todobackend.com/specs/index.html?http://csilo.com:8088