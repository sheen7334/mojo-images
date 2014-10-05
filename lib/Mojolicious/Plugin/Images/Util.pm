package Mojolicious::Plugin::Images::Util;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

use Exporter 'import';
use IO::All;

our @EXPORT_OK = (qw(install_route expand_static calc_static));
our %EXPORT_TAGS = (all => \@EXPORT_OK);

sub calc_static($dir, $url_prefix, $home) {
  return unless defined $url_prefix;

  $dir = io->dir($dir)->canonpath;
  $dir = $home->rel_dir($dir) unless io->dir($dir)->is_absolute;

  my $prefix = Mojo::Path->new($url_prefix)->canonicalize->to_route;
  $prefix = Mojo::Path->new($prefix)->leading_slash(0)->trailing_slash(0);

  $dir =~ s/$prefix$// or return ;

  io->dir($dir)->canonpath;
}

sub expand_static($app, $img) {
  my $paths = $app->static->paths;
  my $static_path = $img->static_path or return;
  push @$paths, $static_path unless grep { $_ eq $static_path } @$paths;
}

# install route /$prefix/(*key)-$suffix.$ext
sub install_route($app, $moniker, $opts) {
  my $placeholder = '(*images_id)';
  my $end = $opts->{suffix} // '';
  $end .= ".${\$opts->{ext}}" if $opts->{ext};
  my $path = Mojo::Path->new($opts->{url_prefix})->leading_slash(1)
    ->trailing_slash(1)->merge("${placeholder}${end}");

  $app->log->debug("Installing route GET $path for Images '$moniker'");
  $app->routes->get("$path")->to(cb => sub { _action(shift, $moniker) });
}

sub _action($c, $moniker) {
  my $id = $c->stash('images_id');
  $c->render(text => 'foo');
  my $img = $c->images->$moniker;

  $c->app->log->debug("Images $moniker: $id");
  return $c->reply->static($img->url($id))
    if $img->exists($id) || $img->sync($id);

  return $c->reply->not_found;
}
