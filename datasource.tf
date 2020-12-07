data "aws_availability_zones" "available" {
  state = "available"
}


data "template_file" "ec2_userdata" {
  template = <<EOF
    #!/bin/sh
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
  EOF
}
