#!/bin/bash

REGION="us-east-1"

echo "=== Створення EC2 інстансу ==="

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-0360c520857e3138f \
  --count 1 \
  --instance-type t3.micro \
  --key-name iht-key-pair \
  --security-group-ids sg-01a6b8a9bb5bd52b9 \
  --user-data file://user-data.sh \
  --region $REGION \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Task3}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Instance ID: $INSTANCE_ID"

echo "=== Очікування запуску інстансу... ==="
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

echo "=== Отримання публічного IP ==="
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Public IP: $PUBLIC_IP"

echo "=== Очікуємо 20 секунд поки user-data виконається ==="
sleep 20

echo "=== Вивід логів sysinfo ==="

ssh -o StrictHostKeyChecking=no \
    -i ./iht-key-pair.pem \
    ec2-user@$PUBLIC_IP \
    "sudo tail -n 30 /var/log/sysinfo"
