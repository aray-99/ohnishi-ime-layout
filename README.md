# Ohnishi IME Layout for Windows

日本語IMEのローマ字入力時**だけ**大西配列を適用する、AutoHotkey v2製の
Windows常駐スクリプトです。英数入力とショートカットはQWERTYのまま維持します。

## 設計の中心

- 日本語IMEのかな・カナ系ローマ字入力時：大西配列
- 日本語IMEの英数入力時（半角/全角）：QWERTY
- Ctrl / Alt / Win を伴う操作：IME状態に関わらずQWERTY（`Ctrl + +` / `Ctrl + -` を含む）
- Shiftのみ：大西配列を維持（変換後の大文字/対応記号）
- 文字キーの同時押し・時間判定・tap/hold・キーアップ待ち：**実装しない**
- IME状態を判定できないとき：QWERTYへフォールバック
- CapsLockと半角/全角の交換：公開Coreに含めず、当面PowerToys側に残す
- 初期リリース：JIS Core／第2段階：US物理キーボード互換レイヤー

## 動作環境

- Windows 10 / 11
- [AutoHotkey v2.0 stable](https://www.autohotkey.com/)（v1は不可）
- Windows標準の日本語IME（ローマ字入力）
- Release 1 の主対象は内蔵JISキーボード

## インストール

1. AutoHotkey v2.0 stable をインストールする。
2. 本リポジトリをクローンまたはZIPで取得する。
3. `OhnishiLayout.ahk` をダブルクリックするか、次で起動する。

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "<repo>\OhnishiLayout.ahk"
```

起動すると有効状態で常駐します。ログイン時の自動起動は
[`docs/operations.md`](docs/operations.md) を参照してください。

## クイックスタート

1. スクリプトを起動する。
2. メモ帳などでIMEをひらがなにする。
3. 物理キー `D S E A F` を打つと「あいうえお」になります（大西配列）。
4. IMEを半角英数に戻すと、通常のQWERTYになります。

## 操作

| 操作 | ホットキー | タスクトレイ |
|---|---|---|
| 有効/無効 | Ctrl+Alt+F12 | Enabled |
| 状態表示 | Ctrl+Alt+F10 | Status |
| 再読み込み | Ctrl+Alt+F11 | Reload |
| 緊急終了 | Ctrl+Alt+Esc | Exit |

## アプリケーション除外

特定アプリを常にQWERTYにするには、`personal.example.ahk` を
`personal.local.ahk`（gitignore対象）へコピーして編集します。

```autohotkey
Layout.Exclude("mstsc.exe")
```

詳細は [`docs/operations.md`](docs/operations.md)。

## 大西配列

```text
物理位置: Q W E R T Y U I O P
出力文字: Q L U , . F W R Y P

物理位置: A S D F G H J K L ;
出力文字: E I A O - K T N S H

物理位置: Z X C V B N M , . /
出力文字: Z X C V ; G D M J B
```

## 既知の制約

- 対象はWindows標準日本語IMEの**ローマ字入力**。かな入力モードは想定外で、
  誤って大西配列が適用され得る（要件 §6 で対象外）。
- Release 1 の主対象はJIS。US物理キーボードの記号補正はRelease 2（US-SPIKE）。
- IME状態は前面ウィンドウへの `SendMessage` で毎入力判定するため、環境により
  ごく僅かな遅延の可能性がある（実機での体感確認を推奨）。
- 全IME・全アプリの完全動作は保証しない。
- 実機・日本語IMEでの手動検証は所有者環境で実施する
  （[チェックリスト](docs/manual-test-checklist.md)）。

## ドキュメント

- [要件](docs/requirements.md)
- [基本設計](docs/basic-design.md)
- [設計判断](docs/decisions.md)
- [運用・復旧](docs/operations.md)
- [IME技術検証](docs/spike-ime.md)
- [手動テスト](docs/manual-test-checklist.md)
- [コントリビュート/分岐運用](CONTRIBUTING.md)
- [Claude Code作業規約](CLAUDE.md)

## 状態

- [x] 要件・基本設計 / Issue計画
- [x] IME技術検証（実機確認済み）
- [x] JIS Core 実装
- [x] 常駐運用・復旧
- [x] Release 1 実機手動検証（完了、issue #4）
- [x] **Release 1（v1.0.0）タグ付け**
- [ ] US互換レイヤー（Release 2, US-SPIKE）

## License

[MIT](LICENSE)（著作権表記は公開前に確認してください）。
