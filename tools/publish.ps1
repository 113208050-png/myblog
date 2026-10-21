# 發佈文章：列出 content/ 裡有變更的檔案，讓你選要上傳哪幾個，
# 再 commit 並推上 GitHub，Cloudflare 會自動更新網站
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$site = 'https://bluewind-blog.bluewindblog.workers.dev'

function Finish($code) {
  Write-Host ''
  Read-Host '按 Enter 關閉視窗' | Out-Null
  exit $code
}

Write-Host ''
Write-Host '=== 發佈文章 ===' -ForegroundColor Cyan
Write-Host ''

$changes = @(git -c core.quotepath=false status --porcelain -- content)
if ($changes.Count -eq 0) {
  Write-Host 'content/ 裡沒有新的變更，不用發佈。' -ForegroundColor Yellow
  Write-Host '（檔案有存檔嗎？VS Code 分頁上有白點 ● 代表還沒存）'
  Finish 0
}

# 整理每個變更：路徑、動作、標題、是否草稿
$items = @()
foreach ($line in $changes) {
  $path = $line.Substring(3).Trim('"')
  $action = switch -Regex ($line.Substring(0, 2)) { 'D' { '刪除' } '\?\?|A' { '新增' } default { '修改' } }
  $title = ''
  $draft = $false
  $md = if ($path.EndsWith('/')) { Join-Path $path 'index.md' } else { $path }
  if ($md -like '*.md' -and $action -ne '刪除' -and (Test-Path $md)) {
    $text = [IO.File]::ReadAllText((Join-Path $root $md), [Text.Encoding]::UTF8)
    if ($text -match '(?m)^title:\s*"?(.+?)"?\s*$') { $title = $Matches[1] }
    $draft = $text -match '(?m)^draft:\s*true\s*$'
  }
  $items += [pscustomobject]@{ Path = $path; Action = $action; Title = $title; Draft = $draft }
}

Write-Host '有變更的檔案：'
Write-Host ''
for ($i = 0; $i -lt $items.Count; $i++) {
  $it = $items[$i]
  $name = if ($it.Title) { $it.Title } else { $it.Path }
  Write-Host ("  [{0}] {1}  {2}" -f ($i + 1), $it.Action, $name) -NoNewline
  if ($it.Draft) { Write-Host '  （草稿，不會上網站）' -ForegroundColor Yellow -NoNewline }
  Write-Host ''
  if ($it.Title) { Write-Host ("       {0}" -f $it.Path) -ForegroundColor DarkGray }
}

# 選擇要上傳的項目
Write-Host ''
Write-Host '要上傳哪幾個？輸入號碼，例如 1 或 1,3 或 1-3；輸入 a 全部上傳；直接按 Enter 取消'
$pick = (Read-Host '選擇').Trim()
if (-not $pick) {
  Write-Host '已取消，沒有任何變更。'
  Finish 0
}

$selected = @()
if ($pick -match '^[Aa]$') {
  $selected = $items
} else {
  foreach ($part in ($pick -split '[,，\s]+' | Where-Object { $_ })) {
    if ($part -match '^(\d+)-(\d+)$') {
      $nums = [int]$Matches[1]..[int]$Matches[2]
    } elseif ($part -match '^\d+$') {
      $nums = @([int]$part)
    } else {
      Write-Host "看不懂「$part」，請輸入號碼。已取消。" -ForegroundColor Red
      Finish 1
    }
    foreach ($n in $nums) {
      if ($n -lt 1 -or $n -gt $items.Count) {
        Write-Host "沒有第 $n 個。已取消。" -ForegroundColor Red
        Finish 1
      }
      if ($selected -notcontains $items[$n - 1]) { $selected += $items[$n - 1] }
    }
  }
}

Write-Host ''
Write-Host '這次會上傳：'
$selected | ForEach-Object {
  $name = if ($_.Title) { $_.Title } else { $_.Path }
  Write-Host "  - [$($_.Action)] $name"
}
$selectedDrafts = @($selected | Where-Object { $_.Draft })
if ($selectedDrafts.Count -gt 0) {
  Write-Host ''
  Write-Host '注意：裡面有草稿（draft: true），不會出現在網站上，但 GitHub 上看得到內容。' -ForegroundColor Yellow
}

$titles = @($selected | Where-Object { $_.Title } | ForEach-Object { $_.Title })
$default = if ($titles.Count -gt 0) { '更新文章：' + ($titles -join '、') } else { '更新網站內容' }
Write-Host ''
Write-Host "說明（直接按 Enter 使用）：$default"
$msg = (Read-Host '或輸入自己的說明').Trim()
if (-not $msg) { $msg = $default }

Write-Host ''
$ok = Read-Host '確定要上傳嗎？(Y/n)'
if ($ok -and $ok -notmatch '^[Yy]') {
  Write-Host '已取消，沒有任何變更。'
  Finish 0
}

# 只 commit 選到的檔案；commit 訊息寫進暫存檔，避免中文在命令列被轉碼
$paths = @($selected | ForEach-Object { $_.Path })
$msgFile = Join-Path $env:TEMP 'myblog-commit-msg.txt'
[IO.File]::WriteAllText($msgFile, $msg, (New-Object Text.UTF8Encoding $false))

git add -A -- $paths
git commit -q -F $msgFile -- $paths
Remove-Item $msgFile -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
  Write-Host 'commit 失敗，請把這個視窗截圖給 Claude。' -ForegroundColor Red
  Finish 1
}

Write-Host '正在同步 GitHub……'
git pull --rebase --autostash -q
if ($LASTEXITCODE -ne 0) {
  Write-Host 'GitHub 上有衝突的變更，沒有推送。請把這個視窗截圖給 Claude。' -ForegroundColor Red
  Finish 1
}

git push -q
if ($LASTEXITCODE -ne 0) {
  Write-Host '推送失敗（文章已經 commit 在電腦裡，不會遺失）。請把這個視窗截圖給 Claude。' -ForegroundColor Red
  Finish 1
}

$left = @($items | Where-Object { $selected -notcontains $_ })
Write-Host ''
Write-Host '上傳完成！約 15–60 秒後網站會更新：' -ForegroundColor Green
Write-Host "  $site"
if ($left.Count -gt 0) {
  Write-Host ''
  Write-Host "還有 $($left.Count) 個沒上傳的變更留在電腦裡，下次再選就好。" -ForegroundColor DarkGray
}
Finish 0
