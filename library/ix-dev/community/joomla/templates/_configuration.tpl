{{- define "joomla.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "joomla" -}}
  {{- $dbName := "joomla" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- $dbRootPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-mariadb-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "MARIADB_PASSWORD") | b64dec) -}}
    {{- $dbRootPass = ((index .data "MARIADB_ROOT_PASSWORD") | b64dec) -}}
  {{- end }}

secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
      MARIADB_HOST: {{ $dbHost }}

  joomla-creds:
    enabled: true
    data:
      JOOMLA_DB_HOST: {{ $dbHost }}
      JOOMLA_DB_NAME: {{ $dbName }}
      JOOMLA_DB_USER: {{ $dbUser }}
      JOOMLA_DB_PASSWORD: {{ $dbPass }}
{{- end -}}
