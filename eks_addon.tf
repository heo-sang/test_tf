resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.snet2_2_cluster.name
  addon_name   = "coredns"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.snet2_2_cluster.name
  addon_name   = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.snet2_2_cluster.name
  addon_name   = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name      = aws_eks_cluster.snet2_2_cluster.name
  addon_name        = "eks-pod-identity-agent"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name      = aws_eks_cluster.snet2_2_cluster.name
  addon_name        = "aws-efs-csi-driver"
  resolve_conflicts = "OVERWRITE"
}
