package Heavy::Web;
use v5.40;
use utf8;

use feature 'defer';
no warnings 'experimental::defer';

use Kossy;
use OTel;
use OpenTelemetry::Constants ();

our $tracer = OTel->init;

get '/heavy' => sub($self, $c) {
	my $span = $tracer->create_span(
		name => 'heavy-func',
		kind => OpenTelemetry::Constants::SPAN_KIND_SERVER,	
	);
	defer { $span->end };

	$c->render_json(+{ heavy => 'Hello, World!' });	
};
