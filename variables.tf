variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "AWS_SESSION_TOKEN" {
  type    = string
  default = null
}

variable "AWS_REGION" {
  type = string
}

variable "principals" {
  type = list(object({
    type        = string
    identifiers = list(string)
  }))
}

variable "role_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "policy_statements" {
  type = list(object({
    sid       = string
    actions   = list(string)
    resources = list(string)
  }))

  default = [
    {
      sid = "CloudWatchLogsPermissions"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
      ],
      resources = ["*"]
    }
  ]
}
