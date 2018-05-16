# Deploy Collectors to ECS nodes

Deploy collectors (aka shippers, beaters) to ECS nodes.

# Prerequsite
Set up ELK stack: https://github.com/hldnova/elastic-docker

Make sure ECS nodes can be accessed via ssh, and the nodes themselves can access port 5044 on the ELK host.

# Setup
1. Install [Docker](http://docker.io)
2. Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html)
3. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. Clone this repository: git clone https://github.com/hldnova/ecs-collector

# Deploy Syslog Collector to ECS nodes
Deploy syslog configurations to ECS nodes to collect ECS access logs via syslog.

## Configure Inventory
```bash
$ cd ecs-collector
```

Edit work/inventory to specify ECS nodes, vdc.
```bash
[nodes:children]
vdc1
vdc2

[nodes:vars]
ssh_user=admin

[syslog:children]
vdc1
vdc2

[vdc1]
10.1.1.1
10.1.1.2
10.1.1.3
10.1.1.4

[vdc2]
10.1.1.11
10.1.1.12
10.1.1.13
10.1.1.14
```

## Configure Logstash Output

Edit group_vars/all to configure logstash hosts, assuming 10.3.1.1 is the ELK host where logstash is running.
```bash
output:
  logstash_syslog:
    host: 10.3.1.1

    # set to 5015 for legacy access log; 5014 for 3.1+
    port: 5014
    #port: 5015

    # set to true for legacy access log
    access_legacy: false
    #access_legacy: true

    # set to ecs_access_legacy for legacy access log
    state_file: ecs_access
    #state_file: ecs_access_legacy
```

## Deploy Syslog Configuration to ECS nodes

Run the commands below to deploy syslog configurations to ECS nodes. You will be prompted to enter password for the ECS admin user.
```bash
$ ansible-playbook ssh-keys.yml --ask-pass
$ ansible-playbook syslog-main.yml
```

Log on to an ECS node to verify that syslog configuration has been deployed. 
```bash
$ ls /etc/rsyslog.d
30-ecs-accesslog.conf
```

Shortly after, you should see data in Elasticsearch. To verify run the following command.
```bash
$ curl -XGET http://<your_elk_host>:9200/filebeat-*/_search?pretty
```

To remove the syslog configuration from ECS nodes
```bash
$ ansible-playbook remove.yml --tags=syslog
```
