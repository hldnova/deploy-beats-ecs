# Deploy beats to ECS nodes

Deploy filebeat, metricbeat to ECS nodes, and optionally deploy ecsbeat to a node either in the ECS cluster or somewhere else.

# Setup
1. Install [Docker](http://docker.io)
2. Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html)
3. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. Clone this repository


# Start ELK Stack

If you don't have Elastic Stack (aka ELK) running, following steps here to stand up the stack in Docker containers.

Install [Elastic Stack](https://github.com/hldnova/elastic-docker)

# Deploy filebeat and metricbeat to ECS nodes
Deploy filebeat and metricbeat containers on ECS nodes. The filebeat is configured to collect dataheadsvc.log. The metricbeat collects system and docker metric sets.

Make sure ECS nodes can be accessed via ssh, and the nodes themselves can access port 5044 on the ELK stack.

Optionally, Edit ansible.cfg.

Edit work/inventory to specify ECS nodes
```bash
# filebeat and metricbeat are deployed on nodes
[nodes]
10.1.1.1
10.1.1.2
10.1.1.3
10.1.1.4

# ecsbeat is deployed on one node
[nodes-ecsbeat]
10.1.1.1
```

Edit group_vars/all to configure logstash hosts and ECS credentials
```bash
output:
  logstash:
    hosts: localhost:5044
    # for multiple logstash hosts, use
    # hosts: 1.1.1.1:5044,2.2.2.2:5044

ECS:
  ssh_user: <ssh user to ecs nodes>
  hosts: https://<ecs_host>:4443
  username: <ecs management username>
  password: <ecs management user password>
```

Execute the following commands to download docker images and deploy containers on ECS nodes

```bash
# ansible-playbook ssh-key.yml --ask-pass
# sudo ansible-playbook upload-image.yml
# ansible-playbook main.yml
```

Log on to an ECS node to verify filebeat and metricbeat containers are running. 
```bash
# sudo docker logs filebeat
# sudo docker logs metricbeat
```

To verify your data are present in Elasticsearch, issue the following commands:
```bash
# curl -XGET http://<your_elasticsearch_host>:9200/filebeat-*/_search?pretty
# curl -XGET http://<your_elasticsearch_host>:9200/metricbeat-*/_search?pretty
```

You can also run the individual playbook to, e.g., restart ecsbeat
```bash
# ansible-playbook ecsbeat-main.yml
```

To remove all the deployed beats
```bash
# ansible-playbook remove.yml
```

To remove just, e.g., ecsbeat
```bash
# ansible-playbook --tags=ecsbeat remove.yml
```

You will need to re-run the upload_image.yml playbook if you want to get latest docker images
