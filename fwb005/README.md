# Task List Web App
We will now build a small task-list web app that uses the micro-service we built in chapter fwb004.
In support of the web app, we will make the following enhancements to our backend:

- Enhance the http_server and router to serve static files such as html, css, and javascript
- Speed up database operations by running mongosh in the background and redirecting IO via named pipes
- Add error handling for database operations
- Add validations for the incoming payload
- Use a start_server.sh script to run both mongosh (backgound) and ncat (foreground)

The web app will of course need html, javascript and css code. Since our focus is bash and not
these technologies, the web app will be a minimalist (but functional) single page app
and avoid using any large and complex frameworks like React or Flutter.

It will make use of just 2 dependencies:
- axios.min.js
- bootstrap.min.css

