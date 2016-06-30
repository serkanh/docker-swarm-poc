Make sure to have key-pair created before running the terraform script so you can ssh into the ec2 instances if needed

https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

Initiate docker swarm manager

docker swarm init --listen-addr 10.0.1.227:2377

ssh and run docker swarm join on all swarm nodes

docker swarm join 10.0.1.227:2377

ssh into the docker manager machine and create a service

docker service create --replicas 1 --name helloworld alpine ping docker.com

list of running services:

docker service ls

Run ```docker service tasks helloworld``` to see which nodes are running the service:
docker service tasks helloworld

scale the service

```docker service scale helloworld=5```

list tasks and servers currently running on each node

```docker service tasks helloworld```


remove service from the swarm

```docker service rm helloworld ```


create a nginx service 
docker service create –name frontend –replicas 5 -p 80:80/tcp nginx:latest

docker service tasks frontend