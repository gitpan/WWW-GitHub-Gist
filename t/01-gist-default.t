use Test::More tests => 1;

use strict;
use WWW::GitHub::Gist;

my $gist = WWW::GitHub::Gist->new;

isa_ok($gist, 'WWW::GitHub::Gist::v2');
