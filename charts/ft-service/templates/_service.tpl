{{/*
ft-service.service — ClusterIP Service. Guarded by service.enabled (default true).
Supports a multi-port list (service.ports) and back-compat single port (service.port).
Legacy Ambassador Mappings flow through verbatim as service.annotations.
*/}}
{{- define "ft-service.service" -}}
{{- $svc := (index .Values "service") | default dict -}}
{{- $enabled := true }}{{- if hasKey $svc "enabled" }}{{- $enabled = $svc.enabled }}{{- end -}}
{{- if $enabled -}}
{{- $name := include "ft-service.name" . -}}
{{- $ports := $svc.ports | default list -}}
{{- if and (not $ports) $svc.port -}}{{- $ports = list $svc.port -}}{{- end -}}
{{- if not $ports -}}{{- $ports = list (dict "name" "http" "port" 80 "targetPort" 3000) -}}{{- end -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ default $name $svc.name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ $name }}
  annotations:
    argocd.argoproj.io/sync-wave: {{ $svc.syncWave | default "1" | quote }}
    {{- with $svc.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  type: {{ $svc.type | default "ClusterIP" }}
  selector:
    app: {{ $name }}
  ports:
    {{- range $ports }}
    - name: {{ .name | default "http" }}
      port: {{ .port }}
      targetPort: {{ .targetPort | default .port }}
      protocol: {{ .protocol | default "TCP" }}
    {{- end }}
{{- end }}
{{- end -}}
