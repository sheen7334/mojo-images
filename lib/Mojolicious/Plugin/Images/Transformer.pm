package Mojolicious::Plugin::Images::Transformer;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

has [qw(id service image controller)];
sub app ($self) { $self->controller->app }

1;

=head1 SYNOPSIS

  Parent class for transformers
  
=head1 DESCRIPTION

Use this class as parent for your transformers

=attr id
  
id of passed image

=attr image

An Imager object

=attr service

Helper that created an image

=attr controller

Mojolicious controller

=method app

returns application (taken from a controller)
