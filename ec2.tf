resource "aws_instance" "ec2_instance" {
  count                = var.instance_count
  ami                  = var.ami
  instance_type        = var.instance_type[count.index]
  user_data_base64     = count.index == 0 ? base64encode(local.ec2_userdata_1) : base64encode(local.ec2_userdata_2)
  subnet_id            = aws_subnet.private_subnet.id
  key_name             = var.key_name
  security_groups      = [aws_security_group.allow_iperf.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    delete_on_termination = true
    volume_size           = "10"
    volume_type           = "gp2"
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s${var.num_suffix_format}", var.name, count.index + 1)
    }
  )
  volume_tags = merge(
    var.tags,
    {
      "Name" = format("%s${var.num_suffix_format}", var.name, count.index + 1)
    }
  )
  depends_on = [aws_s3_bucket.iperf_output, aws_nat_gateway.this]
}

