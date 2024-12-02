{{/*
Define the base name for the RabbitMQ resources.
This is used to generate resource names like Deployment, Service, etc.
*/}}
{{- define "rabbitmq.name" -}}
{{ .Release.Name }}-rabbitmq
{{- end }}

{{/*
Define the fully qualified name for RabbitMQ resources.
Useful for unique naming across namespaces.
*/}}
{{- define "rabbitmq.fullname" -}}
{{ .Release.Namespace }}-{{ include "rabbitmq.name" . }}
{{- end }}

{{/*
Define standard labels for RabbitMQ resources.
These labels help in grouping and selecting resources consistently.
*/}}
{{- define "rabbitmq.labels" -}}
app: rabbitmq
release: {{ .Release.Name }}
{{- end }}

{{/*
Define selector labels for RabbitMQ resources.
These are specifically used in Kubernetes selectors (e.g., for Deployments and Services).
*/}}
{{- define "rabbitmq.selectorLabels" -}}
app: rabbitmq
release: {{ .Release.Name }}
{{- end }}

{{/*
Define annotations for RabbitMQ resources.
These annotations can include Prometheus metrics scraping or other metadata.
*/}}
{{- define "rabbitmq.annotations" -}}
prometheus.io/scrape: "true"
prometheus.io/port: "{{ .Values.service.managementPort }}"
prometheus.io/path: "/metrics"
{{- end }}

{{/*
Define a template for a common resource prefix.
This can help standardize the naming of associated components.
*/}}
{{- define "rabbitmq.componentName" -}}
{{- printf "%s-%s" (include "rabbitmq.name" .) .Values.componentName | trunc 63 | trimSuffix "-" -}}
{{- end }}
