Use the **Tanzu CLI** to verify the workloads are deployed and running. 
```execute
tanzu apps workload list
```

Once the status shows **Ready**, let's see how to access our application.
```execute
tanzu apps workload get spring-sensors
```

We can also use the **Tanzu Application Platform GUI** to get more information about his deployed workloads ...
```dashboard:open-url
name: Live
url: https://tap-gui.{{ ENV_TAP_INGRESS }}
```

... and we can leverage Tanzu's powerful App Live View dashboard to verify ongoing operations.
```dashboard:open-url
url: https://tap-gui.{{ ENV_TAP_INGRESS }}/app-live-view/apps/spring-sensors
```
