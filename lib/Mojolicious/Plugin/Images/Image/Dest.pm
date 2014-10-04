package Mojolicious::Plugin::Images::Image::Dest;
use Mojo::Base 'Mojolicious::Plugin::Images::Image';
use 5.20.0;
use experimental 'signatures';

has from => sub { die "You have to define a 'from' attribute value" };

sub sync($self, $id) {
  $self->write($id, $self->from->read($id));
}

sub read ($self, $id) {
  $self->SUPER::read($id) or $self->sync($id);
}

1;

