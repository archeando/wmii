# ---------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <maglione.k@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.       Kris Maglione
# ---------------------------------------------------------------------------
# <phk@FreeBSD.ORG> wrote this license.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
# ---------------------------------------------------------------------------

use strict;

our $VERSION = '20091030';
our %IRSSI   = (
        authors     => 'Kris Maglione',
        contact     => 'maglione.k@gmail.com',
        name        => 'notify',
        description => 'Writes certain messages to the wmii event FIFO',
        license     => 'BEER-WARE',
        url         => '',
        changed     => $VERSION,
        modules     => '',
);

use Irssi;
use Fcntl;

open my $tty, '>', '/dev/tty';
print $tty "\033]0;irssi\007";

sub should_notify ($);

sub message_handler {
        my ($server, $mesg, $nick, $address, $target) = @_;
        my $mynick = $server->{nick};

        if (not defined $target
        or should_notify($target)
        or $mesg =~ /\b$mynick\b/) {
                $mesg =~ s/\n/\\n/g;
                $target = ($target ? " in $target" : "");

                open my $fifo, '| wmiir write /event' or return;
                print $fifo "IRCMessage from $nick$target: $mesg\n";
                close $fifo;
        }
}

sub should_notify ($) {
        my $target = shift;
        my @notifies = split /,\s*/, Irssi::settings_get_str('notify_channels');

        return 1 if grep { $_ eq "*" || $_ eq $target } @notifies;
        0;
}

Irssi::signal_add('message private', 'message_handler');
Irssi::signal_add('message public',  'message_handler');
Irssi::settings_add_str('misc', 'notify_channels', '');
