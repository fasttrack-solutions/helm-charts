{{/*
ft-service.extraManifests — last-resort escape hatch for irreducible per-service
objects (per-domain Services, Traefik IngressRoute, bespoke RBAC Role/RoleBinding).
Each list item is rendered verbatim. Use sparingly.
*/}}
{{- define "ft-service.extraManifests" -}}
{{- range (index .Values "extraManifests") | default list }}
---
{{ toYaml . }}
{{- end }}
{{- end -}}
