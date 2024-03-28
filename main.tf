data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    dynamic "principals" {
      for_each = { for principal in var.principals : principal.type => principal }
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }

    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.is_external ? [var.condition] : []

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

data "aws_iam_policy_document" "policy_document" {
  dynamic "statement" {
    for_each = { for statement in var.policy_statements : statement.sid => statement }

    content {
      effect    = "Allow"
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.has_condition ? [statement.value.condition] : []

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "policy" {
  count = length(var.policy_statements) > 0 && var.policy_name != "" ? 1 : 0

  name   = var.policy_name
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  for_each = { for attachment in var.policy_attachments : attachment.arn => attachment }

  policy_arn = each.value.arn
  role       = aws_iam_role.role.name
}
