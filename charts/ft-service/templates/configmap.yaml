{{/*
ft-service.configmap — flat literal-env ConfigMap (the ai-soc style).
Use this when a service's env is plain key/value pairs (optionally containing
ArgoCD-Vault `<path:...>` placeholders, which pass through verbatim).

NOTE: services whose ConfigMap VALUES are assembled in-template from
`global.envSettings.*` (dig/printf/default — usage-metrics-api, llm-mcp,
llm-agent, pii-encryptor) keep their OWN templates/configmap.yaml stub and do
NOT call this include. That per-env wiring is genuinely service-specific; the
shared chart deliberately does not try to genericize it. Guarded by
configMap.enabled (default true).
*/}}
{{- define "ft-service.configmap" -}}
{{- $cm := (index .Values "configMap") | default dict -}}
{{- $enabled := true }}{{- if hasKey $cm "enabled" }}{{- $enabled = $cm.enabled }}{{- end -}}
{{- if $enabled -}}
{{- $name := default (include "ft-service.name" .) $cm.name -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ $name }}
  annotations:
    reloader.stakater.com/auto: "true"
    argocd.argoproj.io/sync-wave: "-1"
data:
  {{- range $k, $v := ($cm.data | default dict) }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
{{- end }}
{{- end -}}
