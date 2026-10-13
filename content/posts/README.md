# 📝 新文章放這裡

這個資料夾（`content/posts/`）就是放部落格文章的地方。
**每篇文章 = 一個 `.md` 檔**，放進來就會出現在網站的「文章」列表。

> 這份 README 不會被發佈到網站上（已在 `hugo.yaml` 的 `ignoreFiles` 排除）。

---

## 方法一：用指令建立（推薦）

在 `myblog` 資料夾開終端機，執行：

```bash
hugo new content posts/my-new-post.md
```

會自動產生 `content/posts/my-new-post.md`，最上面的設定已經幫你填好。

## 方法二：手動新增

直接在這個資料夾新增一個 `.md` 檔，開頭貼上：

```markdown
---
title: "文章標題"
date: 2026-10-13
draft: true
categories: ["AI 探索"]
tags: ["Claude", "Hugo"]
summary: "一句話摘要，會顯示在文章列表"
---

從這裡開始寫內文……
```

---

## 欄位說明

| 欄位 | 說明 |
|---|---|
| `title` | 文章標題 |
| `date` | 發佈日期，格式 `YYYY-MM-DD` |
| `draft` | `true` = 草稿（只在本機預覽看得到）；**改成 `false` 才會發佈** |
| `categories` | 分類，建議用 `AI 探索` 或 `政大日常` |
| `tags` | 標籤，可以多個 |
| `summary` | 列表上顯示的摘要（不填會自動擷取開頭） |

## 檔名規則

- 用**英文小寫 + 連字號**，例如 `how-i-built-my-blog.md`
- 檔名就是網址：`content/posts/how-i-built-my-blog.md` → `/posts/how-i-built-my-blog/`
- 避免空格和中文檔名（網址會變成一長串亂碼）

## 文章要放圖片？

把文章改成資料夾，圖片放在一起：

```
content/posts/
└── how-i-built-my-blog/
    ├── index.md      ← 文章內容
    └── cover.jpg     ← 圖片
```

內文用 `![說明文字](cover.jpg)` 插入。

## 預覽

```bash
hugo server --buildDrafts
```

打開 http://localhost:1313 ，存檔後頁面會自動更新。
