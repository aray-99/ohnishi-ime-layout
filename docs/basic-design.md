# 基本設計

## 1. リリース構成

### Release 1: JIS Core

日本語IMEの入力モードと修飾キー状態を条件に、大西配列を適用する小規模な
AutoHotkey v2常駐スクリプトを作成する。

### Release 2: US互換レイヤー

JIS Coreから独立した任意機能として、US物理キーボードの記号位置を補正する。

## 2. 適用判定

概念上、次の条件をすべて満たした場合だけ大西配列の文字ホットキーを有効化する。

```text
layoutEnabled
AND NOT IsExcludedApplication()
AND IsJapaneseCompositionMode()
AND NOT CtrlPressed
AND NOT AltPressed
AND NOT WinPressed
```

Shiftは除外条件に含めない。

IME判定失敗時は`false`とする。

## 3. 判定順序

1. 管理ホットキー
2. アプリケーション全体の有効状態
3. 除外アプリ
4. Ctrl / Alt / Win状態
5. IME開閉状態と変換モード
6. 大西配列変換

## 4. コンポーネント候補

実装規模を確認してから最小限のファイルにまとめる。

- Bootstrap：v2要求、多重起動、初期化
- Configuration：ローカル設定
- IME Context：IME状態と変換モード
- Remap Context：適用可否
- Ohnishi Layout：文字マッピング
- Commands：有効化、状態表示、再読込、終了
- Exclusions：対象外アプリ
- Notifications：短時間の状態通知

関数境界の候補：

```text
IsImeOpen()
GetImeConversionMode()
IsJapaneseCompositionMode()
IsExcludedApplication()
ShouldUseOhnishiLayout()
ToggleLayout()
ShowStatus()
```

具体的なAPI・戻り値は技術検証Issueで確定する。

## 5. キー処理

個別の文字キーを、コンテキスト条件付きホットキーまたはリマップとして定義する。

次を技術検証で比較する。

- AutoHotkeyのリマップ構文
- 条件付きホットキー
- Send系方式
- 仮想キー
- スキャンコード

選定条件：

- IMEへローマ字キーとして自然に渡る
- Shift入力が動く
- キーリピートが動く
- 高速入力で再現性のある欠落や順序逆転がない
- 生成キーを再変換しない
- Ctrl / Alt / Win時にQWERTYとなる
- キーアップの不整合や修飾キー残留を起こさない

## 6. 高速入力

文字キー単位で即時処理する。

通常文字について、次を行わない。

- KeyWait相当の待機
- Sleep
- タイマーによる遅延送信
- 前後キーの組合せ判定
- キーアップを待った確定

受入基準は、通常の高速入力で再現性のある文字欠落、順序逆転、修飾キー残留、
特殊動作の誤発火がないこととする。

## 7. 管理ホットキー初期候補

| 操作 | 初期候補 |
|---|---|
| 有効/無効 | Ctrl+Alt+F12 |
| 再読み込み | Ctrl+Alt+F11 |
| 状態表示 | Ctrl+Alt+F10 |
| 緊急終了 | Ctrl+Alt+Esc |
| JIS/US切替え | Ctrl+Alt+F9（Release 2） |

実装時にWindowsや主要アプリとの競合を確認する。

## 8. PowerToys

Release 1ではCapsLockと半角/全角の交換をPowerToysに残す。

Coreはその設定の有無に依存しない。

将来AutoHotkeyへ移す場合は、PowerToys側を先に無効化し、任意のPersonal
モジュールとして実装する。

## 9. US互換レイヤー

Coreから独立したプロファイル機能として設計する。

目的は、英語IMEへの頻繁な切替えなしに、US物理キーボードの印字に近い記号位置を
利用できるようにすること。

優先検証：

1. バックスラッシュ
2. 丸括弧
3. 波括弧
4. 角括弧
5. ハイフン/アンダースコア
6. イコール/プラス
7. バッククォート/チルダ

入力元キーボードの自動識別はRelease 2にも必須としない。

## 10. 失敗時動作

- IME判定不能：QWERTY
- 設定不正：安全な既定値または起動中止
- 未対応アプリ：除外可能
- スクリプト終了：OS標準入力へ復帰
- GitHub操作不能：ローカル成果と正確なコマンドを残し、成功を装わない
