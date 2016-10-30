package IRC::Protocol::Charybdis;

use Moo;

our $synced;
our %users;

my %commands = (

);

sub parseLine {
  my ($self, $data) = @_;
  print "[Server] $data\n";
  my @ex = split ' ', $data;
}

sub link {
  &::ircWrite("PASS %s TS 6 %s", $::conf->{'irc'}->{'link'}->{'password'}, $::conf->{'irc'}->{'server'}->{'sid'});
  &::ircWrite("CAPAB :QS KLN UNKLN ENCAP EX CHW IE KNOCK SAVE EUID SERVICES RSFNC MLOCK TB EOPMOD BAN");
  &::ircWrite("SERVER %s 0 :%s", $::conf->{'irc'}->{'server'}->{'name'}, $::conf->{'irc'}->{'server'}->{'description'});
  &::ircWrite("SVINFO 6 6 0 %s", time());
}

return 1;
