require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/rack'
require 'rack'
require 'rackup'
require 'net/http'
require 'json'

def init_tracer_provider
	exporter = OpenTelemetry::Exporter::OTLP::Exporter.new

	# (d) リソース情報の設定
	resource = OpenTelemetry::SDK::Resources::Resource.create(
		OpenTelemetry::SemanticConventions::Resource::DEPLOYMENT_ENVIRONMENT => 'development',
		OpenTelemetry::SemanticConventions::Resource::HOST_NAME => Socket.gethostname,
		OpenTelemetry::SemanticConventions::Resource::SERVICE_NAMESPACE => 'sample-namespace',
	)

	# (c) トレーサープロバイダーの初期化
	OpenTelemetry::SDK.configure do |c|
		c.service_name = 'sample-service'
		c.service_version = '0.0.1'
		c.resource = resource
		c.add_span_processor(
			OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(exporter)
		)
		c.use_all
	end
end

def super_heavy_func(context, tracer, n)
	# (B) superHeavyFunc のスパンを作成
	span = tracer.start_span("Heavy func #{n}", with_parent: context)
	OpenTelemetry::Trace.with_span(span) do
		sleep(n)

		# (C) 5秒より処理に時間がかかったらエラーとする
		if n > 5
			msg = 'timeout!'
			span.record_exception(StandardError.new(msg))
			span.status = OpenTelemetry::Trace::Status.error(msg)
		end
	end
	span.finish
end

init_tracer_provider
tracer = OpenTelemetry.tracer_provider.tracer('main')

# (1) /heavy エンドポイントの定義
app = Rack::Builder.new do
	use OpenTelemetry::Instrumentation::Rack::Middlewares::TracerMiddleware

	run lambda { |env|
		req = Rack::Request.new(env)
		res = Rack::Response.new

		if req.path == '/heavy'
			# (2) 2秒間スリープ
			sleep(2)

			# (3) 重い処理をする関数を3回呼び出す
			super_heavy_func(env['rack.span'], tracer, 8)
			super_heavy_func(env['rack.span'], tracer, 3)
			super_heavy_func(env['rack.span'], tracer, 5)

			# (4) テキストでレスポンスを返す
			res.write('This is heavy endpoint')
		else
			res.status = 404
			res.write('Not Found')
		end

		res.finish
	}
end

handler = Rackup::Handler.default
handler.run(app, Port: 8088)
