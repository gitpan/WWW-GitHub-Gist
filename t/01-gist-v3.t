use Test::More tests => 1;

use strict;
use WWW::GitHub::Gist::v3;

my $gist = WWW::GitHub::Gist::v3->new;

can_ok($gist, qw(show list create edit fork star unstar delete));
