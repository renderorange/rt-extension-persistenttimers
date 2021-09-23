package RT::Extension::PersistentTimers;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-PersistentTimers - TODO

=head1 DESCRIPTION

B<NOTE>: This extension is not yet complete.

=head1 RT VERSION

Works with RT 5

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt5/etc/RT_SiteConfig.pm>

Add this line:

    Plugin('RT::Extension::PersistentTimers');

=item Clear your mason cache

    rm -rf /opt/rt5/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut

1;
