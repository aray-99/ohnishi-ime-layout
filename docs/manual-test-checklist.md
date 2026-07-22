# 手動テストチェックリスト

実施していない項目を完了扱いにしない。

対象スクリプト: `OhnishiLayout.ahk`（Issue #2 で大西配列Coreを実装）。
起動: `AutoHotkey64.exe OhnishiLayout.ahk`。Issue #2 時点の終了はタスクトレイ
アイコンの Exit。有効/無効・状態表示・再読込・緊急終了・除外の運用操作は
Issue #3 で追加する。

## 環境記録

- Windowsバージョン:
- AutoHotkeyバージョン:
- IME:
- 物理キーボード:
- Windowsキーボードレイアウト:
- PowerToys Keyboard Manager:
- 対象コミット:

## IMEモード

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| IME OFF | QWERTY | 未実施 | |
| ひらがな | 大西配列 | 検出のみ確認 | 自動観測でIsJapaneseComposition()=true（送出は未実施） |
| 全角カタカナ | 大西配列 | 未実施 | NATIVE有のため適用（ADR-009） |
| 半角カタカナ | 大西配列 | 未実施 | NATIVE有のため適用（ADR-009） |
| 半角英数 | QWERTY | 未実施 | |
| 全角英数 | QWERTY | 未実施 | |
| 判定不能な入力欄 | QWERTY | 未実施 | |

## ショートカット

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| Ctrl+C | QWERTY位置でコピー | 未実施 | |
| Ctrl+V | QWERTY位置で貼付 | 未実施 | |
| Ctrl+S | QWERTY位置で保存 | 未実施 | |
| Ctrl+F | QWERTY位置で検索 | 未実施 | |
| Ctrl++ | JIS通常操作で拡大 | 未実施 | 追加Shift不要 |
| Ctrl+- | JIS通常操作で縮小 | 未実施 | |
| Alt+文字 | QWERTY | 未実施 | |
| Win+文字 | QWERTY | 未実施 | |
| Ctrl+Shift+文字 | QWERTY | 未実施 | |

## 文字入力

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| 全大西配列キー | 対応表どおり | 未実施 | |
| 左Shift | 変換後の大文字/記号 | 未実施 | |
| 右Shift | 変換後の大文字/記号 | 未実施 | |
| 同一キー連打 | 欠落なし | 未実施 | |
| 長押し | 通常のキーリピート | 未実施 | |
| 2～3キーの押下重なり | 通常の連続文字 | 未実施 | |
| 高速タイピング | 再現性ある欠落等なし | 未実施 | |

## 運用

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| 多重起動 | 二重変換なし | 未実施 | #SingleInstance Force |
| 有効/無効 | 状態を切替可能 | ロジック確認 | policyで disabled→ShouldApply=false を自動確認（実キーは未実施） |
| 状態表示 | 状態を確認可能 | 未実施 | Ctrl+Alt+F10 / トレイ |
| 再読み込み | 安全に再起動 | 未実施 | Ctrl+Alt+F11 |
| 緊急終了 | 文字キーなしで終了 | 未実施 | Ctrl+Alt+Esc |
| 除外アプリ | QWERTY | ロジック確認 | policyで excluded→ShouldApply=false を自動確認（実キーは未実施） |
| 終了後 | 通常QWERTY | 未実施 | |
| PowerToys併用 | 二重リマップなし | 未実施 | 詳細は docs/operations.md |
