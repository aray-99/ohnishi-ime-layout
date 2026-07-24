# SPIKE-IME 技術検証記録（Issue #1）

Windows標準日本語IMEのモード判定と、AutoHotkey v2からIMEへ文字キーを送る方式を
確定するための技術検証。採用方針の要約は `docs/decisions.md`（ADR-009〜011）を参照。

> **重要:** 本記録の「期待値」列はWindows IMM APIの仕様と一般的なMS-IMEの挙動から
> 導いた**未検証の予測**である。実機のJIS環境・日本語IMEでの観測は所有者が行い、
> 「実測」欄へ記入する。実機確認前に確定扱いにしないこと（CLAUDE.md §13）。

## 1. 判定方式（採用）

対象ウィンドウの既定IMEウィンドウ（`ImmGetDefaultIMEWnd`）へ `WM_IME_CONTROL`
（0x0283）を `SendMessageTimeout`（50ms, SMTO_ABORTIFHUNG）で送信し、次を取得する。

- `IMC_GETOPENSTATUS`（0x0005）: IMEのオン/オフ
- `IMC_GETCONVERSIONMODE`（0x0001）: 変換モードのビットフラグ

判定ルール:

```text
大西配列を適用する = (open == 1) AND (conversionMode & CMODE_NATIVE)
```

- `CMODE_NATIVE`（0x0001）が立っていれば、かな/カタカナ系のローマ字入力モード。
- 取得失敗・タイムアウト時は「非composition」とみなしQWERTYへフォールバック。

実装は `src/ime.ahk`（`Ime.IsJapaneseComposition()`）。

## 2. IMEモード別の期待値（未検証）

`0xNNNN` はローマ字入力（ROMAN, 0x0010あり）を前提とした典型値。実機の値は
IMEやバージョンで異なり得るため、判定は個別ビットではなく **NATIVEビットのみ** で行う。

| IMEモード | IME open（期待） | conversion（期待） | NATIVE | 大西配列（方針） | 実測 open | 実測 conversion | 一致 |
|---|---|---|---|---|---|---|---|
| IME OFF / 直接入力 | 0 | 該当なし | - | QWERTY | | | |
| ひらがな | 1 | 0x0019 `[NATIVE FULLSHAPE ROMAN]` | あり | 大西配列 | | | |
| 全角カタカナ | 1 | 0x001B `[NATIVE KATAKANA FULLSHAPE ROMAN]` | あり | 大西配列 | | | |
| 半角カタカナ | 1 | 0x0013 `[NATIVE KATAKANA ROMAN]` | あり | 大西配列 | | | |
| 全角英数 | 1 | 0x0008 `[FULLSHAPE]` | なし | QWERTY | | | |
| 半角英数 | 1 または 0 | 0x0000 `[ALPHANUMERIC]` | なし | QWERTY | | | |

カタカナ（全角/半角）はNATIVEが立つため大西配列を適用する、と決定した（ADR-009）。
これは要件・手動テスト表の「大西配列候補（技術検証で確定）」を確定させたもの。

**既知の制約:** かな入力（ローマ字ではない直接かな入力, ROMANビットなし）でも
NATIVEは立つため本判定では大西配列が有効になる。要件 §6 でかな入力配列は対象外
であり、所有者はローマ字入力を使用するため実害はないが、制約として記録する。

## 3. キー送出方式（採用）

- コンテキスト付きホットキー `*src::Send "{Blind}dst"`、送出は v2 既定の SendInput。
- `{Blind}` によりShift状態を保持 → Shift併用で大文字/対応記号が出力される。
- キーリピートはOSが物理キー押下を再送しホットキーが再発火することで実現。
  タイマー・Sleep・キーアップ待ち・DownR保持は使わない。
- SendLevelは既定（0）のまま。生成キーは自身のホットキーを再発火させない
  （= 生成キーの再変換なし）。

送出元/送出先のキー指定（ADR-011）:

- 英字ソース: 文字（A–Z）で指定（JIS/USでVK/SC共通）。
- 記号ソース: **スキャンコード**で指定（物理位置。JISではVKが異なるため）。
  - `;`=SC027, `,`=SC033, `.`=SC034, `/`=SC035
- 記号ターゲット: **リテラル文字**で送出（現在の配列に合わせAHKがキーを解決）。
  - 例: `;` は US では VK_OEM_1 だが JIS では VK_OEM_PLUS。文字送出なら両対応。

