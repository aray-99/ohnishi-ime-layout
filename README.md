# Ohnishi IME Layout for Windows

AutoHotkey v2で、日本語IMEのローマ字入力時だけ大西配列を適用するための
Windows向け常駐スクリプトです。

> 現在は設計・技術検証開始前のInitial Commitです。実装はGitHub Issue単位で
> 追加します。

## 設計の中心

- 日本語IMEのかな・カナ系ローマ字入力時：大西配列
- 日本語IMEの英数入力時：QWERTY
- Ctrl / Alt / Winショートカット：常にQWERTY優先
- 文字キーの同時押し・時間判定・tap/hold：実装しない
- 初期リリース：JIS Core
- 第2段階：US物理キーボード互換レイヤー
- CapsLockと半角/全角の交換：公開Coreから分離し、当面PowerToys側に残す

詳細は次を参照してください。

- [要件](docs/requirements.md)
- [基本設計](docs/basic-design.md)
- [設計判断](docs/decisions.md)
- [Issue計画](docs/issue-plan.md)
- [手動テスト](docs/manual-test-checklist.md)
- [Claude Code作業規約](CLAUDE.md)

## 想定環境

- Windows 10 / 11
- AutoHotkey v2.0 stable
- Windows標準の日本語IME
- 内蔵JISキーボードをRelease 1の主対象とする

## 開発開始

PowerShellとGitHub CLIを利用できる環境では、Initial CommitをGitHubへpushした後に
次を実行します。

```powershell
gh auth status
./scripts/create-issues.ps1
```

その後、Claude Codeへ [`prompts/IMPLEMENT_WITH_CLAUDE_CODE.md`](prompts/IMPLEMENT_WITH_CLAUDE_CODE.md)
の内容を渡します。

## 状態

- [x] 要件・基本設計
- [x] Issue計画
- [ ] IME技術検証
- [ ] JIS Core
- [ ] Release 1
- [ ] US互換レイヤー

## License

Initial Commitではライセンス候補をMITとしています。公開前に
`LICENSE`の著作権者表記を確認してください。
