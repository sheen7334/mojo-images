package Mojolicious::Plugin::Images::Service;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::URL;
use Mojo::Path;
use Mojolicious::Plugin::Images::Util ':all';
use Mojolicious::Plugin::Images::Transformer;
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
    service    => $self,
    id         => $id,
    controller => $self->controller,
    image      => $img,
  );

  if (ref $trans eq 'CODE') {
    plugin_log($self->controller->app, "Transformation to cb with id $id");
    $new = $trans->(Mojolicious::Plugin::Images::Transformer->new(%args));
  }

  elsif (ref $trans eq 'ARRAY') {
    $new = $img;
    my @arr = @$trans;
    while (@arr) {
      my ($act, $args) = (shift @arr, shift @arr);
      $new = $new->$act(%$args);
    }
  }

  elsif ($trans && $trans =~ /^([\w\-:]+)\#([\w]+)$/) {
    my ($class, $action) = (camelize($1), $2);
    $class = $self->namespace . "::$class" if $self->namespace;
    plugin_log($self->controller->app,
      "Transformation to class $class and action $action with id $id");
    $new = $class->new(%args)->$action;
  }

  else {
    $new = $img;
  }
  return $new;
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

=head1 SYNOPSIS

  my $service = $c->helper->service_by_moniker;

=head1 DESCRIPTION

Base class for service objects (helpers).

=method write ($self, $id, $img) 

writes an image

=method url ($self, $id) 

returns url of an image

=method canonpath ($self, $id) 

returns a full normalized fs path of an image


=method exists ($self, $id)

returns true if an image with given id exists

=method read ($self, $id)

reads an image and returns an Imager object

=attr namespace

=attr url_prefix
Url prefix. Used to atomatically calculate static path. i</images> by defaults

=attr ext

=attr dir
Directory of images, i<public/images> by default

=attr suffix
suffix, a moniker by default

=attr write_options
write options for Imager

=attr read_options
read options for Imager

=attr transform
Transformation

  # transform to clousure
  sub { my $t = shift; return $t->image->scale(xpixels => 100) };

  # transform to {namespace}::Trans::action
  trans#action
  
  # perfom a couple of transformations
  [scale => {xpixels => 100}, crop => {width => 100}];

For the subroutines an object L<Mojolicious::Plugin::Images::Transformer> will be passed.
Must return an Imager object

=attr controller

Documentation will be available soon
