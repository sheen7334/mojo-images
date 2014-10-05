package Mojolicious::Plugin::Images::Image;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::URL;

has [qw(url_prefix ext dir suffix write_options read_options)];
has 'transform';
has 'controller';

# maybe too hard
has check_id => sub {
  sub {
    my $id = shift;
    die "bad id $id" unless $id =~ /^[\ \-\w\d\/]+$/;
    return $id;
    }
};

sub static_path($self) {
  return unless defined $self->url_prefix;

  my $dir = io->dir($self->dir)->canonpath;
  my $prefix
    = Mojo::Path->new($self->url_prefix)->canonicalize->trailing_slash(0)
    ->to_route;

  return io->dir($dir)->is_absolute
    ? io->dir($dir)->absolute . ''
    : $self->controller->app->home->rel_dir($dir)
    if $prefix eq '/';

  $dir =~ s/$prefix$// or return;

  io->dir($dir)->is_absolute
    ? io->dir($dir)->absolute . ''
    : $self->controller->app->home->rel_dir($dir);
}

sub url($self, $id) {
  my $fname
    = $self->check_id->($id)
    . $self->suffix
    . ($self->ext ? '.' . $self->ext : '');
  my $fpath = Mojo::Path->new($fname)->leading_slash(0);
  my $url   = Mojo::URL->new($self->url_prefix);
  $url->path($url->path->trailing_slash(1)->merge($fpath)->canonicalize);
  $url;
}

sub canonpath($self, $id) {
  $id = $self->check_id->($id);
  my $fname = $id . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  io->catfile($self->dir, $fname)->canonpath;
}

sub exists ($self, $id) {
  io($self->canonpath($id))->exists;
}

sub read ($self, $id) {
  Imager::->new(
    file => $self->canonpath($self->check_id->($id)),
    %{$self->read_options || {}}
  );
}

sub write($self, $id, $img) {
  my $canonpath = $self->canonpath($id);
  my $dir       = io->file($canonpath)->filepath;
  io->dir($dir)->mkpath unless io->dir($dir)->exists;
  my $new;
  my $trans = $self->transform;

  if (ref $trans eq 'CODE') {
    $new = $trans->($img);
  }
  else {
    $new = $img;
  }

  $new->write(file => $canonpath, %{$self->write_options || {}})
    or die Imager::->errstr;
}

1;

