#!/usr/bin/env perl

use strictures 2;

# Third party stuff
use IO::Async;
use IO::Async::Loop;
use Text::ZPL;
use Net::Async::HTTP;
use IO::Async::Stream;
use IO::Socket::IP;
use Data::Dumper;

our ($loop, $conf, $http, $ircSocket, $ircStream, $proto);

readConfig();
setupLoop();
setupIRC();

sub setupLoop {
  $loop = IO::Async::Loop->new;
  $http = Net::Async::HTTP->new;
}

sub setupIRC {
  my $protoName = ucfirst(lc($conf->{'irc'}->{'link'}->{'proto'}));
  $proto = eval {
    require '../lib/IRC/Protocol/'.$protoName.'.pm';
    ('IRC::Protocol::'.$protoName)->new;
  };
  die("Couldn't find $protoName protocol.") if !$proto;
  $ircSocket = IO::Socket::IP->new(
    Proto    => "tcp",
    PeerHost => $conf->{'irc'}->{'link'}->{'host'},
    PeerPort => $conf->{'irc'}->{'link'}->{'port'},
    Timeout  => 10
  ) or die("Couldn't connect to IRC: $!");
  $ircStream = IO::Async::Stream->new(
    handle => $ircSocket,
    on_read => sub {
      my (undef, $buffref, $eof) = @_;
      while ($$buffref =~ s/^(.*)\n//) {
        $proto->parseLine($1);
      }
    }
  );
  $loop->add($ircStream);
  $proto->link();
}

sub readConfig {
  local $/ = undef;
  open CONF, "../etc/service.conf" or die "Couldn't open config: $!";
  binmode CONF;
  my $txt = <CONF>;
  close CONF;
  $conf = decode_zpl($txt);
}

sub ircWrite {
  my $data = shift;
  my $toWrite = sprintf($data."\r\n", @_);
  print "[Me] $toWrite";
  $ircStream->write($toWrite);
}

# Run the loop
$loop->run;
