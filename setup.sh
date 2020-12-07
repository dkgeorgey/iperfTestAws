#!/bin/bash

sudo apt install python3-pip -y || sudo yum install python3-pip -y
pip3 install -r requirements.txt
wget https://releases.hashicorp.com/terraform/0.12.10/terraform_0.12.10_linux_amd64.zip
unzip terraform_0.12.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
