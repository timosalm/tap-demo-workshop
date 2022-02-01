kapp -y deploy --app rmq-operator --file https://github.com/rabbitmq/cluster-operator/releases/download/v1.10.0/cluster-operator.yml
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: resource-claims-rmq
  labels:
    services.vmware.tanzu.com/aggregate-to-resource-claims: "true"
rules:
- apiGroups: ["rabbitmq.com"]
  resources: ["rabbitmqclusters"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: resource-claims-rmq
  labels:
    resourceclaims.services.apps.tanzu.vmware.com/controller: "true"
rules:
  - apiGroups: ["rabbitmq.com"]
    resources: ["rabbitmqclusters"]
    verbs: ["get", "list", "watch", "update"]

---
apiVersion: services.apps.tanzu.vmware.com/v1alpha1
kind: ClusterResource
metadata:
  name: rabbitmq
spec:
  shortDescription: RabbitMQ Message Broker
  resourceRef:
    group: rabbitmq.com
    kind: RabbitmqCluster
EOF