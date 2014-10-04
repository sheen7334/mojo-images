package Mojolicious::Plugin::Images;
use Mojo::Base 'Mojolicious::Plugin';
use 5.20.0;
use experimental 'signatures';


# VERSION

sub register($self, $app, $options) {

  my $ns = "Mojolicious::Plugin::Images::Image";
  foreach my $k (keys %$options) {
    $app->helper(
      "images.$k" => sub {
        my $c    = shift;
        my %opts = %{$options->{$k}};
        my $type = $opts{from} ? 'Dest' : 'Origin';
        "$ns::$type"->new(%opts, controller => $c);
      }
    );
  }

}

1;

# ABSTRACT: brand new module Mojolicious::Plugin::Images

=head1 SYNOPSIS

  ...

=head1 DESCRIPTION

Some description here.

=method foo

This method does something amazing.
