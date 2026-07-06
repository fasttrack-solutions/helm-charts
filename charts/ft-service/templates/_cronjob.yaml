{{/*
ft-service.cronjob — scheduled batch workload (broadcasting schedule job,
gamerounder cleanup, clickhouse-volume-encryptor). Reuses the same image /
configMapRef / secretRef as the Deployment. Guarded by cronjob.enabled.
NOTE: long-lived services that schedule work via an internal CRON_SCHEDULE env
stay Deployments — this is only for true Kubernetes CronJobs.
*/}}
{{- define "ft-service.cronjob" -}}
{{- $cj := (index .Values "cronjob") | default dict -}}
{{- if $cj.enabled -}}
{{- $name := include "ft-service.name" . -}}
{{- $d := (index .Values "deployment") | default dict -}}
{{- $img := $d.image | default dict -}}
{{- $repo := required "deployment.image.repository is required" $img.repository -}}
{{- $tag := $img.tag | default "" | toString -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ $name }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  schedule: {{ required "cronjob.enabled=true requires cronjob.schedule" $cj.schedule | quote }}
  suspend: {{ $cj.suspend | default false }}
  concurrencyPolicy: {{ $cj.concurrencyPolicy | default "Forbid" }}
  successfulJobsHistoryLimit: {{ $cj.successfulJobsHistoryLimit | default 3 }}
  failedJobsHistoryLimit: {{ $cj.failedJobsHistoryLimit | default 3 }}
  jobTemplate:
    spec:
      backoffLimit: {{ $cj.backoffLimit | default 0 }}
      {{- with $cj.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ . }}
      {{- end }}
      template:
        metadata:
          labels:
            app: {{ $name }}
        spec:
          restartPolicy: {{ $cj.restartPolicy | default "Never" }}
          nodeSelector:
            {{- toYaml ($cj.nodeSelector | default (dict "workload" "common_cronjobs")) | nindent 12 }}
          {{- $sa := include "ft-service.serviceAccountName" . }}
          {{- if $sa }}
          serviceAccountName: {{ $sa }}
          {{- end }}
          containers:
            - name: {{ $name }}
              image: "{{ $repo }}{{ if $tag }}:{{ $tag }}{{ end }}"
              {{- with $cj.command }}
              command:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- with $cj.args }}
              args:
                {{- toYaml . | nindent 16 }}
              {{- end }}
              envFrom:
                - configMapRef:
                    name: {{ include "ft-service.configMapRef" . }}
                {{- with $d.secretRef }}
                - secretRef:
                    name: {{ . }}
                {{- end }}
{{- end }}
{{- end -}}
