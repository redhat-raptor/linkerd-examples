# AWS

## ECS + linkerd + consul

This guide assumes you have already configured AWS with the proper IAM, roles, key pairs, VPCs, and Security Groups for an ECS cluster. For more information start here:
http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html

Create ECS Cluster

```bash
aws ecs create-cluster
```

Create Launch Configuration

```bash
# set this to a key pair you will use to access your instances, or omit the parameter
KEY_PAIR=<MY KEY PAIR NAME>

aws autoscaling create-launch-configuration --launch-configuration-name linkerd-lc --image-id ami-7d664a1d --instance-type m4.xlarge --user-data file://linkerd-startup.sh --iam-instance-profile ecsInstanceRole --key-name $KEY_PAIR
```

Create Auto Scaling Group

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name linkerd-asg --launch-configuration-name linkerd-lc --min-size 1 --max-size 3 --desired-capacity 2 --availability-zones us-west-1a
```








Maybe try for first run:
https://us-west-1.console.aws.amazon.com/ecs/home?region=us-west-1#/firstRun

```bash

aws autoscaling create-launch-configuration
aws autoscaling create-launch-configuration --launch-configuration-name linkerd-lc --key-name my-key-pair --image-id ami-c6169af6 --instance-type m1.small --user-data file://myuserdata.txt


## ECS

http://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html

http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html

`ecsInstanceRole`

Set `$ECS_HOST` to your ECS instance

```bash
export ECS_HOST=ec2-11-111-111-111.us-west-1.compute.amazonaws.com
```

Copy config files to ECS host, to be mounted into running linkerd Docker container

```bash
scp -rp config ec2-user@$ECS_HOST:/home/ec2-user/linkerd-config
```

Register our linkerd task

```bash
aws ecs register-task-definition --cli-input-json file://linkerd-task-definition.json
```

Launch task

```bash
```

Test routing a request. This assumes your EC2 instance inbound rules allows port 4140.

```bash
curl -s -o /dev/null -w "%{http_code}" $ECS_HOST:4140
502

curl -s -o /dev/null -w "%{http_code}" -H "Host: default" $ECS_HOST:4140
200
```

## CloudFormation

`UserData`
