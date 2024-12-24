#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "snet2_2_cluster" {
  name = "snet2_2_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_security_group" "snet2_2_sg" {
  name        = "snet2_2_sg"
  description = "all in, all out"
  vpc_id      = aws_vpc.snet2_2_vpc.id

  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp" },
      { from_port = 2049, to_port = 2049, protocol = "tcp" },
      { from_port = 31393, to_port = 31393, protocol = "tcp" },
      { from_port = 8080, to_port = 11000, protocol = "tcp" },
      { from_port = 80, to_port = 80, protocol = "tcp" },
      { from_port = 443, to_port = 443, protocol = "tcp" }
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "snet2_2_sg"
  }
}

resource "aws_eks_cluster" "snet2_2_cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.snet2_2_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.snet2_2_sg.id]
    subnet_ids         = aws_subnet.snet2_2_public[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.snet2_2_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.snet2_2_cluster_AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role_policy_attachment" "snet2_2_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.snet2_2_cluster.name
}

resource "aws_iam_role_policy_attachment" "snet2_2_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.snet2_2_cluster.name
}

