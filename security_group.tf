resource "aws_security_group" "allow_iperf" {
  name        = "allow_iperf"
  description = "Allow traffic from other ec2"
  vpc_id      = aws_default_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 9600
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block, "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}