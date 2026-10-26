{{- define "postgres.major" -}}
{{- regexFind "^[0-9]+" (toString .) | required (printf "postgres image tag %q must start with the major version" (toString .)) -}}
{{- end }}

{{- define "postgres.volume" -}}
{{- $major := include "postgres.major" .tag | int -}}
{{- if lt $major 18 -}}
name: {{ .release }}-postgres
claim: {{ .release }}-postgres-pvc
pv: {{ .release }}-postgres-pv
label: {{ .release }}-postgres
hostPath: /mnt/raid5_mount/postgres/{{ .release }}/data
mountPath: /var/lib/postgresql/data
pgdata: /var/lib/postgresql/data
legacy: true
{{- else -}}
name: {{ .release }}-postgres-{{ $major }}
claim: {{ .release }}-postgres-{{ $major }}-pvc
pv: {{ .release }}-postgres-{{ $major }}-pv
label: {{ .release }}-postgres-{{ $major }}
hostPath: /mnt/raid5_mount/postgres/{{ .release }}/pg{{ $major }}
mountPath: /var/lib/postgresql
pgdata: /var/lib/postgresql/{{ $major }}/docker
legacy: false
{{- end }}
major: {{ $major }}
{{- end }}

{{- define "postgres.volumes" -}}
{{- $volumes := list (fromYaml (include "postgres.volume" (dict "release" .Release.Name "tag" .Values.pgDeployment.image.tag))) -}}
{{- if .Values.pgUpgrade -}}
{{- if ge (include "postgres.major" .Values.pgUpgrade.fromImage.tag | int) (include "postgres.major" .Values.pgDeployment.image.tag | int) -}}
{{- fail "pgUpgrade.fromImage must be an older major version than pgDeployment.image, remove pgUpgrade after rolling back" -}}
{{- end -}}
{{- $volumes = append $volumes (fromYaml (include "postgres.volume" (dict "release" .Release.Name "tag" .Values.pgUpgrade.fromImage.tag))) -}}
{{- end -}}
{{- toYaml (dict "items" $volumes) -}}
{{- end }}
