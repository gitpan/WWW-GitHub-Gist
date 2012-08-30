package WWW::GitHub::Gist::v3;
{
  $WWW::GitHub::Gist::v3::VERSION = '0.17';
}

use strict;
use warnings;

use base 'WWW::GitHub::Gist';

=head1 NAME

WWW::GitHub::Gist::v3 - (DEPRECATED) Perl interface to the GitHub's pastebin service

=head1 VERSION

version 0.17

=cut

=head1 DESCRIPTION

This module is deprecated, see L<WWW::GitHub::Gist> instead.

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no Moo;

__PACKAGE__ -> meta -> make_immutable;

1; # End of WWW::GitHub::Gist::v3
