# EFS 파일 시스템 생성
resource "aws_efs_file_system" "snet2_2_efs" {
  creation_token = "snet2_2_efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  encrypted = true
  throughput_mode = "elastic"
  tags = {
    Name = "snet2_2_efs"
  }
}
# EFS Mount Target 생성 (서브넷당 하나 필요)
resource "aws_efs_mount_target" "snet2_2_efs_mount" {
  for_each      = toset(aws_subnet.snet2_2_private[*].id)
  file_system_id = aws_efs_file_system.snet2_2_efs.id
  subnet_id      = each.key
  security_groups = [aws_security_group.snet2_2_eks_efs_sg.id]
  depends_on = [aws_subnet.snet2_2_private]
}

# EFS를 위한 Security Group
resource "aws_security_group" "snet2_2_eks_efs_sg" {
  name        = "snet2_2_eks_efs_sg"
  description = "Allow NFS access for EFS"
  vpc_id      = aws_vpc.snet2_2_vpc.id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 서비스 계정 (IAM 역할을 연결)
# resource "kubernetes_service_account" "snet2_2_efs_csi_sa" {
#   metadata {
#     name      = "efs-csi-controller-sa"
#     namespace = "kube-system"
#   }

#   automount_service_account_token = true
# }

# resource "aws_iam_role" "snet2_2_efs_csi_role" {
#   name = "snet2_2_efs_csi_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_policy_attach" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#   role       = aws_iam_role.snet2_2_efs_csi_role.name
# }