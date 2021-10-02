use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../lib";

use RT::Extension::PersistentTimers::Test tests => undef;
use_ok( 'RT::Extension::PersistentTimers' );

my $user_one_obj = RT::User->new( RT->SystemUser );
my ( $user_one_id ) = $user_one_obj->Create(
    Name         => 'one',
    EmailAddress => 'one@example.com',
);

my $subject = 'ticket one';
my $ticket_obj = RT::Ticket->new( RT->SystemUser );
my ( $ticket_id ) = $ticket_obj->Create(
    Queue   => 'General',
    Subject => $subject,
);

my $user_two_obj = RT::User->new( RT->SystemUser );
my ( $user_two_id ) = $user_two_obj->Create(
    Name         => 'two',
    EmailAddress => 'two@example.com',
);

my $timer_one_id = RT::Extension::PersistentTimers->AddTimer( user_id => $user_one_id, ticket_id => $ticket_id );
my $timer_two_id = RT::Extension::PersistentTimers->AddTimer( user_id => $user_two_id, ticket_id => $ticket_id );
my $timers = RT::Extension::PersistentTimers->GetTimers( user_id => $user_one_id );

is( scalar @{$timers}, 1, 'only user one timers are returned for user one' );

my $timer = $timers->[0];
my $timer_expected =
    {
        'id' => $timer_one_id,
        'ticket' => {
            'owner' => 'Nobody',
            'id' => $ticket_id,
            'link' => '/Ticket/Display.html?id=' . $ticket_id,
            'subject' => $subject,
        },
        'seconds' => '0'
    };

is_deeply( $timer, $timer_expected, 'content from GetTimers matches expected content' );

ARGS: {
    note( 'args' );

    my ( $ret, $msg ) = RT::Extension::PersistentTimers->GetTimers();
    ok( $ret == 0 && $msg eq 'Argument user_id is required', 'missing user_id arg returns error response' );
}

done_testing();
