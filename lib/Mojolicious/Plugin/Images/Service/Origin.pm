package Mojolicious::Plugin::Images::Service::Origin;
use Mojo::Base 'Mojolicious::Plugin::Images::Service';
use 5.20.0;
use experimental 'signatures';
use Imager;

sub upload ($self, $id, $upload) {
  $upload = $self->controller->req->upload($upload) unless ref $upload;
  my $img = Imager::->new(data => $upload->slurp) or die Imager::->errstr;
  $self->write($id, $img);
}

1;

=head1 SYNOPSIS

  my $origin = $c->images->origin;
  
=head1 DESCRIPTION

A service for images that are origins of others and can be written from uploads. 
Inherits all objects from L<Mojolicious::Plugin::Images::Service> and implements the following new ones


=method upload ($self, $id, $upload_or_name) 

Save image from L<Mojo::Upload> object or finds an upload in the controller

  $img = $origin->upload('image');
  $img = $origin->upload($controller->req->upload('image'));

=method read ($self, $id) 

Reads an object and tries to syncronize it if not exists yet

=attr from

A moniker to the parent object
