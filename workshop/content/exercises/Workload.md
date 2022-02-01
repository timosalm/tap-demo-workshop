**TAP provides an abstraction for developers called workloads**. Workloads allow developers to create application specifications such as the location of their repository, environment variables and service claims.

- **Choose** the **Spring Sensors** card from the user interface
- Click on the **Explore** button towards the bottom of the page
- Let's now view and explain the **config/workload.yaml** file

For this demo, we'll use the Tanzu command line interface instead of the Web UI to download the Spring Sensors application accelerator.
```execute
tanzu accelerator generate spring-sensors-rabbit --server-url https://accelerator.{{ ENV_TAP_INGRESS }} --options='{"gitUrl": "'{{ ENV_GIT_REPO }}'","gitBranch":"main"}'
```

Unzip the repo into your local file system:
```execute
unzip -o spring-sensors-rabbit.zip
```

Commit the configured application to Git, where it can be picked up by Tanzu Application Platform's Supply Chain Choreographer.
```execute
git -C ~/spring-sensors-rabbit init
git -C ~/spring-sensors-rabbit add ~/spring-sensors-rabbit/
git -C ~/spring-sensors-rabbit commit -a -m "Initial Commit of Spring Sensors"
```

```execute
git -C ~/spring-sensors-rabbit branch -M main
git -C ~/spring-sensors-rabbit remote add origin {{ ENV_GIT_REPO }}
git -C ~/spring-sensors-rabbit config credential.helper '!f() { sleep 1; echo "username=${GIT_USER}"; echo "password=${GIT_PASSWORD}"; }; f'
git -C ~/spring-sensors-rabbit push -u origin main
```

Create the CI pipeline
```execute
kubectl apply -f ci-pipeline.yaml
```

```editor:select-matching-text
file: spring-sensors-rabbit/config/workload.yaml
text: "apps.tanzu.vmware.com/workload-type: web"
```
```editor:replace-text-selection
file: spring-sensors-rabbit/config/workload.yaml
text: |
    apps.tanzu.vmware.com/workload-type: web
        apps.tanzu.vmware.com/has-tests: "true"
```
```editor:select-matching-text
file: spring-sensors-rabbit/config/workload.yaml
text: "source:"
```
```editor:replace-text-selection
file: spring-sensors-rabbit/config/workload.yaml
text: |
    serviceAccountName: {{ session_namespace }}-default
      source:
```

Executes the *workload create* command to publish the new application. 
```execute
tanzu apps workload create spring-sensors -f spring-sensors-rabbit/config/workload.yaml -y
```

We'll start streaming the logs that show what Tanzu Application Platform does next:
```execute-2
tanzu apps workload tail spring-sensors --since 1h
```
