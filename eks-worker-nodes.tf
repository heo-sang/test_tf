resource "aws_iam_role" "snet2_2_node" {
  name = "snet2_2_node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "snet2_2_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.snet2_2_node.name
}

resource "aws_iam_role_policy_attachment" "snet2_2_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.snet2_2_node.name
}

resource "aws_iam_role_policy_attachment" "snet2_2_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.snet2_2_node.name
}

resource "aws_iam_role_policy_attachment" "snet2_2_node_AWSCertificateManagerFullAccess"{
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
  role       = aws_iam_role.snet2_2_node.name
}

resource "aws_eks_node_group" "snet2_2_node_group" {
  cluster_name    = aws_eks_cluster.snet2_2_cluster.name
  node_group_name = "snet2_2_worker_nodes"
  node_role_arn   = aws_iam_role.snet2_2_node.arn
  subnet_ids      = aws_subnet.snet2_2_public[*].id
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.snet2_2_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.snet2_2_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.snet2_2_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.snet2_2_node_AWSCertificateManagerFullAccess
  ]
}

