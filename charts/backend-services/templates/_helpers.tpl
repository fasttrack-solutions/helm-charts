{{/* Namespace: explicit override, else the release namespace. */}}
{{- define "crm-api.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/* Export bucket name: "<brandName>-<environmentType>-data-studio-exports" */}}
{{- define "crm-api.exportBucket" -}}
{{- printf "%s-%s-data-studio-exports" .Values.brandName .Values.environmentType -}}
{{- end -}}
