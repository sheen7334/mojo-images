package Mojolicious::Plugin::Images::Transformer;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

has [qw(id service image controller)];
sub app ($self) { $self->controller->app }

1;
