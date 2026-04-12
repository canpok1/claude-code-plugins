# CLAUDE.md

## 使用言語

すべてのやり取りを日本語で行うこと。対象は以下のとおり。

- ユーザーとの会話（説明、質問、報告など）
- コミットメッセージ
- PR・Issueの本文

## GitHub Issue/PR管理

Issue や PR を作成する際は、末尾に以下のフッターを付与すること。

```text
🤖 Generated with [Claude Code](https://claude.ai/code)
```

作成後は、想定通りに作成できたか内容を確認すること。

## 独り言（monologue）スキル

`/vox-actor-plugin:monologue` スキルを以下のタイミングで積極的に使うこと。

- 作業開始・終了時時
- ステップの開始・終了時
- 想定外のことが起こったとき
- ユーザーに確認が必要なとき
- 新しい発見があったとき
