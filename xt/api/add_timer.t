use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../lib";

use RT::Extension::PersistentTimers::Test tests => undef;
use_ok( 'RT::Extension::PersistentTimers' );

my $user_obj = RT::User->new( RT->SystemUser );
my ( $user_id ) = $user_obj->Create(
    Name         => 'one',
    EmailAddress => 'one@example.com',
);

my $ticket_obj = RT::Ticket->new( RT->SystemUser );
my ( $ticket_id ) = $ticket_obj->Create(
    Queue   => 'General',
    Subject => 'ticket one',
);

my $timer_id = RT::Extension::PersistentTimers->AddTimer( user_id => $user_id, ticket_id => $ticket_id );
like( $timer_id, qr/^\d+$/, 'timer was added' );

my $attr = RT::Attribute->new( RT->SystemUser );
$attr->Load( $timer_id );

my $timer_content = $attr->Content;
my $timer_content_expected =
    {
        'ticket' => {
            'id' => $ticket_id,
        },
        'seconds' => '0'
    };

is_deeply( $timer_content, $timer_content_expected, 'stored content matches expected content' );

my ( $ret, $msg ) = RT::Extension::PersistentTimers->AddTimer( user_id => $user_id, ticket_id => $ticket_id );

is( $msg, "Timer for ticket $ticket_id already exists", 'adding a second timer returns error response' );

ARGS: {
    note( 'args' );

    my ( $ret, $msg ) = RT::Extension::PersistentTimers->AddTimer( ticket_id => $ticket_id );
    ok( $ret == 0 && $msg eq 'Argument user_id is required', 'missing user_id arg returns error response' );

    ( $ret, $msg ) = RT::Extension::PersistentTimers->AddTimer( user_id => $user_id );
    ok( $ret == 0 && $msg eq 'Argument ticket_id is required', 'missing ticket_id arg returns error response' );
}

done_testing();
