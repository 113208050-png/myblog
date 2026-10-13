# 建立新文章：問標題和分類，產生格式正確的 .md，再用 VS Code 打開
$ErrorActionPreference = 'Stop'
$root  = Split-Path -Parent $PSScriptRoot
$posts = Join-Path $root 'content\posts'

Write-Host ''
Write-Host '=== 新增文章 ===' -ForegroundColor Cyan
Write-Host ''

do { $title = (Read-Host '文章標題').Trim() } while (-not $title)

Write-Host ''
Write-Host '分類：  1) AI 探索    2) 政大日常'
$choice = Read-Host '選 1 或 2（直接按 Enter = 1）'
$category = if ($choice -eq '2') { '政大日常' } else { 'AI 探索' }

Write-Host ''
$slug = (Read-Host '英文網址名稱，例如 my-ai-blog（可直接按 Enter 跳過）').Trim().ToLower()
$slug = ($slug -replace '[^a-z0-9]+', '-').Trim('-')
$now  = Get-Date
if (-not $slug) { $slug = $now.ToString('yyyy-MM-dd-HHmm') }

$file = Join-Path $posts "$slug.md"
if (Test-Path $file) {
  $file = Join-Path $posts ("$slug-" + $now.ToString('HHmmss') + '.md')
}

$escapedTitle = $title -replace '"', '\"'
$content = @"
---
title: "$escapedTitle"
date: $($now.ToString('yyyy-MM-ddTHH:mm:sszzz'))
draft: true
categories: ["$category"]
tags: []
summary: ""
---

在這裡開始寫內文。

寫完後把上面的 draft: true 改成 draft: false 才會發佈。
"@

[IO.File]::WriteAllText($file, $content.Replace("`r`n", "`n"), (New-Object Text.UTF8Encoding $false))

Write-Host ''
Write-Host "已建立：content\posts\$(Split-Path -Leaf $file)" -ForegroundColor Green

if (Get-Command code -ErrorAction SilentlyContinue) {
  code $root -g "${file}:10"
} else {
  notepad $file
}

Start-Sleep -Seconds 2
