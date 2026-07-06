{{/*
ft-service — shared named templates (library chart).

A library chart renders nothing on its own; consuming application charts invoke
these via `{{ include "ft-service.deployment" . }}` etc. with the PARENT root
context (`.`).

IMPORTANT: a library subchart's own values.yaml does NOT merge into the
consumer's top-level `.Values`. Every default below is therefore applied INLINE.
We deliberately avoid sprig `dig` (it hard-asserts map[string]interface{} and
fails on Helm's chartutil.Values named type); we use index / dot-access / with /
hasKey, which work on any map kind via reflection and preserve value types.

The only hard requirement on a consumer is `deployment.image.repository`; the
service name defaults to the consuming chart's name (`.Chart.Name`).
*/}}

{{/* Service / workload name: deployment.name, else the consuming chart's name. */}}
{{- define "ft-service.name" -}}
{{- $d := (index .Values "deployment") | default dict -}}
{{- default .Chart.Name $d.name -}}
{{- end -}}

{{/* Render gate: local deployment.enabled (default true) AND, if
     deployment.deployFlagKey is set, global.deploymentFlags.<key>.deploy
     (default true). Returns the string "true"/"false". */}}
{{- define "ft-service.enabled" -}}
{{- $d := (index .Values "deployment") | default dict -}}
{{- $local := true -}}
{{- if hasKey $d "enabled" -}}{{- $local = $d.enabled -}}{{- end -}}
{{- $global := true -}}
{{- $flagKey := $d.deployFlagKey | default "" -}}
{{- if $flagKey -}}
{{- $g := (index .Values "global") | default dict -}}
{{- $flags := (index $g "deploymentFlags") | default dict -}}
{{- $svcFlags := (index $flags $flagKey) | default dict -}}
{{- if hasKey $svcFlags "deploy" -}}{{- $global = $svcFlags.deploy -}}{{- end -}}
{{- end -}}
{{- and $local $global -}}
{{- end -}}

{{/* ConfigMap referenced by envFrom: deployment.configMapRef, else the service name. */}}
{{- define "ft-service.configMapRef" -}}
{{- $d := (index .Values "deployment") | default dict -}}
{{- default (include "ft-service.name" .) $d.configMapRef -}}
{{- end -}}

{{/* ServiceAccount name on the pod: explicit serviceAccount.name, else the service
     name when serviceAccount.create=true, else deployment.serviceAccountName, else "". */}}
{{- define "ft-service.serviceAccountName" -}}
{{- $sa := (index .Values "serviceAccount") | default dict -}}
{{- $d := (index .Values "deployment") | default dict -}}
{{- if $sa.name -}}
{{- $sa.name -}}
{{- else if $sa.create -}}
{{- include "ft-service.name" . -}}
{{- else -}}
{{- $d.serviceAccountName | default "" -}}
{{- end -}}
{{- end -}}

{{/* IRSA role ARN: explicit serviceAccount.roleArn, else built from
     serviceAccount.roleNamePattern + global.aws.accountID + global.brandID.
     Returns "" when it cannot be built — callers must guard. */}}
{{- define "ft-service.irsaRoleArn" -}}
{{- $sa := (index .Values "serviceAccount") | default dict -}}
{{- if $sa.roleArn -}}
{{- $sa.roleArn -}}
{{- else -}}
{{- $g := (index .Values "global") | default dict -}}
{{- $aws := (index $g "aws") | default dict -}}
{{- $accountID := $aws.accountID | default "" -}}
{{- $brandID := $g.brandID | default "" -}}
{{- if and $sa.roleNamePattern $accountID -}}
{{- printf "arn:aws:iam::%s:role/%s" (toString $accountID) (printf $sa.roleNamePattern (toString $brandID)) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* initContainer list ITEMS (no `initContainers:` key). dbInit convenience +
     deployment.initContainers passthrough. */}}
{{- define "ft-service.initContainers" -}}
{{- $db := (index .Values "dbInit") | default dict -}}
{{- if $db.enabled }}
- name: {{ include "ft-service.name" . }}-db-init
  image: {{ $db.image | default "745106446559.dkr.ecr.eu-west-1.amazonaws.com/db-init:latest" }}
  imagePullPolicy: Always
  {{- with $db.secretRef }}
  envFrom:
    - secretRef:
        name: {{ . }}
  {{- end }}
  {{- with $db.env }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- $d := (index .Values "deployment") | default dict -}}
{{- with $d.initContainers }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/* volumeMount list ITEMS. analyticsConfig convenience + deployment.volumeMounts. */}}
{{- define "ft-service.volumeMounts" -}}
{{- $ac := (index .Values "analyticsConfig") | default dict -}}
{{- if $ac.enabled }}
- name: analytics-central-config
  mountPath: /app/config.json
  subPath: config.json
  readOnly: true
- name: analytics-central-config-patch
  mountPath: /app/patch.json
  subPath: patch.json
  readOnly: true
{{- end }}
{{- $d := (index .Values "deployment") | default dict -}}
{{- with $d.volumeMounts }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/* volume list ITEMS. analyticsConfig convenience + deployment.volumes. */}}
{{- define "ft-service.volumes" -}}
{{- $ac := (index .Values "analyticsConfig") | default dict -}}
{{- if $ac.enabled }}
- name: analytics-central-config
  configMap:
    name: analytics-central-config
    defaultMode: 0444
- name: analytics-central-config-patch
  configMap:
    name: analytics-central-config-patch
    defaultMode: 0444
{{- end }}
{{- $d := (index .Values "deployment") | default dict -}}
{{- with $d.volumes }}
{{- toYaml . }}
{{- end }}
{{- end -}}
