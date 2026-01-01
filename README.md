## Minecraft-VM
This terraform script creates a minecraft server that runs backups on shutdown and saves them to a bucket. 
To save cost the VM shuts down after a while whene nobody is on the server. 
To further reduce the price it is not assigned an IP adress. 
For restarting the server a cloud function is deployed. 
simply requesting the endpoint starts the VM again. 
