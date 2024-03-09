output "otterize-credentials-operator-role-arn" {
  value = aws_iam_role.credentials_operator_service_account_role.arn
}

output "otterize-intents-operator-role-arn" {
  value = aws_iam_role.intents_operator_service_account_role.arn
}

output "otterize-credentials-operator-trust-profile-arn" {
  value = aws_rolesanywhere_profile.credentials-operator
}

output "otterize-intents-operator-trust-profile-arn" {
  value = aws_rolesanywhere_profile.intents-operator
}

output "trust-anchor-arn" {
  value = aws_rolesanywhere_trust_anchor.otterize-cert-manager-spiffe-ca.arn
}
