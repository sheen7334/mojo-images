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

# install route /$prefix/(*key)-$suffix.$ext
sub _route($app, $moniker, $opts) {

  my $placeholder = '(*img)';
  my $end = $opts->{suffix} // '';
  $end .= ".${\$opts->{ext}}" if $opts->{ext};
  my $path = Mojo::Path->new($opts->{url_prefix})->leading_slash(1)
    ->trailing_slash(1)->merge("${placeholder}${end}");

  $app->log->debug("Installing route GET $path for Images '$moniker'");
  $app->routes->get("$path")->to(cb => sub { _action(shift, $moniker) });
}

sub _class($from) {
  my $ns = "Mojolicious::Plugin::Images::Image";
  return $from ? "${ns}::Dest" : "${ns}::Origin";
}

sub _defaults {
  return (ext => 'jpg', dir => 'public/images', url_prefix => '/images');
}

sub register($self, $app, $options) {
  foreach my $moniker (keys %$options) {

    # helper
    my %opts = (_defaults(), %{$options->{$moniker}});
    $opts{suffix} //= "-$moniker";
    my $class = _class($opts{from});

    $app->log->debug(sprintf "Creating helper images.%s(%s): {%s};",
      $moniker, $class, join(', ', map {"$_ => '$opts{$_}'"} sort keys %opts));
    $app->helper(
      "images.$moniker" => sub {
        $class->new(%opts, controller => shift);
      }
    );

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
