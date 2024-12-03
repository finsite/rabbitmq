
# RabbitMQ Helm Chart Testing Guide

This guide provides a comprehensive set of procedures to test the RabbitMQ Helm chart, ensuring functionality across different configurations and scenarios.

---

## 1. Pre-Deployment Tests

### 1.1 Lint the Chart

Validate the structure and syntax of the Helm chart:

```bash
helm lint .
```

Ensure there are no errors or warnings.

### 1.2 Dry Run

Render the templates without applying them to the cluster:

```bash
helm template rabbitmq . --namespace rabbitmq --debug
```

Review the generated manifests to ensure correctness.

### 1.3 Cluster Readiness

Confirm that your Kubernetes cluster is ready:

```bash
kubectl get nodes
```

Ensure all nodes are in the `Ready` state.

---

## 2. Basic Deployment

### 2.1 Install the Chart

Deploy RabbitMQ with the default values:

```bash
helm install rabbitmq . --namespace rabbitmq --create-namespace
```

### 2.2 Verify Resources

Check if the required resources are created:

```bash
kubectl get all -n rabbitmq
```

### 2.3 Check Pod Status

Ensure all RabbitMQ pods are running:

```bash
kubectl get pods -n rabbitmq
```

### 2.4 Access Logs

Inspect logs to verify that RabbitMQ started successfully:

```bash
kubectl logs -l app=rabbitmq -n rabbitmq
```

### 2.5 Check Service Endpoints

Confirm that RabbitMQ is exposed correctly:

```bash
kubectl get svc -n rabbitmq
```

---

## 3. Configuration-Specific Tests

### 3.1 TLS

1. Enable TLS in `values.yaml`:

   ```yaml
   tls:
     enabled: true
     certSecretName: rabbitmq-tls
   ```

2. Deploy the chart:

   ```bash
   helm upgrade --install rabbitmq . --namespace rabbitmq
   ```

3. Verify the TLS configuration:
   - Check the mounted certificates in the RabbitMQ pod:

     ```bash
     kubectl exec -it <pod-name> -n rabbitmq -- ls /etc/rabbitmq/tls
     ```

   - Attempt a secure connection using a RabbitMQ client.

### 3.2 Horizontal Pod Autoscaler (HPA)

1. Enable HPA in `values.yaml`:

   ```yaml
   hpa:
     enabled: true
     minReplicas: 3
     maxReplicas: 10
     targetCPUUtilizationPercentage: 80
   ```

2. Apply the chart:

   ```bash
   helm upgrade --install rabbitmq . --namespace rabbitmq
   ```

3. Simulate CPU load:
   Use a load generator (e.g., `stress`) to increase RabbitMQ pod CPU usage.
4. Verify scaling behavior:

   ```bash
   kubectl get hpa -n rabbitmq
   kubectl get pods -n rabbitmq
   ```

### 3.3 Ingress

1. Enable ingress in `values.yaml`:

   ```yaml
   ingress:
     enabled: true
     className: "nginx"
     annotations:
       nginx.ingress.kubernetes.io/rewrite-target: /
     hosts:
       - host: rabbitmq.example.com
     tls:
       - secretName: rabbitmq-tls-secret
         hosts:
           - rabbitmq.example.com
   ```

2. Deploy the chart:

   ```bash
   helm upgrade --install rabbitmq . --namespace rabbitmq
   ```

3. Test ingress connectivity:
   - Resolve the domain (e.g., `rabbitmq.example.com`) to the ingress controller IP.
   - Use a browser or `curl` to access the RabbitMQ management interface:

     ```bash
     curl -k https://rabbitmq.example.com
     ```

### 3.4 Persistent Volume

1. Confirm the volume is correctly mounted:

   ```bash
   kubectl exec -it <pod-name> -n rabbitmq -- df -h
   ```

2. Simulate a pod restart:

   ```bash
   kubectl delete pod <pod-name> -n rabbitmq
   ```

3. Verify that data persists after the pod restarts.

---

## 4. Functional Tests

### 4.1 Default User Authentication

1. Retrieve default user credentials stored in the `rabbitmq-default-user` secret:

   ```bash
   kubectl get secret rabbitmq-default-user -n rabbitmq -o jsonpath="{.data.username}" | base64 --decode
   kubectl get secret rabbitmq-default-user -n rabbitmq -o jsonpath="{.data.password}" | base64 --decode
   ```

2. Use the RabbitMQ Management UI or `rabbitmqadmin` CLI to log in.

### 4.2 Message Queueing

1. Publish and consume messages to verify RabbitMQ functionality:

   ```bash
   kubectl exec -it <pod-name> -n rabbitmq -- rabbitmqctl add_queue test-queue
   kubectl exec -it <pod-name> -n rabbitmq -- rabbitmqctl list_queues
   ```

### 4.3 Cluster Tests (If using a cluster)

1. Verify node health:

   ```bash
   kubectl exec -it <pod-name> -n rabbitmq -- rabbitmqctl cluster_status
   ```

---

## 5. Post-Deployment Tests

### 5.1 Helm Test

If your chart includes Helm tests, run:

```bash
helm test rabbitmq --namespace rabbitmq
```

### 5.2 Cleanup

Remove the resources to confirm that deletion works as expected:

```bash
helm uninstall rabbitmq --namespace rabbitmq
kubectl delete namespace rabbitmq
```

---

## 6. CI/CD Integration

Automate testing using a CI/CD pipeline:

- Use tools like GitHub Actions, GitLab CI, or Jenkins.
- Automate steps like:
  - `helm lint`
  - `helm template`
  - Deploy the chart to a test cluster.
  - Run functional tests (e.g., using RabbitMQ CLI or custom scripts).

---

## Summary of Testing Areas

| **Test Area**          | **Steps**                                                                 |
|-------------------------|---------------------------------------------------------------------------|
| Pre-Deployment         | Lint, dry-run, cluster readiness                                          |
| Basic Deployment       | Resource creation, pod status, service endpoints                         |
| TLS                    | Enable TLS, test secure connectivity                                     |
| HPA                    | Simulate load and observe scaling                                        |
| Ingress                | Enable ingress, test connectivity                                        |
| Persistent Volume      | Verify data persistence after pod restarts                               |
| Functional             | Authentication, queue creation, and cluster health                      |
| Post-Deployment        | Helm test, cleanup                                                       |
