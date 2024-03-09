resource "aws_iam_role" "intents_operator_service_account_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession", "sts:SetSourceIdentity"]
        Effect = "Allow",
        Principal = {
          Service = "rolesanywhere.amazonaws.com",
        },
        Condition = {
          StringLike = {
            "aws:PrincipalTag/x509SAN/URI" = "spiffe://${var.spiffe_trust_domain}/ns/${var.otterize_deploy_namespace}/sa/intents-operator-controller-manager",
          }
          ArnEquals = {
            "aws:SourceArn" = aws_rolesanywhere_trust_anchor.otterize-cert-manager-spiffe-ca.arn
          }
        }
      },
    ],
  })
  path = "/"
  name = substr("${var.cluster_name}-otterize-intents-operator", 0, 64)
  tags = {
    "otterize/system"      = "true"
    "otterize/clusterName" = var.cluster_name
  }
}

resource "aws_iam_role" "credentials_operator_service_account_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession", "sts:SetSourceIdentity"]
        Effect = "Allow",
        Principal = {
          Service = "rolesanywhere.amazonaws.com",
        },
        Condition = {
          StringLike = {
            "aws:PrincipalTag/x509SAN/URI" = "spiffe://${var.spiffe_trust_domain}/ns/${var.otterize_deploy_namespace}/sa/credentials-operator-controller-manager",
          }
          ArnEquals = {
            "aws:SourceArn" = aws_rolesanywhere_trust_anchor.otterize-cert-manager-spiffe-ca.arn
          }
        }
      },
    ],
  })
  path = "/"
  name = substr("${var.cluster_name}-otterize-credentials-operator", 0, 64)
  tags = {
    "otterize/system"      = "true"
    "otterize/clusterName" = var.cluster_name
  }
}

resource "aws_iam_policy" "intents_operator_policy" {
  name = "${var.cluster_name}-intents-operator-access-policy"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:GetPolicy",
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListPolicyVersions"
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:*"
          ]
          Resource = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-otterize-intents-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-otterize-credentials-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster_name}-limit-iam-permission-boundary"
          ]
        },
        {
          Effect = "Deny"
          Action = [
            "iam:CreatePolicyVersion",
            "iam:DeletePolicyVersion",
            "iam:DetachRolePolicy",
            "iam:SetDefaultPolicyVersion"
          ]
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster_name}-limit-iam-permission-boundary"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:DeleteRolePermissionsBoundary"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:AttachRolePolicy",
            "iam:CreatePolicy",
            "iam:CreatePolicyVersion",
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion",
            "iam:TagPolicy",
            "iam:UntagPolicy",
            "iam:DetachRolePolicy",
            "ec2:DescribeInstances",
            "eks:DescribeCluster"
          ]
          Resource = "*"
        }
      ]
  })
}

resource "aws_iam_policy" "credentials_operator_policy" {
  name = "${var.cluster_name}-credentials-operator-access-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:GetPolicy",
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListPolicyVersions"
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:*"
          ]
          Resource = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-otterize-intents-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-otterize-credentials-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster_name}-limit-iam-permission-boundary"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iam:CreateRole"
          ]
          Resource = [
            "*"
          ]
          Condition = {
            StringEquals = {
              "iam:PermissionsBoundary" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.cluster_name}-limit-iam-permission-boundary"
            }
          }
        },
        {
          "Action": [
            "rolesanywhere:CreateProfile",
            "rolesanywhere:DeleteProfile",
            "rolesanywhere:GetProfile",
            "rolesanywhere:ListProfiles"
          ],
          "Resource": "*",
          "Effect": "Allow"
        },
        {
          "Action": [
            "iam:PassRole"
          ],
          "Resource": "*",
          "Effect": "Allow"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion",
            "iam:DeleteRole",
            "iam:DetachRolePolicy",
            "iam:TagRole",
            "iam:TagPolicy",
            "iam:UntagRole",
            "iam:UntagPolicy",
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:DeleteRolePermissionsBoundary"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstances",
            "eks:DescribeCluster"
          ]
          Resource = "*"
        }
      ]
  })
}

resource "awscc_iam_managed_policy" "limit_iam_permission_boundary_policy" {
  managed_policy_name = "${var.cluster_name}-limit-iam-permission-boundary"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
    }
  )
}


resource "aws_iam_role_policy_attachment" "intents_operator_policy" {
  role       = aws_iam_role.intents_operator_service_account_role.name
  policy_arn = aws_iam_policy.intents_operator_policy.arn
}

resource "aws_iam_role_policy_attachment" "credentials_operator_policy" {
  role       = aws_iam_role.credentials_operator_service_account_role.name
  policy_arn = aws_iam_policy.credentials_operator_policy.arn
}