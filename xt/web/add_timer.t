use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../lib";

use RT::Extension::PersistentTimers::Test tests => undef;
use_ok( 'RT::Extension::PersistentTimers' );

my $subject = 'ticket one';
my $ticket_obj = RT::Ticket->new( RT->SystemUser );
my ( $ticket_id ) = $ticket_obj->Create(
    Queue   => 'General',
    Subject => $subject,
);

my ( $baseurl, $m ) = RT::Test->started_ok;
ok $m->login, 'logged in as root';

$m->follow_link_ok( { id => 'tools-timers', url_regex => qr|/Tools/Timers\.html$| },
                     'followed tools/timers link to /Tools/Timers.html' );
$m->submit_form_ok( {
    form_name => 'add_timer',
    fields => {
        ticket_id => $ticket_id,
    },
}, 'submitted form to add timer' );

$m->content_contains( 'Timer for ticket ' . $ticket_id . ' added', 'success message was displayed' );
$m->content_contains( '#' . $ticket_id . ': ' . $subject, 'ticket is displayed in table' );

done_testing();
