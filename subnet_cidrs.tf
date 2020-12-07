module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = aws_default_vpc.this.cidr_block
  networks = [
    {
      name     = "pub-subnet-a"
      new_bits = 4
    },
    {
      name     = "pub-subnet-b"
      new_bits = 4
    },
    {
      name     = "pub-subnet-c"
      new_bits = 4
    },
    {
      name     = "pvt-subnet-a"
      new_bits = 4
    },
    {
      name     = "pvt-subnet-b"
      new_bits = 4
    },
    {
      name     = "pvt-subnet-c"
      new_bits = 4
    }
  ]
}