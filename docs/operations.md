# 運用・復旧ガイド（Release 1）

`OhnishiLayout.ahk` の起動・操作・除外設定・自動起動・終了・復旧・PowerToys併用を
まとめる。本アプリはレジストリを変更せず、管理者権限を要求せず、外部通信もしない。

## 1. 前提

- Windows 10 / 11
- AutoHotkey v2.0 stable（例: `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`）
- Windows標準の日本語IME（ローマ字入力）

## 2. 起動

エクスプローラーで `OhnishiLayout.ahk` をダブルクリックするか、次を実行する。

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "<repo>\OhnishiLayout.ahk"
```

起動すると有効状態で常駐し、短い通知を表示する。多重起動しても
`#SingleInstance Force` により後発が先発を置き換えるため、二重変換は起きない。

## 3. 操作（管理ホットキー / タスクトレイ）

| 操作 | ホットキー | タスクトレイ |
|---|---|---|
| 有効/無効の切替 | Ctrl+Alt+F12 | 「Enabled」 |
| 状態表示 | Ctrl+Alt+F10 | 「Status」（ダブルクリックでも） |
| 再読み込み | Ctrl+Alt+F11 | 「Reload」 |
| 緊急終了 | Ctrl+Alt+Esc | 「Exit」 |

- 管理ホットキーはCtrl+Altを伴うため、大西配列の文字変換とは干渉しない。
- 状態表示は、有効/無効・IMEがcomposition中か・前面アプリ名と除外状態を、
  フォーカスを奪わないツールチップで数秒表示する。

## 4. アプリケーション除外

前面が特定アプリのときは常にQWERTYにできる。リポジトリ直下の
`personal.example.ahk` を `personal.local.ahk`（gitignore対象）へコピーし、次を書く。

```autohotkey
Layout.Exclude("mstsc.exe")             ; リモートデスクトップ
Layout.Exclude("someGame.exe", "vmware.exe")
```

`personal.local.ahk` は起動時に自動で読み込まれる（無ければ無視）。名前は
大文字小文字を区別しない。反映には再読み込み（Ctrl+Alt+F11）を行う。

## 5. 自動起動（任意）

`shell:startup` にショートカットを置くとログイン時に起動する。

作成:

```powershell
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut("$([Environment]::GetFolderPath('Startup'))\OhnishiLayout.lnk")
$lnk.TargetPath = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
$lnk.Arguments  = '"<repo>\OhnishiLayout.ahk"'
$lnk.Save()
```

解除: `shell:startup` フォルダ内の `OhnishiLayout.lnk` を削除する。

## 6. 終了と復帰

- 通常終了・緊急終了のいずれでも、AutoHotkeyがホットキーを解除し、OS標準の
  QWERTY入力へ戻る。本アプリの送出は押下ごとに down+up で完結するため、修飾キーは
  残留しない。
- キー入力がおかしくなった場合の復旧手順:
  1. Ctrl+Alt+Esc で緊急終了。
  2. 効かない場合はタスクマネージャーで `AutoHotkey64.exe` を終了。
  3. それでも直らない場合はサインアウト/再ログイン。

## 7. アンインストール

インストーラを持たないため、次で完全に除去できる。

1. スクリプトを終了する（Ctrl+Alt+Esc）。
2. 自動起動を設定していれば `shell:startup` の `OhnishiLayout.lnk` を削除。
3. リポジトリのフォルダを削除。

システム設定・レジストリは変更していないため、他の後始末は不要。

## 8. PowerToysとの併用

- Release 1では、所有者のCapsLock↔半角/全角の入れ替えはPowerToys側に残す。
  本Coreはこの設定に依存しない（CapsLockも半角/全角キーもリマップしない）。
- 同じ物理キーをPowerToysとAutoHotkeyの両方でリマップしないこと。二重リマップは
  予期しない挙動の原因になる。
- 将来AutoHotkey側へ移す場合は、先にPowerToys側を無効化し、任意の
  `personal.local.ahk`（Personalモジュール）として実装する。既定では有効化しない。
