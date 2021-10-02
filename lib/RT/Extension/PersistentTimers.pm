package RT::Extension::PersistentTimers;

use strict;
use warnings;

require RT::User;
require RT::Ticket;
require RT::Attribute;

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

=head1 METHODS

=head2 GetTimers

Get timers for a given user id.

 my ( $ret, $msg ) = RT::Extension::PersistentTimers->GetTimers( user_id => $user_id );

=head3 ARGUMENTS

=over

=item user_id (required)

The user id to get timer attribute objects for.

=back

=head3 RETURNS

On success, an arrayref of timer hashrefs.

On failure, a list of 2 members; C<undef> and the failure message.

=cut

sub GetTimers {
    my $self = shift;
    my $arg  = {
        user_id => undef,
        @_,
    };

    unless ( defined $arg->{user_id} ) {
        return ( 0, 'Argument user_id is required' );
    }

    my $user_obj = RT::User->new( RT->SystemUser );
    $user_obj->Load( $arg->{user_id} );

    my $timers = [];
    foreach my $timer_obj ( $user_obj->Attributes->Named( 'Timer' ) ) {
        my $content = $timer_obj->Content();

        my $ticket_obj = RT::Ticket->new( $user_obj );
        my ( $ret, $msg ) = $ticket_obj->Load( $content->{ticket}{id} );
        unless ( $ret ) {
            return ( $ret, $msg );
        }

        my $timer = $content;
        $timer->{id} = $timer_obj->id;
        $timer->{ticket}{subject} = $ticket_obj->Subject;
        $timer->{ticket}{owner}   = $ticket_obj->OwnerObj->Name;
        $timer->{ticket}{link}    = RT->Config->Get( 'WebPath' ) .
                                    '/Ticket/Display.html?id=' . $ticket_obj->Id;
        push @{$timers}, $timer;
    }

    return $timers;
}

=head2 AddTimer

Add a timer attribute object for a given user id.

 my ( $ret, $msg ) = RT::Extension::PersistentTimers->AddTimer( user_id => $user_id, ticket_id => $ticket_id );

=head3 ARGUMENTS

=over

=item user_id (required)

The user id to add the timer attribute for.

=item ticket_id (required)

The ticket id to add the timer for.

=back

=head3 RETURNS

On success, the id of the new timer attribute.

On failure, a list of 2 members; C<undef> and the failure message.

=cut

sub AddTimer {
    my $self = shift;
    my $arg  = {
        user_id   => undef,
        ticket_id => undef,
        @_,
    };

    foreach my $required ( keys %{$arg} ) {
        unless ( defined $arg->{$required} ) {
            return ( 0, "Argument $required is required" );
        }
    }

    my $user_obj = RT::User->new( RT->SystemUser );
    $user_obj->Load( $arg->{user_id} );

    foreach my $timer ( @{ $self->GetTimers( user_id => $arg->{user_id} ) } ) {
        if ( $timer->{ticket}{id} == $arg->{ticket_id} ) {
            return ( 0, 'Timer for ticket ' . $arg->{ticket_id} . ' already exists' );
        }
    }

    my $ticket_obj = RT::Ticket->new( $user_obj );
    my ( $ret, $msg ) = $ticket_obj->Load( $arg->{ticket_id} );
    unless ( $ret ) {
        return ( $ret, $msg );
    }

    # TODO:
    # check if current user has ModifyTicket for this ticket
    # Permission Denied: unable to ModifyTicket

    my $attr = RT::Attribute->new( $user_obj );

    return $attr->Create(
        Name        => 'Timer',
        Description => 'Ticket timer',
        Content     => {
            ticket  => {
                id => $arg->{ticket_id},
            },
            seconds => '0',
        },
        Object => $user_obj,
    );
}

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut

1;
