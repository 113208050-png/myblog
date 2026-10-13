# {{ .Title }}

{{ with .Date }}日期：{{ .Format "2006-01-02" }}　{{ end }}原文：{{ (.OutputFormats.Get "html").Permalink }}
{{ if .Params.profilePage }}{{ $p := hugo.Data.profile }}
**{{ $p.name }}**：{{ $p.tagline }}

{{ $p.bio }}

{{ with $p.experience }}## 經歷
{{ range . }}
- {{ .start }}–{{ .end }}　{{ .org }}，{{ .role }}{{ with .description }}：{{ . }}{{ end }}
{{- end }}

{{ end }}{{ with $p.education }}## 學歷
{{ range . }}
- {{ .start }}–{{ .end }}　{{ .school }} {{ .department }}{{ with .degree }}（{{ . }}）{{ end }}
{{- end }}

{{ end }}{{ with $p.skills }}## 技能

{{ range $i, $s := . }}{{ if $i }}、{{ end }}{{ $s.name }}{{ end }}

{{ end }}## 常見問題
{{ range $p.faq }}
**{{ .q }}**
{{ .a }}
{{ end }}
{{- else }}
{{ .RawContent }}
{{- end }}
