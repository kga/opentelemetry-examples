import time
from flask import Flask
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.trace import StatusCode
from opentelemetry.semconv.resource import ResourceAttributes

app = Flask(__name__)

def init_tracer():
	resource = Resource(attributes={
		ResourceAttributes.SERVICE_NAME: "sample-service",
		ResourceAttributes.DEPLOYMENT_ENVIRONMENT: "development",
		ResourceAttributes.SERVICE_NAMESPACE: "sample-namespace"
	})

	exporter = OTLPSpanExporter()

	provider = TracerProvider(resource=resource)
	processor = BatchSpanProcessor(exporter)
	provider.add_span_processor(processor)
	trace.set_tracer_provider(provider)

init_tracer()
tracer = trace.get_tracer(__name__)

def super_heavy_func(n):
	with tracer.start_as_current_span(f"Heavy func {n}") as span:
		time.sleep(n)
		if n > 5:
			msg = "timeout!"
			span.record_exception(Exception(msg))
			span.set_status(StatusCode.ERROR, msg)

@app.route("/heavy")
def heavy():
	time.sleep(2)
	super_heavy_func(8)
	super_heavy_func(3)
	super_heavy_func(5)
	return "This is heavy endpoint"

FlaskInstrumentor().instrument_app(app)

if __name__ == "__main__":
	app.run(port=8080)
