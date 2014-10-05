package Mojolicious::Plugin::Images::Service::Dest;
use Mojo::Base 'Mojolicious::Plugin::Images::Service';
use 5.20.0;
use experimental 'signatures';

has from => sub { die "You have to define a 'from' attribute value" };

sub sync($self, $id) {
  my $from = $self->controller->images->${\$self->from};
  $self->write($id, $from->read($id));
}

sub read ($self, $id) {
  $self->SUPER::read($id) or $self->sync($id);
}

1;
