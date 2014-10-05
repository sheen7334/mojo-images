package Mojolicious::Plugin::Images;
use Mojo::Base 'Mojolicious::Plugin';
use 5.20.0;
use experimental 'signatures';

use Mojo::Path;
use Mojolicious::Plugin::Images::Service::Dest;
use Mojolicious::Plugin::Images::Service::Origin;
use Mojolicious::Plugin::Images::Util ':all';

# VERSION


sub _class($from) {
  my $ns = "Mojolicious::Plugin::Images::Service";
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
    $opts{namespace} //= ref $app unless $app->isa('Mojolicious::Lite');
    my $class = _class($opts{from});

    my $msg_attr = join(', ',
      map {"$_ => '${\( $opts{$_} // 'undef' ) }'"} sort keys %opts);

    plugin_log($app, "Creating helper images.%s(%s): {%s};",
      $moniker, $class, $msg_attr);

    $app->helper(
      "images.$moniker" => sub {
        $class->new(%opts, controller => shift);
      }
    );

    if (defined $opts{url_prefix}) {
      install_route($app, $moniker, \%opts);
      expand_static($opts{dir}, $opts{url_prefix}, $app);
    }
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
