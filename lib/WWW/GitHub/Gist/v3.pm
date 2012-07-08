package WWW::GitHub::Gist::v3;
{
  $WWW::GitHub::Gist::v3::VERSION = '0.14';
}

use Any::Moose;

use Carp;
use JSON;
use HTTP::Tiny;

use strict;
use warnings;

=head1 NAME

WWW::GitHub::Gist::v3 - Perl interface to the GitHub's pastebin service (v3)

=head1 VERSION

version 0.14

=cut

has 'api_url' => (
	isa => 'Str',
	is  => 'ro',
	default => 'https://api.github.com'
);

=head1 SYNOPSIS

    use feature 'say';
    use WWW::GitHub::Gist::v3;

    my $gist = WWW::GitHub::Gist::v3 -> new(
      id       => '1216637',
      #user     => $username,
      #password => $password
    );

    # Fetch and print information
    my $gist_info = $gist -> show;

    say $gist_info -> {'description'};
    say $gist_info -> {'user'} -> {'login'};
    say $gist_info -> {'git_pull_url'};
    say $gist_info -> {'git_push_url'};

    # Show files
    my $files = $gist_info -> {'files'};

    foreach my $file (keys %$files) {
      say $files -> {$file} -> {'filename'};
      say $files -> {$file} -> {'content'};
    }

    # Create a new gist
    my $new_gist_info = $gist -> create(
      description => $descr,
      public => 1,
      files => {'name1' => 'content', 'name2' => 'content'}
    );

=head1 DESCRIPTION

L<WWW::GitHub::Gist> provides an object-oriented interface for Perl to the
L<gist.github.com> API. Gist is a pastebin service operated by GitHub.

This module implements the interface to the version 3 of the API.

=head1 METHODS

=head2 new( )

Create a new WWW::GitHub::Gist object. Takes the following arguments:

=over 4

=item * C<id>

Gist id.

=cut

has 'id'  => (
	isa => 'Str',
	is  => 'rw',
);

=item * C<user>

GitHub username.

=cut

has 'user'  => (
	isa => 'Str',
	is  => 'rw',
);

=item * C<password>

Authenticating user's password.

=cut

has 'password'  => (
	isa => 'Str',
	is  => 'rw',
);

=back

The username and password are used for the methods that require auth. The
username is also used in the C<list()> method.

=head2 show( $gist_id )

Fetch information of the given gist. By default uses the 'id' attribute defined
in ->new.

Returns an hash ref containing the gist's information.

=cut

sub show {
	my $self = shift;
	my $gist = shift || $self -> id;

	return $self -> get_json_obj("/gists/$gist");
}

=head2 list( $user )

List all gists of the given user. By default uses the 'user' attribute defined
in ->new.

Returns a list of hash refs containing the gists' information.

=cut

sub list {
	my $self = shift;
	my $user = shift || $self -> user;

	return $self -> get_json_obj("/users/$user/gists");
}

=head2 create( %args )

Create a new gist. Takes the following arguments:

=over 4

=item * C<description>

The description for the new gist (optional).

=item * C<public>

Whether the new gist is public or not (optional, defaults to '1').

=item * C<files>

A hash reference containing the new gist's file names and contents.

=back

Returns an hash ref containing the new gist's information.

(requires authentication)

=cut

sub create {
	my $self   = shift;
	my %args   = @_;

	my $descr  = $args{'description'};
	my $public = $args{'public'} ? 1 : 0;
	my $files  = $args{'files'};

	my $data = {
		'description' => $descr,
		'public' => $public == 1 ? JSON::true : JSON::false,
		'files' => {}
	};

	while (my ($filename, $content) = each(%$files)) {
		$data -> {'files'} -> {$filename} = {'content' => $content};
	}

	return $self -> post_json_obj($data, '/gists');
}

=head2 edit( %args )

Updates a gist. Takes the following arguments:

=over 4

=item * C<id>

The id of the gist to be updated. By default uses the 'id' attribute defined
in ->new.

=item * C<description>

The updated description for the gist (optional).

=item * C<public>

Whether the new gist is public or not (optional, defaults to '1').

=item * C<files>

A hash reference containing the gist's updated file names and conttents.

=back

Returns an hash ref containing the updated gist's information.

(requires authentication)

=cut

