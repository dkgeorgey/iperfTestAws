An EC2 instance is a virtual server that replaces on-site, physical hardware. There are several benefits to migrating to EC2 instance, elasticity, control, reliability and cost effectiveness being some of the advantages. Not all EC2 instances are same and hence choosing the right EC2 instance type is critical in producing the right performance factor for the purpose a user is spinning up the EC2 instance.

Various factors affecting EC2 instance throughputs are but not limited to the physical proximity of the EC2 instances, maximum transmission unit (MTU), the size of your EC2 instance and advanced AMI configurations by viz., Placement groups, AZ and region affinity. A typical performance table for the some of the older generation general purpose  EC2 instances are as follows;

INSTANCE TYPE	    Baseline (Gbit/s)	  Burst (Gbit/s)
m5.large		      0.74			          10.04
m5.xlarge		      1.24			          10.04
m5.2xlarge		    2.49			          10.04
m5.4xlarge		    4.97			          10.04
m5.12xlarge		    10.04
m5.24xlarge		    21.49
t3.nano		        0.03			          5.06
t3.micro		      0.06			          5.09
t3.small		      0.13			          5.11
t3.medium		      0.25			          4.98
t3.large		      0.51			          5.11
t3.xlarge		      1.02			          5.11
t3.2xlarge		    2.04			          5.11


Network latency of many factors, has a direct implication on the network performance of the EC2 instances. Latency really matters for cross-region connectivity, Instance to Instance clustering and other similar scenarios. TCP tuning, finding the right MTUs, selecting the appropriate AWS region, setting AZ affinity, making use of Placement groups, rightly configuring Load balancers  are some of considerations to mitigate the network latency.



# TCP Throughput Check - Iperf

This project contains the required files to create a temporary infrastructure on AWS to perform a TCP throughput test using iperf3

## What does the module do?
This module does the following:
- Utilises the default vpc every region and creates a new private subnet within that default vpc
- Creates 2 ec2 instances whose userdata installs the required packages like iperf3
- One of the ec2 instances is configured as a client and the other as a server
- The iperf results are uploaded to s3
- The python script downloads those results
- As soon as the files are downloaded, the temporary infra that is spun up gets deleted by Terraform


## Tools used
Terraform(0.12.10), Iperf3, Python, Boto3, pip3

# Using this module

## macOS
If you are running the code on a macOS, initiate the program by running
`python3 terraform_init.py`

## Linux
If you are running the code on a Linux box, then:
- run ./setup.sh
- run python3 terraform_init.py


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| instance\_type\_1 | Instance type of first instance | `string` | t3.micro | yes |
| instance\_type\_2 | Instance type of second instance | `string` | t3.xlarge | yes |
| ami | ID of AMI to use for the instance | `string` | ami-07fbdcfe29326c4fb | no |
| key\_name | keypair to be used for the ec2 instances | `string` | n/a | yes, if we want to login into ec2 |
