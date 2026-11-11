{{/*
Expand the name of the chart.
*/}}
{{- define "boldreports.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "boldreports.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "boldreports.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "boldreports.labels" -}}
helm.sh/chart: {{ include "boldreports.chart" . }}
{{ include "boldreports.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "boldreports.selectorLabels" -}}
app.kubernetes.io/name: {{ include "boldreports.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "boldreports.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "boldreports.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "boldreports.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "boldreports.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "boldreports.kubeVersion" .))) -}}
{{- end -}}
{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "boldreports.kubeVersion" .))) -}}
{{- end -}}

{{/*
Define the boldreports.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "boldreports.namespace" -}}
{{- if eq .Release.Namespace "default" -}}
{{ printf "namespace: %s" .Values.namespace }}
{{- else -}}
{{ printf "namespace: %s" .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
Define the boldreports.notes template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "boldreports.notes-pods" -}}
{{- if eq .Release.Namespace "default" -}}
{{ printf "$ kubectl get pods -n %s" .Values.namespace }}
{{- else -}}
{{ printf "$ kubectl get pods -n %s" .Release.Namespace }}
{{- end -}}
{{- end -}}

{{- define "boldreports.notes-hpa" -}}
{{- if eq .Release.Namespace "default" -}}
{{ printf "$ kubectl get hpa -n %s" .Values.namespace }}
{{- else -}}
{{ printf "$ kubectl get hpa -n %s" .Release.Namespace }}
{{- end -}}
{{- end -}}
{{/*
Service port for a Bold service (matches templates/service.yaml).
*/}}
{{- define "boldreports.servicePort" -}}
{{- $ports := dict "id-web" 6000 "id-api" 6001 "id-ums" 6002 "reports-web" 6550 "reports-api" 6551 "reports-jobs" 6552 "reports-reportservice" 6553 "reports-viewer" 6554 "reports-ai" 6555 "reports-mcp" 6556 "bold-etl" 6009 -}}
{{- get $ports . -}}
{{- end -}}

{{/*
ServiceAccount name for the Bold service pods. Empty when neither serviceAccount.create nor
serviceAccount.name is set, so pods keep using the namespace's default ServiceAccount.
*/}}
{{- define "boldreports.podServiceAccountName" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- if $sa.create -}}
{{- $sa.name | default "bold-reports" -}}
{{- else if $sa.name -}}
{{- $sa.name -}}
{{- end -}}
{{- end -}}

{{/*
Render a map as YAML with every value converted to a string. Labels, annotations and
nodeSelector values must be strings; unquoted values like `true` or `1234` are rejected by the API.
*/}}
{{- define "boldreports.stringMap" -}}
{{- $out := dict -}}
{{- range $k, $v := . -}}
{{- $_ := set $out $k (ternary "" (toString $v) (kindIs "invalid" $v)) -}}
{{- end -}}
{{- toYaml $out -}}
{{- end -}}

{{/*
Render a list of EnvVar entries, converting `value` to a string (e.g. `value: 0` -> "0").
Entries using valueFrom are rendered unchanged.
*/}}
{{- define "boldreports.envList" -}}
{{- $out := list -}}
{{- range . -}}
{{- $e := deepCopy . -}}
{{- if hasKey $e "value" -}}
{{- $_ := set $e "value" (ternary "" (toString $e.value) (kindIs "invalid" $e.value)) -}}
{{- end -}}
{{- $out = append $out $e -}}
{{- end -}}
{{- toYaml $out -}}
{{- end -}}
