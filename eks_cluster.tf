resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = concat(aws_subnet.public_subnets.*.id, aws_subnet.private_subnets.*.id)
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name      = "${var.aws_stack_name}-eks-cluster",
    StackName = var.aws_stack_name
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_policy]
}
