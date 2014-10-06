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


=head1 SYNOPSIS

  my $small = $c->images->small;
  
=head1 DESCRIPTION

A service for images that depends on ::Origin or other ::Dest. Can be a source too, but can not be saved from upload
Inherits all objects from L<Mojolicious::Plugin::Images::Service> and implements the following new ones


=method sync ($self, $id) 

Syncronize with parent service. Returns an imager object. Writes result to disk


=method read ($self, $id) 

Reads an object and tries to syncronize it if not exists yet

=attr from

A moniker to the parent object



