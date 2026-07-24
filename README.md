# Ohnishi IME Layout for Windows

![Release](https://img.shields.io/github/v/release/aray-99/ohnishi-ime-layout)
![License: MIT](https://img.shields.io/github/license/aray-99/ohnishi-ime-layout)
![AutoHotkey v2.0](https://img.shields.io/badge/AutoHotkey-v2.0-2f4858)
![Platform: Windows 10/11](https://img.shields.io/badge/platform-Windows%2010%2F11-0078d6)

日本語は[大西配列](#大西配列とは)で速く打ちたい。でも英字入力や `Ctrl+C` のようなショートカットは、いつもの QWERTY のままがいい。

**Ohnishi IME Layout for Windows** は、その両立だけをやる AutoHotkey v2 製の常駐ツールです。OS のキーボードレイアウトは一切変更しません。日本語 IME が「かな/カナ入力中かどうか」を常時監視し、**大西配列 ⇔ QWERTY を自動で切り替える**だけです。手動の切替操作は要りません。

> 本ツールは大西配列を Windows の日本語 IME 上で使うための**非公式・独立の実装**です。配列そのものの考案者・公式サイトとは関係がありません。詳しくは[大西配列とは](#大西配列とは)を参照してください。

## 大西配列とは

大西配列（Onishi Layout）は、**[大西拓磨（Onishi Takuma）](https://note.com/illlilllililill)氏が考案した**、日本語ローマ字入力向けのキー配列です。

大西氏の解説記事によれば、100 万字規模のローマ字入力データの解析に基づき、QWERTY と比べて指の移動距離を半分以下に、同一指の連続打鍵を約 1/9 に削減し、母音キーと子音キーを左右の手に分離することで交互打鍵を促す設計とされています（これは考案者による解析・主張であり、本ツールが測定・保証する数値ではありません）。

- 公式サイト（配列の定義・打鍵ヒートマップ・最新版）: <https://0414.works/hairetu/>
- 考案者による解説記事: [ローマ字入力に最適なキー配列を考える(制作編)](https://note.com/illlilllililill/n/n3b51f4aaf086) ／ [(比較編)](https://note.com/illlilllililill/n/nc099239c5565)
- 考案者 note プロフィール: <https://note.com/illlilllililill>

本リポジトリは、この配列を Windows の日本語 IME 上で使うための非公式・独立の実装です。**大西拓磨氏とは関係がなく**、氏からの認定・推奨を受けたものでもありません。配列そのものの考案・権利は大西拓磨氏に帰属します。配列の正確・最新の定義は必ず公式サイトをご確認ください。

本ツールが Release 1 で適用する、物理キー位置 → 出力文字の対応は次のとおりです（[要件定義](docs/requirements.md) §4 の定義に基づく）。

```text
物理位置: Q W E R T Y U I O P
出力文字: Q L U , . F W R Y P

物理位置: A S D F G H J K L ;
出力文字: E I A O - K T N S H

物理位置: Z X C V B N M , . /
出力文字: Z X C V ; G D M J B
```

表にない物理キー（数字段など）は QWERTY のまま出力されます。

## なぜ「OS のレイアウトごと大西配列にする」ではダメなのか

キーボードレイアウトそのものを大西配列に切り替える方法は手軽に見えますが、実運用では次の問題が出ます。

- レイアウトを切り替えると、英字入力や `Ctrl+C` / `Ctrl+V` のような**ショートカットの位置まで変わって**しまいます。
- IME を英数⇔かなで切り替えるたびに、レイアウトも手動で切り替えるのは現実的ではありません。

本ツールは IME の状態そのものを見て自動的に切り替えるので、この二律背反を意識せずに済みます。日本語入力は大西配列、英数入力とショートカットは QWERTY が、常に自動で成立します。

## 特徴

- **自動切替** — 日本語 IME がかな/カナ入力中のときだけ大西配列を適用。半角/全角英数モードでは QWERTY のまま。手動切替は不要です。
- **ショートカットを壊さない** — Ctrl / Alt / Win を伴うキー操作は常に QWERTY。`Ctrl` + `+` / `Ctrl` + `-` のズーム操作も、追加の Shift 押下なしで動作します（JIS 環境で実機確認済み）。
- **Shift はそのまま使える** — Shift 単独では大西配列を維持します（大文字・シフト記号は大西配列の対応キーで出力）。
- **高速タイピングを妨げない** — 同時押しの特殊解釈、時間判定、tap/hold、キーアップ待ちを一切行いません。転がし打ちのような速い入力でも、文字の欠落や順序の入れ替わりが起きない設計です。
- **判定できないときは安全側に倒れる** — IME の状態を取得できない場合は QWERTY にフォールバックします。スクリプトを終了すれば、修飾キーの残留なく即座に通常入力へ戻ります。
- **常駐運用のための最低限の機能** — 有効/無効、状態表示、再読み込み、緊急終了をホットキーとタスクトレイから。アプリケーション単位の除外設定にも対応します。

## デモ

> 準備中です（ひらがなで打つと大西配列、英数に切り替えると QWERTY へ自動で戻る様子を収録予定）。

<!-- 収録後、次のコメントを外して有効化する -->
<!-- ![大西配列と QWERTY の自動切替デモ](docs/assets/demo.gif) -->

## 動作環境・対象

- Windows 10 / 11
- [AutoHotkey v2.0 stable](https://www.autohotkey.com/)（v1 では動作しません）
- Windows 標準の日本語 IME（**ローマ字入力**）
- Release 1 の主対象は **JIS キーボード**（US 物理キーボードの記号補正は Release 2 で対応予定）

**こんな人に向いています**: JIS 配列の Windows 機で、Windows 標準 IME のローマ字入力を使い、日本語入力だけを大西配列にしたい人。

## インストール

1. [AutoHotkey v2.0 stable](https://www.autohotkey.com/) をインストールします。
2. 本リポジトリをクローン、または ZIP でダウンロードします。
3. リポジトリ直下の `OhnishiLayout.ahk` をダブルクリックするか、次のコマンドで起動します。

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" ".\OhnishiLayout.ahk"
```

起動すると有効な状態で常駐します。ログイン時の自動起動やアンインストール手順は [`docs/operations.md`](docs/operations.md) を参照してください。

## クイックスタート

1. `OhnishiLayout.ahk` を起動する。
2. メモ帳やブラウザなどで IME をひらがな入力にする。
3. 物理キー `D S E A F` を打つと「あいうえお」になる（大西配列が適用されている）。
4. IME を半角英数に戻すと、通常の QWERTY 入力に戻る。

## 操作

管理ホットキーはすべて Ctrl+Alt を伴うため、大西配列の文字変換とは干渉しません。

| 操作 | ホットキー | タスクトレイ |
|---|---|---|
| 有効/無効の切替 | Ctrl+Alt+F12 | Enabled |
| 状態表示 | Ctrl+Alt+F10 | Status |
| 再読み込み | Ctrl+Alt+F11 | Reload |
| 緊急終了 | Ctrl+Alt+Esc | Exit |

状態表示は、有効/無効・IME が composition 中か・前面アプリ名と除外状態を、フォーカスを奪わないツールチップで数秒間表示します。

## アプリケーション除外

特定のアプリ（リモートデスクトップやゲームなど）を常に QWERTY にしたい場合は、`personal.example.ahk` を `personal.local.ahk`（gitignore 対象、リポジトリには含まれません）としてコピーし、次のように記述します。

```autohotkey
Layout.Exclude("mstsc.exe")
```

`personal.local.ahk` は起動時に自動で読み込まれます（存在しない場合は無視されます)。反映には再読み込み（Ctrl+Alt+F11）を行ってください。詳細は [`docs/operations.md`](docs/operations.md) を参照してください。

## 安全性・プライバシー

すべてのキー入力を扱うツールだからこそ、次を徹底しています。

- キーストロークや入力内容を**一切ログに記録しません**。
- **外部通信・テレメトリはありません**。ネットワークには一切接続しません。
- **管理者権限を必要としません**。
- レジストリや OS のキーボードレイアウト設定は変更しません。
- スクリプトを終了すれば、**即座に通常の QWERTY 入力へ復帰**します（キー送出は押下ごとに down/up で完結するため、修飾キーが残留したまま固着することもありません）。
- ソースコードは公開されており、誰でも動作を確認できます（[MIT License](LICENSE)）。

## 既知の制約

- 対象は Windows 標準日本語 IME のローマ字入力です。かな入力（直接かな入力）モードは対象外で、その状態では意図せず大西配列が適用され得ます。
- Release 1 の主対象は JIS キーボードです。US 物理キーボードの記号補正は Release 2 で対応予定です。
- IME の状態を入力のたびに問い合わせる設計のため、環境によってはごく僅かな遅延が生じる可能性があります（実使用で体感するものではありません）。
- すべての日本語 IME・すべてのアプリケーションでの完全な動作を保証するものではありません。
- CapsLock と半角/全角キーの入れ替えは本ツールの対象外です。必要な場合は PowerToys などで各自設定してください（同じ物理キーを PowerToys と本ツールの両方でリマップしないよう注意してください）。

## 実機での検証

Release 1（v1.0.0）は、実機の JIS 環境（Windows 11 / AutoHotkey 2.0.19 / Windows 標準 IME）で、かな/カナ→大西配列・英数→QWERTY・Ctrl 系バイパス・`Ctrl+ +`/`Ctrl+ -`・Shift・高速入力・管理ホットキー・終了後の QWERTY 復帰といった主要な挙動を手動検証済みです。

検証の過程では、実機でしか見つからないバグも 2 件発見・修正しています。PowerToys で無変換キーを Ctrl にリマップした環境で Ctrl バイパスが効かなかった問題（判定を論理キー状態に変更して解決）と、Windows 11 の新しいメモ帳で IME 状態を検出できなかった問題（フォーカス中のコントロールへの問い合わせに変更して解決）です。詳しい経緯は [`docs/decisions.md`](docs/decisions.md)（ADR-013・ADR-014）、検証結果全体は [`docs/manual-test-checklist.md`](docs/manual-test-checklist.md) と [`docs/spike-ime.md`](docs/spike-ime.md) を参照してください。

## 設計方針・ドキュメント

大西配列は「アプリケーション単位で有効かつ除外対象外」「Ctrl/Alt/Win 非押下」「IME がかな/カナ入力中」がすべて揃ったときだけ適用されます。内部設計や意思決定の詳細は次のドキュメントを参照してください。

- [要件](docs/requirements.md) ／ [基本設計](docs/basic-design.md) ／ [設計判断（ADR）](docs/decisions.md)
- [運用・復旧ガイド](docs/operations.md) ／ [IME 技術検証記録](docs/spike-ime.md) ／ [手動検証結果](docs/manual-test-checklist.md)
- [コントリビュート / ブランチ運用](CONTRIBUTING.md) ／ [変更履歴](CHANGELOG.md)

## 状態 / ロードマップ

- [x] **Release 1（v1.0.0）: JIS Core** — 実機検証済み
- [ ] Release 2: US 物理キーボード互換レイヤー（バックスラッシュ・LaTeX 記号などの記号補正）

## License

本リポジトリのコード（AutoHotkey スクリプトおよびドキュメント）は [MIT License](LICENSE) です。

大西配列そのものの考案・権利は大西拓磨氏に帰属します（[大西配列とは](#大西配列とは)参照）。本ツールは氏とは無関係な、非公式・独立の実装です。
