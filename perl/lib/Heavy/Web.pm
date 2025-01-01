package Heavy::Web;
use v5.40;
use utf8;

use Kossy;
use Time::HiRes ();

use OTel;
use OpenTelemetry::Constants ();

our $tracer = OTel->init;

# 引数で与えられた秒数だけスリープする関数
sub superHeavyFunc($tracer, $n) {
	$tracer->in_span(
		"Heavy func $n" => sub ($span, $ctx) {
			Time::HiRes::sleep($n);

			if ($n > 5) {
				my $msg = 'timeout!';
				$span->record_exception($msg);
				$span->set_status(OpenTelemetry::Constants::SPAN_STATUS_ERROR, $msg);
			}
		},
	)
}

get '/heavy' => sub($self, $c) {
	$tracer->in_span(
		'heavy-func' => (
			kind => OpenTelemetry::Constants::SPAN_KIND_SERVER,
		) => sub ($span, $ctx) {
			Time::HiRes::sleep(2);

			superHeavyFunc($tracer, 8);
			superHeavyFunc($tracer, 3);
			superHeavyFunc($tracer, 5);

			$c->render_json(+{ heavy => 'Hello, World!' });	
		},
	);
};
