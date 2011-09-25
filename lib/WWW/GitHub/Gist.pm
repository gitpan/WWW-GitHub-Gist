package WWW::GitHub::Gist;
{
  $WWW::GitHub::Gist::VERSION = '0.13';
}

use strict;
use warnings;

use base qw(WWW::GitHub::Gist::v2);

=head1 NAME

WWW::GitHub::Gist - Perl interface to the GitHub's pastebin service

=head1 VERSION

version 0.13

=head1 SYNOPSIS

    use WWW::GitHub::Gist;

    # WWW::GitHub::Gist::v2 by default
    my $gist = WWW::GitHub::Gist -> new(...);

See L<WWW::GitHub::Gist::v2> for more information.

=head1 DESCRIPTION

L<WWW::GitHub::Gist> provides an object-oriented interface for Perl to the
L<gist.github.com> API. Gist is a pastebin service operated by GitHub.

You can use either the L<v2|WWW::GitHub::Gist::v2> of the API (default),
or the L<v3|WWW::GitHub::Gist::v3>.

=head1 SEE ALSO

=over 4

=item L<WWW::GitHub::Gist::v2>

=item L<WWW::GitHub::Gist::v3>

=back

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of WWW::GitHub::Gist