本スパイクでは D→A, F→O, J→T の3キーで送出を検証する。

## 4. 観測・検証手順（所有者が実施）

1. `spike/ime-spike.ahk` を AutoHotkey v2 で実行する（左上に情報パネルが出る）。
2. メモ帳など日本語入力できるアプリを前面にする。
3. IMEを各モードへ切り替え、パネルの `IME open` / `Conversion` / `Composition?`
   を上表「実測」欄へ記入する。
4. ひらがなモードで `d` `f` `j` を打ち、`あ` `お` `と` が出ることを確認（送出検証）。
5. **Ctrlバイパス:** 何か入力後、Ctrl+D等でQWERTYのCtrlショートカットが働き、
   `あ` に化けないことを確認（パネルのremapがONのままでも、Ctrl押下で無効化）。
6. **Shift:** Shift+D で大文字/対応出力になること。
7. **キーリピート:** `d` を長押しし、通常のリピートになること。
8. **重なり押下:** `d f j` を高速で転がし打ちして、欠落・順序逆転がないこと。
9. **記号キー確認（任意）:** Ctrl+Alt+I を押し、`;` `,` `.` `/` を1つずつ押して
   VK/SCを確認し、SC027/033/034/035 と一致するか記録する。
10. 終了は Ctrl+Alt+Q。

観測中も本ツールはキー内容を保存・記録しない（パネルはIME状態のみ表示、
identifyは押した1キーのVK/SCを一度表示するのみ）。

## 5. 実機結果

### 5.1 自動観測（検出のみ・部分検証）

2026-07-22、読み取り専用プローブ（キー送出なし）で前面ウィンドウのIME状態を
プログラム取得した結果:

| 項目 | 値 |
|---|---|
| 前面プロセス | Code.exe |
| IME open | 1 |
| conversion | 0x09 `[NATIVE FULLSHAPE]` |
| `IsJapaneseComposition()` | true |

- `src/ime.ahk` のDllCall経路（`ImmGetDefaultIMEWnd` + `SendMessageTimeout`）が
  実機で動作し、ひらがなモードで正しく true を返すことを確認した。
- **重要:** この環境のひらがなモードでは ROMAN ビット（0x10）が立たず 0x09 だった。
  判定に ROMAN を要求していれば誤って無効化されるところで、NATIVEのみで判定する
  ADR-009 の選択が正しいことが実機で裏付けられた（期待値 0x19 は環境により 0x09）。
- **未検証:** キー送出（d→あ 等）、カタカナ・英数各モード、Ctrl/Shift/リピート/
  重なりの実挙動。以下の記入欄で所有者が確認する。

### 5.3 実機検証セッション（Issue #4, 2026-07-23）で判明した事項

Edge等の実アプリで所有者が確認した結果:

- **検出**: Edge（msedge.exe）で `open=1, 0x0009 [NATIVE FULLSHAPE], Composition=YES`。
  トップレベル/フォーカス両プローブとも検出成功。
- **送出**: 3キー版スパイクで物理 D→あ, F→お が正しく送出。他キーは素通り（正常）。
- **リピート/重なり打鍵**: 問題なし。
- **Shift**: `Shift+D → A`（設計どおり。Shift併用で大文字。IMEのShift→半角英数
  挙動によりcompositionが一瞬offになるのは正常）。
- **新メモ帳（TSF/WinUI）**: トップレベルhwnd経由ではIMEを検出できないが、
  フォーカスhwnd（GetGUIThreadInfo）経由なら検出できた → ADR-014で修正（#14）。
- **PowerToys 無変換→Ctrl**: 注入Ctrlが物理状態に現れず、`"P"` 判定ではバイパスが
  効かず `無変換+D → Ctrl+A → 全選択` になった。実Ctrlでは正常。→ ADR-013で
  論理状態判定に修正（#14）。修正後、実機で 無変換+D と新メモ帳を再確認する。

### 5.2 記入欄（所有者が実施）

- 実施日:
- Windows:
- AutoHotkey:
- IME:
- 物理キーボード:
- 送出検証（D→あ, F→お, J→と）:
- Ctrlバイパス:
- Shift:
- キーリピート:
- 重なり押下:
- 記号キーVK/SC（SC027/033/034/035）:
- 判定方式で問題が出たモード:
- 追記すべき制約・追加Issue:
