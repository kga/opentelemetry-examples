use v5.40;
use feature qw(class);
no warnings qw(experimental::class);
use utf8;

class Main {
	method main {
		say "Hello, World!";
	}
}

Main->new()->main();
