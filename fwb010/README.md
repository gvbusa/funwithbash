# Authentication
We will now add a simple email/password registration and login mechanism for our
task-list app. Only authenticated users will be able to access the app. Authenticated
users will be able to manage and access only their own tasks. Users will be able to 
reset and change their password.

The signup and password reset functionality will require the ability to send emails. To
accomplish this, we will use the free tier in SendGrid.

To be able to send emails using SendGrid, we will need a real domain name that we own,
so that the sender's email address can be verified. We will create the "funwithbash.com" domain
using Ionos, where we can get one for $1 for the first year.

We will now be able to use a valid SSL certificate for our domain instead of the self-signed
certificates we have been using till date. At this point, when we deploy to AWS, and add a DNS "A"
record in Ionos, we will have a proper publicly available app that anyone can signup with a valid email
address, and use to manage their task list.


