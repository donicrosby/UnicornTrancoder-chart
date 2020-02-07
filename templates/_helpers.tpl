{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "unicorn-plex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "unicorn-plex.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "unicorn-plex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "unicorn-plex.labels" -}}
helm.sh/chart: {{ include "unicorn-plex.chart" . }}
{{ include "unicorn-plex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "unicorn-plex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "unicorn-plex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "unicorn-plex.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "unicorn-plex.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "unicorn-plex.lb-url" -}}
{{- if .Values.ingress.host -}}
{{- if (.Values.ingress.tls.host) -}}
{{- if eq ( .Values.transcoding.port | int64 ) 443 -}}
{{- printf "https://%s/" .Values.ingress.tls.host -}}
{{- else -}}
{{- printf "https://%s:%s/" .Values.ingress.tls.host ( .Values.service.port | toString ) -}}
{{- end -}}
{{- else -}}
{{- if eq ( .Values.transcoding.port | int64 ) 80 -}}
{{- printf "http://%s/" .Values.ingress.host -}}
{{- else -}}
{{- printf "http://%s:%s/" .Values.ingress.host ( .Values.service.port | toString ) -}}
{{- end -}}
{{- end -}}
{{- else -}}
{{- printf "http://%s:%s/" .Values.service.loadbalancerIP ( .Values.service.port | toString ) -}}
{{- end -}}
{{- end -}}

{{- define "unicorn-plex.transcoder-url" -}}
{{- if .Values.ingress.tls.host -}}
{{- if eq ( .Values.transcoding.port | int64 ) 443 -}}
{{- printf "https://$(SERVER_HOST).%s" .Values.transcoding.transcodeDomain -}}
{{- else -}}
{{- printf "https://$(SERVER_HOST).%s:%s" .Values.transcoding.transcodeDomain ( .Values.transcoding.port | toString ) -}}
{{- end -}}
{{- else -}}
{{- if eq ( .Values.transcoding.port | int64 ) 80 -}}
{{- printf "http://$(SERVER_HOST).%s" .Values.transcoding.transcodeDomain -}}
{{- else -}}
{{- printf "http://$(SERVER_HOST).%s:%s" .Values.transcoding.transcodeDomain ( .Values.transcoding.port | toString ) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
UnicornTranscoder Loadbalancer Labels
*/}}
{{- define "unicorn-plex.loadbalancerSelectorLabels" -}}
{{ include "unicorn-plex.selectorLabels" . }}
unicorn-trancoder: loadbalancer
{{- end -}}

{{/*
UnicornTranscoder Trancoder Labels
*/}}
{{- define "unicorn-plex.transcoderSelectorLabels" -}}
{{ include "unicorn-plex.selectorLabels" . }}
unicorn-trancoder: transcoder
{{- end -}}

{{/*
UnicornTranscoder Trancoder Labels
*/}}
{{- define "unicorn-plex.transcoderControllerSelectorLabels" -}}
{{ include "unicorn-plex.selectorLabels" . }}
unicorn-trancoder: transcoder-controller
{{- end -}}

{{- define "helm-toolkit.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}


{{- define "unicorn-plex.plex-advertise-ip" -}}
{{- $lbIP := join "" ( list "http://" .Values.service.loadbalancerIP ":" ( .Values.service.localPort | default .Values.service.port ) ) -}}
{{- $advertiseIPs := ( join "," .Values.plexAdvertiseIPs ) -}}
{{- printf ( join "," ( list $lbIP $advertiseIPs ) | quote ) -}}
{{- end -}}
