use v5.40;
use utf8;

use FindBin;
use lib "$FindBin::Bin/lib";

use Heavy::Web;

warn $ENV{OTEL_SERVICE_NAME};
warn $ENV{EXPORTER_OTLP_ENDPOINT};

Heavy::Web->psgi;