sub edit {
	my $self   = shift;
	my %args   = @_;

	my $descr  = $args{'description'};
	my $files  = $args{'files'};
	my $public = $args{'public'} ? 1 : 0;
	my $gist   = $args{'id'} || $self -> id;

	my $data = {
		'description' => $descr,
		'public' => $public == 1 ? JSON::true : JSON::false,
		'files' => {}
	};

	while (my ($filename, $content) = each(%$files)) {
		$data -> {'files'} -> {$filename} = {
			'content' => $content,
			'filename' => $filename
		};
	}

	return $self -> patch_json_obj($data, "/gists/$gist");
}

=head2 fork( $gist_id )

Forks the given gist. By default uses the 'id' attribute defined in ->new.

Returns an hash ref containing the forked gist's information.

(requires authentication)

=cut

sub fork {
	my $self = shift;
	my $gist = shift || $self -> id;

	return $self -> post_json_obj("", "/gists/$gist/fork");
}

=head2 delete( $gist_id )

Deletes the given gist. By default uses the 'id' attribute defined in ->new.

Returns nothing.

(requires authentication)

=cut

sub delete {
	my $self = shift;
	my $gist = shift || $self -> id;

	$self -> delete_json_obj("/gists/$gist");
}

=head2 star( $gist_id )

Stars the given gist. By default uses the 'id' attribute defined in ->new.

Returns nothing.

(requires authentication)

=cut

sub star {
	my $self = shift;
	my $gist = shift || $self -> id;

	$self -> put_json_obj("/gists/$gist/star");
}

=head2 unstar( $gist_id )

Unstars the given gist. By default uses the 'id' attribute defined in ->new.

Returns nothing.

(requires authentication)

=cut

sub unstar {
	my $self = shift;
	my $gist = shift || $self -> id;

	$self -> delete_json_obj("/gists/$gist/star");
}

### PRIVATE METHODS ###

sub get_json_obj {
	my ($self, $url) = @_;

	my $req_url  = $self -> api_url.$url;

	my $response  = HTTP::Tiny -> new -> get($req_url);
	my $resp_data = from_json $response -> {'content'};
	croak $resp_data -> {'message'} unless $response -> {'status'} == 200;

	return $resp_data;
}

sub post_json_obj {
	my ($self, $data, $url) = @_;

	my $req_url  = $self -> api_url.$url;
	my $options  = {
		'content' => to_json($data),
		'headers' => $self -> basic_auth_header
	};

	my $response  = HTTP::Tiny -> new -> request('POST', $req_url, $options);
	my $resp_data = from_json $response -> {'content'};
	croak $resp_data -> {'message'} unless $response -> {'status'} == 201;

	return $resp_data;
}

sub patch_json_obj {
	my ($self, $data, $url) = @_;

	my $req_url  = $self -> api_url.$url;
	my $options  = {
		'content' => to_json($data),
		'headers' => $self -> basic_auth_header
	};

	my $response  = HTTP::Tiny -> new -> request('PATCH', $req_url, $options);
	my $resp_data = from_json $response -> {'content'};
	croak $resp_data -> {'message'} unless $response -> {'status'} == 200;

	return $resp_data;
}

sub put_json_obj {
	my ($self, $url) = @_;

	my $req_url  = $self -> api_url.$url;
	my $headers  = $self -> basic_auth_header;
	$headers -> {'Content-Length'} = 0;
	my $options  = { 'headers' => $headers };

	my $response  = HTTP::Tiny -> new -> request('PUT', $req_url, $options);

	if ($response -> {'status'} != 204) {
		my $resp_data = from_json $response -> {'content'};
		croak $resp_data -> {'message'};
	}
}

sub delete_json_obj {
	my ($self, $url) = @_;

	my $req_url  = $self -> api_url.$url;
	my $headers  = $self -> basic_auth_header;

	my $options  = { 'headers' => $self -> basic_auth_header };

	my $response  = HTTP::Tiny -> new -> request('DELETE', $req_url, $options);

	if ($response -> {'status'} != 204) {
		my $resp_data = from_json $response -> {'content'};
		croak $resp_data -> {'message'};
	}
}

sub basic_auth_header {
	require MIME::Base64;

	my $self  = shift;

	croak 'Provide valid credentials' if (!$self -> user || !$self -> password);

	my $token = MIME::Base64::encode_base64($self -> user.':'.$self -> password, '');

	return {'Authorization' => "Basic $token"};
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no Any::Moose;

__PACKAGE__ -> meta -> make_immutable;

1; # End of WWW::GitHub::Gist::v3
