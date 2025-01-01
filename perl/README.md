```sh
carmel
OTEL_SERVICE_NAME=sample-service EXPORTER_OTLP_ENDPOINT=http://localhost:4317 carmel exec -- plackup --port 8181 app.psgi
```

![otel-tui](./otel-tui.png)
