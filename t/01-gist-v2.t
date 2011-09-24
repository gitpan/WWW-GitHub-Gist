use Test::More tests => 1;

use strict;
use WWW::GitHub::Gist::v2;

my $gist = WWW::GitHub::Gist::v2->new;

can_ok($gist, qw(info user file add_file create update));
