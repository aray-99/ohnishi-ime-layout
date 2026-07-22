# 手動テストチェックリスト

実施していない項目を完了扱いにしない。

対象スクリプト: `OhnishiLayout.ahk`。起動は `AutoHotkey64.exe OhnishiLayout.ahk`。
操作・除外・復旧の詳細は `docs/operations.md`、送出/IME判定の観測手順は
`docs/spike-ime.md` を参照。

## 自動事前チェック（実施済み）

実機・IME操作を要さない範囲で自動確認済み。詳細は各PRとdocs/spike-ime.md。

| 項目 | 方法 | 結果 |
|---|---|---|
| 全スクリプトの構文 | `scripts/check-syntax.ps1`（AHK /ErrorStdOut, --selfcheck） | PASS |
| IME検出プラミング | 読取専用プローブ | ひらがなで open=1 mode=0x09 [NATIVE FULLSHAPE] |
| composition判定 | `Ime.IsJapaneseComposition()` | ひらがなで true |
| 有効/無効ゲート | `Layout.ShouldApply()` | disabled→false |
| 除外ゲート | `Layout.IsExcludedApp()`/`ShouldApply()` | excluded→false |

参考検証環境: Windows 11 (build 26200), AutoHotkey 2.0.19。

> 以下の実機項目（キー送出・Ctrl/Shift/リピート・各IMEモード・運用UX）は
> 実機での手動確認が必要。未実施を完了扱いにしないこと。

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

### 変換テスト例（ひらがなモードで物理キーを押す）

大西配列では物理キーの押下位置が下記の出力に対応する。ひらがなモードで次の
物理キー列を打ち、期待するかな/記号が出るか確認する。

| 打つ物理キー | 送出ローマ字 | 期待 | 結果 |
|---|---|---|---|
| D S E A F | a i u e o | あいうえお | 未実施 |
| H D K D | ka na | かな | 未実施 |
| I D G | ra - | らー | 未実施 |
| R T | , . | 、。 | 未実施 |
| Shift+D | A | 大文字/対応（IME依存） | 未実施 |

物理→出力の全対応は CLAUDE.md §8 と `src/ohnishi-map.ahk` を参照。
Q P Z X C V は恒等（そのまま q p z x c v）。

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
