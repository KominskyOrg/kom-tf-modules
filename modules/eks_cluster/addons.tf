resource "aws_eks_addon" "aws_ebs_csi" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.21.0-eksbuild.1"
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

resource "aws_iam_role" "role" {
  name = "AWS-EBS-CSI-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_number}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}:aud": "sts.amazonaws.com",
          "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  name = "AWS-EBS-CSI-Policy"
  role = aws_iam_role.role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateVolume",
                "ec2:CreateTags",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DeleteVolume",
                "ec2:DeleteSnapshot",
                "ec2:ModifyVolume",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

