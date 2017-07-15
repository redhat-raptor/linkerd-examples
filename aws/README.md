# AWS

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
