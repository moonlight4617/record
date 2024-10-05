# USER テーブル
resource "aws_dynamodb_table" "user_table" {
  name           = "USER"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"  # PK

  attribute {
    name = "userId"
    type = "S"
  }

  tags = {
    Name = "user_table"
  }
}

# content テーブル
resource "aws_dynamodb_table" "content_table" {
  name           = "ContentTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "contentId" # PK
  range_key      = "userId"    # FK

  attribute {
    name = "contentId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "year"
    type = "N"
  }

  attribute {
    name = "rank"
    type = "N"
  }

  global_secondary_index {
    name            = "YearIndex"
    hash_key        = "userId"
    range_key       = "year"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "RankIndex"
    hash_key        = "userId"
    range_key       = "rank"
    projection_type = "ALL"
  }

  tags = {
    Name = "content_table"
  }
}

# EXTERNAL_LINKS テーブル
resource "aws_dynamodb_table" "external_links_table" {
  name           = "EXTERNAL_LINKS"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "contentId" # PK
  range_key      = "id" # FK

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "contentId"
    type = "S"
  }

  tags = {
    Name = "external_links_table"
  }
}
