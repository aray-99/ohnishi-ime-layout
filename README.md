# Ohnishi IME Layout for Windows

![Release](https://img.shields.io/github/v/release/aray-99/ohnishi-ime-layout)
![License: MIT](https://img.shields.io/github/license/aray-99/ohnishi-ime-layout)
![AutoHotkey v2.0](https://img.shields.io/badge/AutoHotkey-v2.0-2f4858)
![Platform: Windows 10/11](https://img.shields.io/badge/platform-Windows%2010%2F11-0078d6)

**「日本語は[大西配列](#大西配列とクレジット)で速く打ちたい。でも英語入力や Ctrl 系ショートカットは QWERTY のままがいい」** を叶える、AutoHotkey v2 製の Windows 常駐ツールです。

OS のキーボードレイアウトは変更しません。日本語 IME が**かな入力中かどうかを監視**し、**大西配列 ⇔ QWERTY を自動で切り替え**ます。だから切替操作なしで、日本語入力は大西配列、英数入力とショートカットは QWERTY のまま両立できます。

> ⚠️ 本ツールは大西配列を Windows で使うための**非公式・独立の実装**です。配列そのものの考案者とは無関係です（[クレジット](#大西配列とクレジット)）。

## 特徴

- **自動切替** — 日本語 IME のかな/カナ入力中だけ大西配列。英数入力（半角/全角）は QWERTY。手動切替は不要。
- **ショートカットを壊さない** — Ctrl / Alt / Win を伴う操作は常に QWERTY。`Ctrl` + `+` / `Ctrl` + `-` のズームも追加 Shift なしで動作（JIS 環境で確認）。
- **Shift はそのまま** — Shift 単独では大西配列を維持。
- **高速入力に配慮** — 同時押しの特殊解釈・時間判定・tap/hold・キーアップ待ちを一切しない。速い打鍵でも文字の欠落や順序逆転が起きない設計。
- **安全に復帰** — IME 状態を判定できないときは QWERTY へフォールバック。終了すれば即座に通常入力へ戻る（修飾キー残留なし）。
- **常駐運用** — 有効/無効・状態表示・再読込・緊急終了をホットキー/トレイから。アプリ単位の除外も可能。

## デモ

> デモ GIF（ひらがなで打つと大西配列、英数に戻すと QWERTY に自動で切り替わる様子）は準備中です。
<!-- 録画後: docs/assets/demo.gif を追加し、次行のコメントを外す -->
<!-- ![大西配列と QWERTY の自動切替](docs/assets/demo.gif) -->

## なぜ「OS のレイアウトを大西配列に変える」ではダメなのか

- OS のキーボードレイアウトごと大西配列にすると、**英語入力や `Ctrl` + `C` などのショートカットまで配列が変わって**しまい破綻します。
- IME の英数/かなを切り替えるたびに、レイアウトも手動で切り替えるのは非現実的です。

本ツールは **IME の状態を監視して自動で切り替える**ので、この手間や破綻なしに「日本語＝大西配列、英数＝QWERTY」を両立します。

## 安全性・プライバシー

全キー入力を扱うツールとして、次を守っています。

- キーストロークや入力内容を**一切ログに残しません**。
- **外部通信・テレメトリはありません**。
- **管理者権限を要求しません**。
- スクリプトを終了すれば**即座に通常の QWERTY 入力へ復帰**します。

## 大西配列とクレジット

**大西配列（Onishi Layout）は、[大西拓磨（Onishi Takuma）](https://note.com/illlilllililill)氏が考案した、日本語ローマ字入力に最適化されたキー配列です。** 100 万字のローマ字解析に基づき、QWERTY 比で指の移動距離を半分以下、同一指の連続打鍵を約 1/9 に削減し、母音と子音を左右に分離して交互打鍵を促す設計です。

- 🔗 **公式サイト（配列の定義・ヒートマップ・最新版）**: <https://0414.works/hairetu/>
- 📝 考案者の解説記事: [ローマ字入力に最適なキー配列を考える（制作編）](https://note.com/illlilllililill/n/n3b51f4aaf086) ／ [（比較編）](https://note.com/illlilllililill/n/nc099239c5565)

本リポジトリは、この配列を Windows の日本語 IME 上で使うための独立した実装にすぎません。**配列そのものの考案・権利は大西拓磨氏に帰属します。** 配列の正確・最新の定義は公式サイトをご確認ください。

本ツールが適用する物理キー → 出力の対応（Release 1）:

```text
物理位置: Q W E R T Y U I O P
出力文字: Q L U , . F W R Y P

物理位置: A S D F G H J K L ;
出力文字: E I A O - K T N S H

物理位置: Z X C V B N M , . /
出力文字: Z X C V ; G D M J B
```

## 動作環境・対象

- Windows 10 / 11
- [AutoHotkey v2.0 stable](https://www.autohotkey.com/)（v1 は不可）
- Windows 標準の日本語 IME（**ローマ字入力**）
- Release 1 の主対象は **JIS キーボード**

**こんな人向け**: JIS 配列の Windows 機で Windows 標準 IME のローマ字入力を使い、日本語入力だけを大西配列にしたい人。

## インストール

1. [AutoHotkey v2.0 stable](https://www.autohotkey.com/) をインストールする。
2. 本リポジトリをクローンまたは ZIP で取得する。
3. リポジトリ直下の `OhnishiLayout.ahk` をダブルクリックするか、次で起動する。

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" ".\OhnishiLayout.ahk"
```

起動すると有効状態で常駐します。ログイン時の自動起動は [`docs/operations.md`](docs/operations.md) を参照してください。

## クイックスタート

1. スクリプトを起動する。
2. メモ帳やブラウザなどで IME をひらがなにする。
3. 物理キー `D S E A F` を打つと「あいうえお」になります（大西配列）。
4. IME を半角英数に戻すと、通常の QWERTY に戻ります。

## 操作

| 操作 | ホットキー | タスクトレイ |
|---|---|---|
| 有効/無効 | Ctrl+Alt+F12 | Enabled |
| 状態表示 | Ctrl+Alt+F10 | Status |
| 再読み込み | Ctrl+Alt+F11 | Reload |
| 緊急終了 | Ctrl+Alt+Esc | Exit |

## アプリケーション除外

特定アプリを常に QWERTY にするには、`personal.example.ahk` を `personal.local.ahk`（gitignore 対象）へコピーして編集します。

```autohotkey
Layout.Exclude("mstsc.exe")
```

詳細は [`docs/operations.md`](docs/operations.md)。

## 既知の制約

- 対象は Windows 標準日本語 IME の**ローマ字入力**です。かな入力（直接かな）モードは対象外で、その状態では意図せず大西配列が適用され得ます。
- Release 1 の主対象は JIS キーボードです。US 物理キーボードの記号補正は Release 2 で対応予定です。
- IME 状態を入力ごとに問い合わせる設計のため、環境によってはごく僅かな遅延の可能性があります（実使用で体感はありません）。
- すべての IME・すべてのアプリでの完全動作は保証しません。
- CapsLock と半角/全角キーの入れ替えは本ツールの対象外です（必要なら PowerToys 等で各自設定してください）。

## 設計方針・ドキュメント

大西配列は「アプリで有効 かつ 除外対象外 かつ Ctrl/Alt/Win 非押下 かつ IME がかな入力中」のときだけ適用します。内部設計・意思決定の詳細は次を参照してください。

- [要件](docs/requirements.md) ／ [基本設計](docs/basic-design.md) ／ [設計判断（ADR）](docs/decisions.md)
- [運用・復旧ガイド](docs/operations.md) ／ [IME 技術検証](docs/spike-ime.md) ／ [手動テスト結果](docs/manual-test-checklist.md)
- [コントリビュート / 分岐運用](CONTRIBUTING.md)

## 状態 / ロードマップ

- [x] **Release 1（v1.0.0）: JIS Core** — 実機検証済み
- [ ] Release 2: US 物理キーボード互換レイヤー（バックスラッシュ / LaTeX 記号など）

## License

本リポジトリのコードは [MIT License](LICENSE) です。

大西配列そのものの考案・権利は大西拓磨氏に帰属します（[クレジット](#大西配列とクレジット)）。本ツールは非公式・独立の実装です。
