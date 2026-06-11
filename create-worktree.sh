#!/usr/bin/env bash
set -euo pipefail

read -r -p "请输入项目名称: " project

if [[ -z "$project" ]]; then
  echo "项目名称不能为空"
  exit 1
fi

if [[ ! "$project" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "项目名称只能包含字母、数字、点、下划线、短横线"
  exit 1
fi

if ! command -v trae-cn >/dev/null 2>&1; then
  echo "未找到 trae-cn 命令，请先确认它已安装并在 PATH 中"
  exit 1
fi

branch="feature/${project}"
repo_root="$(git rev-parse --show-toplevel)"
worktree_dir="${repo_root}/.worktrees/repo_${project}"

git check-ref-format --branch "$branch" >/dev/null

mkdir -p "${repo_root}/.worktrees"

git worktree add -b "$branch" "$worktree_dir" main

echo "已创建 worktree: $worktree_dir"
echo "分支名称: $branch"
echo "项目目录: $worktree_dir"

cd "$worktree_dir"
trae-cn .
