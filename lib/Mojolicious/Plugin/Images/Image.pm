package Mojolicious::Plugin::Images::Image;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::URL;
use Mojo::Path;
use Mojolicious::Plugin::Images::Util ':all';
use Mojo::Util 'camelize';

has [qw(namespace url_prefix ext dir suffix write_options read_options)];
has 'transform';
has 'controller';

sub url($self, $id) {
  my $fname
    = check_id($id) . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  my $fpath = Mojo::Path->new($fname)->leading_slash(0);
  my $url   = Mojo::URL->new($self->url_prefix);
  $url->path($url->path->trailing_slash(1)->merge($fpath)->canonicalize);
  $url;
}

sub canonpath($self, $id) {
  $id = check_id($id);
  my $fname = $id . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  io->catfile(check_dir($self->dir, $self->controller->app), $fname)
    ->canonpath;
}

sub exists ($self, $id) {
  io($self->canonpath($id))->exists;
}

sub read ($self, $id) {
  Imager::->new(
    file => $self->canonpath(check_id($id)),
    %{$self->read_options || {}}
  );
}

sub _trans($self, $id, $img) {
  my $trans = $self->transform;
  my $new;
  my %args = (
    helper     => $self,
    id         => $id,
    controller => $self->controller,
    app        => $self->controller->app
  );
  if (ref $trans eq 'CODE') {
    $new = $trans->($img);
  }
=pod
  elsif ($trans && $trans =~ /^([\w\-:]*?)\#([\w]+)$/) {
    my ($class, $sub) = ($1, $2);
    unless ($class) {
      my $app = $self->controller->app;
      $class = $app->isa('Mojolicious::Lite') ? 'main' : ref $app;

    }
  }
=cut
  else {
    $new = $img;
  }
}

sub write($self, $id, $img) {
  my $canonpath = $self->canonpath($id);
  my $dir       = io->file($canonpath)->filepath;
  my $new       = _trans($self, $id, $img);

  io->dir($dir)->mkpath unless io->dir($dir)->exists;
  $new->write(file => $canonpath, %{$self->write_options || {}})
    or die Imager::->errstr;
}

1;

