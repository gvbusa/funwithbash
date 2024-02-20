# A rudimentary http server
http_server.sh handles GET and POST requests only for now. It relies on the ncat networking utility.
All it does is to parse out the incoming http request, and then send back a response "Have fun with bash!"
We will enhance it in future chapters to do more fun stuff.

This script is inspired by, and makes liberal use of code from https://github.com/chris-rock/vesper
