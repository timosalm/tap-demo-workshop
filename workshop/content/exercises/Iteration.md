The **Supply Chain is repeatable**, so each new commit to the codebase will trigger another execution of the supply chain.

Let's enhance the number formatting of the sensor data values.

```editor:select-matching-text
file: spring-sensors-rabbit/src/main/java/org/tanzu/demo/SensorsUiController.java
text: "model.addAttribute(\"sensors\", sensorRepository.findAll());"
```

```editor:replace-text-selection
file: spring-sensors-rabbit/src/main/java/org/tanzu/demo/SensorsUiController.java
text: |
    var formattedSensorData = sensorRepository.findAll()
            .stream().map(s -> new SensorData(
                            s.getId(),
                            Math.round(s.getTemperature() * 100) / 100.0d,
                            Math.round(s.getPressure() * 100) / 100.0d
                    )
            ).collect(java.util.stream.Collectors.toList());
            model.addAttribute("sensors", formattedSensorData);
```

Now, let's commit the change to the Git repo that is being monitored by our supply chain:

```execute
git -C ~/spring-sensors-rabbit commit -a -m "Application Change"
```

```execute
git -C ~/spring-sensors-rabbit push -u origin main
```

Wait a moment, and the supply chain will kick off:
```execute
tanzu apps workload get spring-sensors
```

You will see the second build process listed for the build you triggered with your application update. The State for that build pod should show **Succeeded**.
