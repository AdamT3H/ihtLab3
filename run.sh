#!/bin/bash

echo "=== Створення EC2 інстансу ==="

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-01bc990364452ab3e \
  --count 1 \
  --instance-type t3.micro \
  --key-name adam-key \
  --security-group-ids sg-01a6b8a9bb5bd52b9 \
  --user-data file://user-data.sh \
  --region "us-east-1" \
  --iam-instance-profile Name="default" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Task3}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Instance ID: $INSTANCE_ID"

echo "=== Очікування запуску інстансу... ==="
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region "us-east-1"

echo "=== Отримання публічного IP ==="
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Public IP: $PUBLIC_IP"

echo "=== Очікуємо 20 секунд поки user-data виконається ==="
sleep 20

echo "=== Вивід логів sysinfo ==="

ssh -i ./adam-key.pem ec2-user@$PUBLIC_IP
