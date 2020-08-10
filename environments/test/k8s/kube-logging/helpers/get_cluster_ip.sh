#!/bin/bash

eval "$(jq -r '@sh "NAMESPACE=\(.k8s_namespace)"')"

OUTPUT_IP=$(kubectl get svc/fluentd-service -n ${NAMESPACE} -o jsonpath='{.spec.clusterIP}')
OUTPUT_IP_JSON="{\"ip\": \"${OUTPUT_IP}\"}"

echo $OUTPUT_IP_JSON
