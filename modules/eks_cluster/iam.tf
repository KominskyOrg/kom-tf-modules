locals {
  ec2_actions = [
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
  ]

  role_principals = {
    "eks.amazonaws.com"  = "eks.amazonaws.com",
    "ec2.amazonaws.com"  = "ec2.amazonaws.com",
    "oidc.amazonaws.com" = "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}"
  }

  role_names = {
    "eks.amazonaws.com"  = "${var.cluster_name}-eks-role",
    "ec2.amazonaws.com"  = "${var.cluster_name}-eks-node-group-role",
    "oidc.amazonaws.com" = "AWS-EBS-CSI-Role"
  }

  role_policies = {
    "eks.amazonaws.com"  = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"],
    "ec2.amazonaws.com"  = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"],
    "oidc.amazonaws.com" = []
  }
  assume_role_statement = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_number}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}:aud" : "sts.amazonaws.com"
            "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_number}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  }
}

resource "aws_iam_role" "role" {
  name               = "AWS-EBS-CSI-Role"
  assume_role_policy = jsonencode(local.assume_role_statement)
}


resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = { for key, policies in local.role_policies : key => policies }

  role       = aws_iam_role.role[each.key].id
  policy_arn = each.value
}

resource "aws_iam_role_policy" "policy" {
  name   = "AWS-EBS-CSI-Policy"
  role   = aws_iam_role.role.id
  policy = jsonencode(local.policy_statement)
}

data "aws_iam_policy_document" "ebs_csi_driver" {
  statement {
    actions   = local.ec2_actions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ebs_csi_driver" {
  name   = "EBS_CSI_Driver"
  policy = data.aws_iam_policy_document.ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.role["ec2.amazonaws.com"].id
  policy_arn = aws_iam_policy.ebs_csi_driver.arn
}
