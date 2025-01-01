use v5.40;
use utf8;

use FindBin;
use lib "$FindBin::Bin/lib";

use Heavy::Web;

Heavy::Web->psgi;
