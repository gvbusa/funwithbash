# Micro-Service
task_svc.sh implements a "task list" micro-service by leveraging the scripts we wrote earlier to 
serve and route http requests, as well as handle database persistence.

We are going to copy the common scripts into this folder, so we can make some minor enhancements to them.

Run the micro service:
ncat --listen --keep-open --source-port 7777 --sh-exec "./task_svc.sh"


