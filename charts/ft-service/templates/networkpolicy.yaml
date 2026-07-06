{{/*
ft-service.networkpolicy — optional egress allowlist (llm-agent / llm-agent-bedrock).
egress is a passthrough rule list. Guarded by networkPolicy.enabled.
*/}}
{{- define "ft-service.networkpolicy" -}}
{{- $np := (index .Values "networkPolicy") | default dict -}}
{{- if $np.enabled -}}
{{- $name := include "ft-service.name" . -}}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ $name }}-egress
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ $name }}
spec:
  podSelector:
    matchLabels:
      app: {{ $name }}
  policyTypes:
    - Egress
  egress:
    {{- toYaml ($np.egress | default list) | nindent 4 }}
{{- end }}
{{- end -}}
