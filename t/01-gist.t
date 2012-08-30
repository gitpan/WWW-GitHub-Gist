#!perl

BEGIN {
	unless ($ENV{RELEASE_TESTING}) {
		require Test::More;
		Test::More::plan(skip_all =>
			'these tests are for release candidate testing');
	}
}

use Test::More;

use WWW::GitHub::Gist;
use Config::Identity::GitHub;

my %identity = Config::Identity::GitHub -> load;

my $gist = WWW::GitHub::Gist -> new(
	user     => $identity{'login'},
	password => $identity{'password'}
);

my $create = $gist -> create(
	public      => 0,
	description => 'some test',
	files       => {
		'test1' => 'this is the first test',
		'test2' => 'this is the second test'
	}
);

is($create -> {'description'}, 'some test');
is($create -> {'user'} -> {'login'}, 'ghedo');

my $files = $create -> {'files'};

is($files -> {'test1'} -> {'content'}, 'this is the first test');
is($files -> {'test2'} -> {'content'}, 'this is the second test');

my $edit = $gist -> edit(
	id     => $create -> {'id'},
	public => 0,
	files  => {
		'test1' => 'this is the second test',
		'test2' => 'this is the first test'
	}
);

is($create -> {'description'}, 'some test');
is($create -> {'user'} -> {'login'}, 'ghedo');

$files = $edit -> {'files'};

is($files -> {'test1'} -> {'content'}, 'this is the second test');
is($files -> {'test2'} -> {'content'}, 'this is the first test');

$gist -> delete($create -> {'id'});

my $info = WWW::GitHub::Gist -> new(id => '2783919') -> show;

is($info -> {'description'}, 'Stupid JSON prettifier');

done_testing;
