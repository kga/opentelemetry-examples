package OTel;
use v5.40;
use utf8;

use OpenTelemetry;
use OpenTelemetry::SDK;
use OpenTelemetry::SDK::Exporter::Console;
use OpenTelemetry::SDK::Trace::Span::Processor::Simple;

OpenTelemetry->tracer_provider->add_span_processor(
    OpenTelemetry::SDK::Trace::Span::Processor::Simple->new(
        exporter => OpenTelemetry::SDK::Exporter::Console->new,
    ),
);

sub init {
	my $provider = OpenTelemetry->tracer_provider;
	my $tracer = $provider->tracer( name => 'my_app', version => '1.0' );
	return $tracer;
}
