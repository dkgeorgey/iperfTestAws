locals {
  ec2_userdata_1 = <<USERDATA
#!/bin/bash
sudo apt-get update -y
sudo apt-get install jq -y
sudo apt-get install -y iperf3
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
SPOT_REQ_ID=$(aws --region "$REGION" ec2 describe-instances --instance-ids "$INSTANCE_ID"  --query 'Reservations[0].Instances[0].SpotInstanceRequestId' --output text)
if [ "$SPOT_REQ_ID" != "None" ] ; then
    TAGS=$(aws --region "$REGION" ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_REQ_ID" --query 'SpotInstanceRequests[0].Tags')
    VOLUMES=$(aws ec2 describe-instances --region "ap-southeast-2" --instance-ids "$INSTANCE_ID" --query 'Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId' --output text)
    aws --region "$REGION" ec2 create-tags --resources "$INSTANCE_ID" --tags "$TAGS"
    for volume in $VOLUMES; do aws ec2 create-tags --resources "$volume" --tags "$TAGS" --region "$REGION"; done
fi

INSTANCE_1=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running Name=tag:project,Values=iperf-test --output text | awk 'NR==1{print $1}')
INSTANCE_2=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running Name=tag:project,Values=iperf-test --output text | awk 'NR==2{print $1}')

if [ "$INSTANCE_ID" == "$INSTANCE_1" ] ; then
    TARGET_IP=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$INSTANCE_2" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text)
else
    TARGET_IP=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$INSTANCE_1" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text)
fi
iperf3 -c "$TARGET_IP" -p 5201  >> client-to-server.txt
iperf3 -c "$TARGET_IP" -p 5201  -R >> server-to-client.txt
aws s3 cp client-to-server.txt s3://${aws_s3_bucket.iperf_output.id}/client-to-server.txt
aws s3 cp server-to-client.txt s3://${aws_s3_bucket.iperf_output.id}/server-to-client.txt
 USERDATA

  ec2_userdata_2 = <<USERDATA
#!/bin/bash
sudo apt-get update -y
sudo apt-get install jq -y
sudo apt-get install -y iperf3
sudo apt install -y unzip
iperf3 -s -p 5201 -D
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
SPOT_REQ_ID=$(aws --region "$REGION" ec2 describe-instances --instance-ids "$INSTANCE_ID"  --query 'Reservations[0].Instances[0].SpotInstanceRequestId' --output text)
if [ "$SPOT_REQ_ID" != "None" ] ; then
    TAGS=$(aws --region "$REGION" ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_REQ_ID" --query 'SpotInstanceRequests[0].Tags')
    VOLUMES=$(aws ec2 describe-instances --region "ap-southeast-2" --instance-ids "$INSTANCE_ID" --query 'Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId' --output text)
    aws --region "$REGION" ec2 create-tags --resources "$INSTANCE_ID" --tags "$TAGS"
    for volume in $VOLUMES; do aws ec2 create-tags --resources "$volume" --tags "$TAGS" --region "$REGION"; done
fi

USERDATA

}