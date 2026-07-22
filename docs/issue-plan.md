# GitHub Issue計画

`scripts/create-issues.ps1`は以下のIssueを作成する。
番号はGitHubが採番するため、この文書では論理IDを使用する。

## SPIKE-IME: IME状態・キー送信方式の技術検証

### 目的

本実装前に、Windows標準日本語IMEのモード判定と、AutoHotkey v2からIMEへ
安定して文字キーを送る方式を確定する。

### 完了条件

- IME OFF、ひらがな、カタカナ、半角英数、全角英数の観測結果を記録
- 大西配列を適用すべき状態の判定方針を確定
- 1～3キーの試験変換を実装
- Ctrl押下中にQWERTYとなることを確認
- Shift、キーリピート、重なったキー押下を確認
- 採用方式と不採用方式を`docs/decisions.md`へ追記
- 実機未確認項目を明記

## CORE-JIS: JIS向け大西配列Core

### 完了条件

- 完全な大西配列マッピング
- 日本語ローマ字入力モードでのみ有効
- IME英数入力でQWERTY
- Ctrl/Alt/WinでQWERTY
- Shift入力
- 多重起動防止
- 生成キーの再変換防止
- `#Requires AutoHotkey v2.0`

## OPS: 常駐運用と安全操作

### 完了条件

- 起動時有効
- 有効/無効
- 状態表示
- 再読み込み
- 緊急終了
- アプリ除外
- 自動起動と復旧手順
- 終了後に通常入力へ戻る

## TEST-R1: Release 1手動検証

### 完了条件

- 手動テスト表を実施可能な形に更新
- JIS実機のIMEモード
- `Ctrl + +` / `Ctrl + -`
- 高速入力、キーリピート、Shift
- 管理ホットキー
- 未確認事項を明記
- 既知の問題をIssue化

## DOCS-R1: 公開用ドキュメントとRelease 1準備

### 完了条件

- インストール、設定、停止、復旧
- PowerToysとの責務分担
- 対応環境と既知の制約
- ライセンス確認
- 個人情報やローカルパスがない
- Release 1タグ候補を提示

## US-SPIKE: US物理キーボード記号調査

Release 1後に実施する。

### 完了条件

- 優先記号のVK/SC、JIS論理環境での出力を記録
- バックスラッシュの実現候補
- LaTeX主要記号の試験
- Win+Spaceを減らせるか評価
- Release 2の実装Issueへ分割
