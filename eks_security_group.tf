resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = aws_vpc.external_api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.aws_stack_name}-eks-cluster-sg",
    StackName = var.aws_stack_name
  }
}

resource "aws_security_group" "eks_node_sg" {
  vpc_id = aws_vpc.external_api_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["ip-address/32"]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.aws_stack_name}-eks-node-sg",
    StackName = var.aws_stack_name
  }
}
