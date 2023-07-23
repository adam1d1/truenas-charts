{{- define "joomla.workload" -}}
workload:
  joomla:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        joomla:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 33
            capabilities:
              add:
                - NET_BIND_SERVICE
          envFrom:
            - secretRef:
                name: joomla-creds
          {{ with .Values.wpConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: 80
            readiness:
              enabled: true
              type: tcp
              port: 80
            startup:
              enabled: true
              type: tcp
              port: 80
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 33
                                                        "GID" 33
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
{{/* Service */}}
service:
  joomla:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: joomla
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.jmNetwork.webPort }}
        nodePort: {{ .Values.jmNetwork.webPort }}
        targetPort: 80
        targetSelector: joomla

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.wpStorage.data.type }}
    datasetName: {{ .Values.wpStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.wpStorage.data.hostPath | default "" }}
    targetSelector:
      joomla:
        joomla:
          mountPath: /var/www/html
        01-permissions:
          mountPath: /mnt/directories/data
  {{- range $idx, $storage := .Values.wpStorage.additionalStorages }}
  {{ printf "wp-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      joomla:
        joomla:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      joomla:
        joomla:
          mountPath: /tmp
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      joomla:
        joomla:
          mountPath: /var/run
{{- end -}}
