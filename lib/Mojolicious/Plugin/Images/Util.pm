package Mojolicious::Plugin::Images::Util;
use Mojo::Base 'Mojolicious::Plugin';
use 5.20.0;
use experimental 'signatures';

use Exporter 'import';
our @EXPORT_OK = (qw(install_route expand_static));
our %EXPORT_TAGS = (all => \@EXPORT_OK);

sub expand_static {

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

