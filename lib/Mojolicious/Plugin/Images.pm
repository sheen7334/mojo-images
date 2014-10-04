package Mojolicious::Plugin::Images;
use Mojo::Base 'Mojolicious::Plugin';
use 5.20.0;
use experimental 'signatures';

use Mojo::Path;
use Mojolicious::Plugin::Images::Image::Dest;
use Mojolicious::Plugin::Images::Image::Origin;

# VERSION

sub _action($c, $moniker) {
  $c->render(text => 'foo');
}

sub _route($app, $moniker, $opts) {

  my $path = Mojo::Path->new($opts->{url_prefix})->leading_slash(1)
    ->trailing_slash(1)->merge('(*img)' . ($opts->{suffix} // '') . '.jpg');
  $app->routes->get("$path")->to(cb => sub { _action(shift, $moniker) });
}

sub _class($from) {
  my $ns = "Mojolicious::Plugin::Images::Image";
  return $from ? "${ns}::Dest" : "${ns}::Origin";
}

sub register($self, $app, $options) {

  foreach my $moniker (keys %$options) {

    # helper
    my %opts  = %{$options->{$moniker}};
    my $class = _class($opts{from});

    # defaults
    $opts{suffix} //= "-$moniker";

    $app->log->debug(sprintf "Creating helper images.%s(%s): {%s};",
      $moniker, $class, join(', ', map {"$_=> '$opts{$_}'"} sort keys %opts));

    $app->helper(
      "images.$moniker" => sub {
        my $c = shift;
        $class->new(%opts, controller => $c);
      }
    );

    # install route /$prefix/(*key)-$suffix.$ext
    _route($app, $moniker, \%opts) if defined $opts{url_prefix};


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
