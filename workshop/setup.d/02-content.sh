#!/bin/bash
set -x
set +e

cat > ci-pipeline.yaml <<EOL
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: developer-defined-tekton-pipeline
  labels:
    apps.tanzu.vmware.com/pipeline: test     # (!) required
spec:
  params:
    - name: source-url                       # (!) required
    - name: source-revision                  # (!) required
  tasks:
    - name: test
      params:
        - name: source-url
          value: \$(params.source-url)
        - name: source-revision
          value: \$(params.source-revision)
      taskSpec:
        params:
          - name: source-url
          - name: source-revision
        steps:
          - name: test
            image: maven:3-openjdk-11
            script: |-
              cd \$(mktemp -d)
              wget -qO- \$(params.source-url) | tar xvz -m
              mvn test
EOL

mkdir supply-chains
kubectl eksporter clusterconfigtemplate,clusterdeploymenttemplates,clusterimagetemplates,clusterruntemplates,clustersourcetemplates,clustersupplychains,clustertemplates > tmp-supply-chain.yaml 
kubectl slice -o supply-chains/ -f tmp-supply-chain.yaml
rm tmp-supply-chain.yaml