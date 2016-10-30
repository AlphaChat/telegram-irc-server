package Telegram;
use Moo;
use JSON::MaybeXS;
use Data::Dumper;

has lastID => (
  is => 'rw',
  default => sub { 0; },
  writer => 'set_lastid'
);

has token => (
  is      => 'ro',
  default => sub { $::conf->{'telegram'}->{'token'}; }
);

has waiting => (
  is => 'rw',
  default => sub { 0; },
  writer => 'set_waiting'
);

sub getUpdates {
  my $self = shift;
  return if $self->waiting;
  my $offset = $self->lastID+1;
  $::http->do_request(
    uri => URI->new("https://api.telegram.org/bot".$self->token."/getUpdates?offset=".$offset),
    on_response => sub { $self->gotUpdates(@_); }
  );
  $self->set_waiting(1);
}

sub gotUpdates {
  my ($self, $response) = @_;
  my $json = decode_json($response->content);
  #print Dumper($json);
  my @updates = @ { $json->{result} };
  foreach my $update (@updates) {
    printf("Parsing update %i...\n", $update->{'update_id'});
    $self->set_lastid($update->{'update_id'});
  }
  $self->set_waiting(0);
}

1;
