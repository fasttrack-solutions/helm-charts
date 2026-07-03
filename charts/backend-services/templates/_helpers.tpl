{{/* Namespace: explicit override, else the release namespace. */}}
{{- define "crm-api.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/* min_replicas = production ? 2 : 1 */}}
{{- define "crm-api.minReplicas" -}}
{{- if eq .Values.environmentType "production" -}}2{{- else -}}1{{- end -}}
{{- end -}}

{{/* node selector workload class (var.use_ondemand_instances) */}}
{{- define "crm-api.workload" -}}
{{- if eq (toString .Values.useOndemandInstances) "true" -}}common_ondemand{{- else -}}common{{- end -}}
{{- end -}}

{{/* Export bucket name: "<brandName>-<environmentType>-data-studio-exports" */}}
{{- define "crm-api.exportBucket" -}}
{{- printf "%s-%s-data-studio-exports" .Values.brandName .Values.environmentType -}}
{{- end -}}
