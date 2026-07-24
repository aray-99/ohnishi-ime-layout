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

## 環境記録（実機検証セッション）

- Windowsバージョン: Windows 11（build 26200）
- AutoHotkeyバージョン: 2.0.19
- IME: Windows標準 日本語IME（ローマ字入力）
- 物理キーボード: JIS
- Windowsキーボードレイアウト: 日本語（JIS）
- PowerToys Keyboard Manager: CapsLock↔半角/全角、無変換→Ctrl
- 対象コミット: `develop`（#14マージ後、全24キー本体）
- 実施日: 2026-07-23〜24

## IMEモード

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| IME OFF | QWERTY | 確認 | 英数モードと同様にQWERTY |
| ひらがな | 大西配列 | 確認 | Edge・新メモ帳で送出確認（あいうえお等） |
| 全角カタカナ | 大西配列 | 確認 | 物理D→ア |
| 半角カタカナ | 大西配列 | 未実施 | NATIVE有のため全角カタカナと同挙動と推定（ADR-009） |
| 半角英数 | QWERTY | 確認 | 物理D→d |
| 全角英数 | QWERTY | 確認 | 物理D→ｄ |
| 判定不能な入力欄 | QWERTY | 設計 | 検出不能時はQWERTYフォールバック（ADR-009） |

## ショートカット

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| Ctrl+C | QWERTY位置でコピー | 確認 | |
| Ctrl+A | QWERTY位置で全選択 | 確認 | |
| Ctrl++ | JIS通常操作で拡大 | 確認 | 追加Shift不要でズームイン |
| Ctrl+- | JIS通常操作で縮小 | 確認 | 追加Shift不要でズームアウト |
| 無変換+文字（PowerToys=Ctrl） | QWERTY（バイパス） | 確認 | 無変換+D→ブックマーク（全選択にならない）。論理状態判定（ADR-013） |
| Ctrl+V | QWERTY位置で貼付 | 未実施 | 下記バイパス機構は確認済 |
| Ctrl+S | QWERTY位置で保存 | 未実施 | 下記バイパス機構は確認済 |
| Ctrl+F | QWERTY位置で検索 | 未実施 | 下記バイパス機構は確認済 |
| Alt+文字 | QWERTY | 未実施 | 下記バイパス機構は確認済 |
| Win+文字 | QWERTY | 未実施 | 下記バイパス機構は確認済 |
| Ctrl+Shift+文字 | QWERTY | 未実施 | 下記バイパス機構は確認済 |

> 修飾キーのバイパス機構（Ctrl/Alt/Win押下時は `ShouldApply()`=false でQWERTY）は
> Ctrl+C/A、Ctrl++/-、無変換+D で実証済み。上記「未実施」は個別打鍵の未実施を示す。

## 文字入力

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| 大西配列キー（代表・恒等・記号） | 対応表どおり | 確認 | 母音/子音/長音-/読点/恒等QPZXCVを確認 |
| 左Shift | 変換後の大文字/記号 | 確認 | Shift+D→A（IMEのShift→半角英数挙動、設計どおり） |
| 右Shift | 変換後の大文字/記号 | 未実施 | 左Shiftと同一機構（{Blind}） |
| 同一キー連打 | 欠落なし | 確認 | |
| 長押し | 通常のキーリピート | 確認 | |
| 2～3キーの押下重なり | 通常の連続文字 | 確認 | 転がし打ちで欠落・順序逆転なし |
| 高速タイピング | 再現性ある欠落等なし | 確認 | |

### 変換テスト例（ひらがなモードで物理キーを押す）

| 打つ物理キー | 送出ローマ字 | 期待 | 結果 |
|---|---|---|---|
| D S E A F | a i u e o | あいうえお | 確認 |
| H D K D | ka na | かな | 確認 |
| I D G | ra - | らー | 確認 |
| R T | , . | 、。 | 確認 |
| `-`（数字段、@の上） | / | / または ・（IME依存） | 未実施（#23） |
| Q P Z X C V | （恒等） | q p z x c v（IMEでは ｑｐｚｘｃｖ） | 確認 |
| Shift+D | A | 大文字（IMEのShift挙動でA） | 確認 |

> 補足: Shift+文字は最初の一打で大西配列の大文字（例 Shift+D→A）になるが、
> IMEのShift→半角英数挙動で composition を抜けるため、続けて打つと以降は
> QWERTY直接入力になる（例 Shift+D連打→"ADD..."）。単発は設計どおり。

物理→出力の全対応は CLAUDE.md §8 と `src/ohnishi-map.ahk` を参照。

## 運用

| 項目 | 期待結果 | 結果 | 備考 |
|---|---|---|---|
| 多重起動 | 二重変換なし | 設計 | #SingleInstance Force（後発が先発を置換） |
| 有効/無効 | 状態を切替可能 | 確認 | Ctrl+Alt+F12：無効化でD→d、有効化でD→あ |
| 状態表示 | 状態を確認可能 | 確認 | Ctrl+Alt+F10でツールチップ表示 |
| 再読み込み | 安全に再起動 | 確認 | Ctrl+Alt+F11：再読込後も動作 |
| 緊急終了 | 文字キーなしで終了 | 確認 | Ctrl+Alt+Esc |
| 終了後 | 通常QWERTY | 確認 | 終了後 物理D→d |
| 除外アプリ | QWERTY | ロジック確認 | policyで excluded→ShouldApply=false を自動確認（実除外の打鍵は未実施） |
| PowerToys併用 | 二重リマップなし | 確認 | 無変換→Ctrl と併用可。CapsLock/半角全角スワップは非干渉 |

## まとめ

Release 1 の必須項目（ひらがな/カタカナで大西配列、英数でQWERTY、Ctrl/Alt/Win
バイパス、Ctrl++/-、Shift、高速入力、管理ホットキー、終了後QWERTY復帰、
PowerToys併用、新メモ帳等の近代アプリ）を実機で確認した。残る「未実施」は
確認済み機構と同一系統の個別打鍵、および半角カタカナ・右Shiftで、いずれも
既知の等価挙動。ブロッキング不具合なし。
