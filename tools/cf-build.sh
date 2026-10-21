#!/usr/bin/env bash
# Cloudflare 建置腳本：下載指定版本的 Hugo，抓主題，再建置網站到 public/
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.167.0}"

git submodule update --init --recursive

# Cloudflare 可能只抓最新一個 commit；抓完整歷史，Hugo 才算得出每篇文章的修改日期
if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
  git fetch --unshallow --quiet || true
fi

curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" \
  | tar -xz -C /tmp hugo

/tmp/hugo version
/tmp/hugo --gc --minify
