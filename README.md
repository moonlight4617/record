## 当ディレクトリについて
自作アプリrecordの環境構築用レポジトリ。
terraformでAWS環境の構築を行う。
※ secret情報はあえてソースには記載してない

### 実際に構築されている環境をterraformに反映する方法
1. `terraform state rm <resource_type>.<resource_name>`  # 既にstateファイルに情報がある場合は削除する
2. `terraform import <resource_type>.<resource_name> <resource_id>`  # 実環境の情報をstateにインポート
3. `terraform state show <resource_type>.<resource_name>`  # インポートされた情報を表示
4. 表示された情報を各tfファイルに反映

### コマンドメモ
- 実体の内容に沿ってstateを更新。実体側が更新されることはない。
`terraform apply -refresh-only`

- 構文エラーチェック
`terraform validate`

- フォーマットコマンド
`terraform fmt --recursive`

- tfstate一覧取得し、指定ファイルに書き出し
terraform state pull > tmp.tfstate
