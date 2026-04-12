---
name: read-issue
description: GitHub Issueの内容（タイトル、本文、ラベル、コメント）を確認し、実装要件を整理する時に使うスキル。
argument-hint: "[issue-number]"
allowed-tools: Bash(gh issue view *)
---

## 確認方法

- `gh issue view $ARGUMENTS --comments`

## 注意点

- 確認した内容は、節目ごとに作業メモとして残すこと。要件の整理結果や判断のポイントを記録し、後続の作業で参照できるようにする。
