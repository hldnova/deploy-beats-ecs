# Deploy beats to ECS nodes

Deploy filebeat, metricbeat to ECS nodes, and optionally deploy ecsbeat to a node either in the ECS cluster or somewhere else.

# Setup
1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/)
3. Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html)
4. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
5. Clone this repository


# Start ELK Stack
Start the ELK stack with *docker-compose*. 

cd to ecs-dashboard/docker-elk and edit docker-compose.yml to disable filebeat, metricbeat, ecsbeat
Edit the ecsbeat section if you want to run ecsbeat on the same host as ELK stack. 
Edit ecsbeat/config/ecsbeat.yml to configure metricsets, ECS hosts/username/password, logstash output.
```bash
# docker-compose up -d
```

# Deploy filebeat and metricbeat to ECS nodes
Deploy filebeat and metricbeat containers on ECS nodes. The filebeat is configured to collect dataheadsvc.log. The metricbeat collects system and docker metric sets.

Make sure ECS nodes can be accessed via ssh, and the nodes themselves can access port 5044 on the ELK stack host.


cd to ecs-dashboard/deploy/playbooks
create directory work
copy inventory.example to work/inventory
edit work/inventory to specify ECS nodes
edit group_vars/all to configure logstash hosts
```bash
# ansible-playbook ssh-key.yml --ask-pass
# ansible-playbook upload-image.yml
# ansible-playbook main.yml
```
log on to an ECS node to verify filebeat and metricbeat containers are running. 
```bash
# sudo docker logs filebeat
# sudo docker logs metricbeat
```

To verify your data are present in Elasticsearch, issue the following commands:
```bash
# curl -XGET http://<your_elasticsearch_host>:9200/filebeat-*/_search?pretty
# curl -XGET http://<your_elasticsearch_host>:9200/metricbeat-*/_search?pretty
```
