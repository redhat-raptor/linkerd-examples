#!/bin/bash
echo ECS_CLUSTER=default >> /etc/ecs/ecs.config

usermod -a -G docker ec2-user

# Retrieve IP of this instance from the AWS API

ECS_INSTANCE_IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Generate linkerd config file

read -d '' LINKERD_CONFIG <<EOF
admin:
  ip: 0.0.0.0
  port: 9990

namers:
- kind: io.l5d.consul
  host: localhost
  port: 8500

telemetry:
- kind: io.l5d.prometheus
- kind: io.l5d.recentRequests
  sampleRate: 0.25

usage:
  orgId: linkerd-examples-ecs

routers:
- protocol: http
  label: outgoing
  servers:
  - ip: 0.0.0.0
    port: 4140
  identifier:
    kind: io.l5d.path
    segments: 1
    consume: true
  interpreter:
    kind: default
    transformers:
    # tranform all outgoing requests to deliver to incoming linkerd port 4141
    - kind: io.l5d.port
      port: 4141
  dtab: |
    /svc => /#/io.l5d.consul/dc1;
- protocol: http
  label: incoming
  servers:
  - ip: 0.0.0.0
    port: 4141
  interpreter:
    kind: default
    transformers:
    # filter instances to only include those on this host
    - kind: io.l5d.specificHost
      host: ${ECS_INSTANCE_IP_ADDRESS}
  dtab: |
    /svc => /#/io.l5d.consul/dc1;
EOF

echo "$LINKERD_CONFIG" |
  docker run -i -a stdin --restart=always \
  --memory=256m \
  --cpu-shares=60 \
  -p 4140:4140 -p 4141:4141 -p 9990:9990 \
  buoyantio/linkerd:1.1.2 -- - &
