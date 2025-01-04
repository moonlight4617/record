# lambdaのソース格納用のS3バケット作成
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name

  tags = {
    Name = "record-lambda-01"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "lambda_s3_enabled" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_s3_encrypt_default" {
  bucket = aws_s3_bucket.lambda_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_s3_public_access" {
  bucket                  = aws_s3_bucket.lambda_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "testFunctionPython-role-emg7xt7g"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  path = "/service-role/"
}

resource "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole-6d6e94fc-91bf-4818-b01b-61fc9e47a2c6"
  path = "/service-role/"
  # description = "My test policy"

  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:ap-northeast-1:502674413540:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:ap-northeast-1:502674413540:log-group:/aws/lambda/testFunctionPython:*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role-attach-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy" "Lambda-Execute-BasicAction-DynamoDB" {
  name = "Lambda-Execute-BasicAction-DynamoDB"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:GetItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:dynamodb:*:502674413540:table/*"
          Sid      = "VisualEditor0"
        },
        {
          Action = [
            "dynamodb:Scan",
            "dynamodb:Query",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:dynamodb:*:502674413540:table/*/index/*"
          Sid      = "VisualEditor1"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_lambda_function" "lambda_function" {
  # TODO: 名前後ほど変更
  function_name = "testFunctionPython"
  description   = "自作アプリrecordのバックエンド機能"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.main.handler"
  # TODO: 現在のterraformバージョンだとpython3.11を選択できない
  runtime = "python3.9"

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = "lambda/function.zip"

  timeout = 29
  layers = [
    "arn:aws:lambda:ap-northeast-1:502674413540:layer:memoApp-layer-01:11",
  ]
  environment {
    variables = {
      # secret情報などが含まれるのでソースとして記載しない
      # "COGNITO_APP_CLIENT_ID"     = ""
      # "COGNITO_APP_CLIENT_SECRET" = ""
      # "COGNITO_DOMAIN"            = ""
      # "COGNITO_USER_POOL_ID"      = ""
      # "GOOGLE_CLIENT_ID"          = ""
      # "GOOGLE_CLIENT_SECRET"      = ""
      # "REDIRECT_URI"              = ""
    }
  }
}

resource "aws_lambda_permission" "apigw_permission_root" {
  action              = "lambda:InvokeFunction"
  function_name       = "arn:aws:lambda:ap-northeast-1:502674413540:function:${aws_lambda_function.lambda_function.function_name}"
  principal           = "apigateway.amazonaws.com"
  source_arn          = "arn:aws:execute-api:ap-northeast-1:502674413540:c8mfz80519/*/*/"
  statement_id        = "1ccd6ce9-0878-5483-a98c-d0a4334cbb23"
  statement_id_prefix = null
}

resource "aws_lambda_permission" "apigw_permission_all" {
  action              = "lambda:InvokeFunction"
  function_name       = "arn:aws:lambda:ap-northeast-1:502674413540:function:${aws_lambda_function.lambda_function.function_name}"
  principal           = "apigateway.amazonaws.com"
  source_arn          = "arn:aws:execute-api:ap-northeast-1:502674413540:c8mfz80519/*/*/*"
  statement_id        = "5d7a31b7-e398-5fbd-a7ee-4083860fe45f"
  statement_id_prefix = null
}
