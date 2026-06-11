#!/usr/bin/env bash
set -euo pipefail

read -r -p "请输入要移除的项目名称: " project

if [[ -z "$project" ]]; then
  echo "项目名称不能为空"
  exit 1
fi

if [[ ! "$project" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "项目名称只能包含字母、数字、点、下划线、短横线"
  exit 1
fi

branch="feature/${project}"
repo_root="$(git rev-parse --show-toplevel)"
worktree_dir="${repo_root}/.worktrees/repo_${project}"

current_branch="$(git branch --show-current)"

if [[ "$current_branch" != "main" ]]; then
  echo "请先切换到 main 分支后再执行删除脚本"
  echo "当前分支: $current_branch"
  exit 1
fi

echo "即将强制删除:"
echo "worktree: $worktree_dir"
echo "branch:   $branch"
echo

read -r -p "确认删除请输入项目名称 '${project}': " confirm

if [[ "$confirm" != "$project" ]]; then
  echo "已取消"
  exit 0
fi

if git worktree remove --force --force "$worktree_dir"; then
  echo "已删除 worktree: $worktree_dir"
else
  echo "git worktree remove 失败，尝试清理 stale worktree 记录..."
  git worktree prune --expire now
fi

if [[ -d "$worktree_dir" ]]; then
  rm -rf -- "$worktree_dir"
  echo "已删除残留目录: $worktree_dir"
fi

git worktree prune --expire now

if git show-ref --verify --quiet "refs/heads/${branch}"; then
  git branch -D "$branch"
  echo "已强制删除分支: $branch"
else
  echo "分支不存在，跳过分支删除: $branch"
fi