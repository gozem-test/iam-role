data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = var.assume_role_service_type
      identifiers = var.assume_role_service_identifiers
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy_document" {
  dynamic "statement" {
    for_each = { for statement in var.policy_statements : statement.sid => statement }

    content {
      effect    = "Allow"
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "policy" {
  name   = var.policy_name
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.policy_document.json
}
