resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.aws_stack_name}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private_subnets.*.id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.ec2_instance_template.id
    version = "$Latest"
  }

  tags = {
    Name      = "${var.aws_stack_name}-eks-node-group",
    StackName = var.aws_stack_name
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_launch_template" "ec2_instance_template" {
  name_prefix   = "${var.aws_stack_name}-eks-node-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = "my-aws-key"  # Replace with your SSH key name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_node_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.aws_stack_name}-eks-node"
      StackName = var.aws_stack_name
    }
  }
}