package Mojolicious::Plugin::Images::Image;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::URL;

has ext => 'jpg';
has dir => 'public/images';

has [qw(suffix  write_options read_options)];
has url_prefix => '/images';
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

sub url($self, $id) {
  my $fname
    = $self->check_id->($id)
    . $self->suffix
    . ($self->ext ? '.' . $self->ext : '');
  my $url = Mojo::URL->new($self->url_prefix);
  $url->path->leading_slash(1)->trailing_slash(1)->merge($fname);
  $url;
}

sub filepath($self, $id) {

  $id = $self->check_id->($id);
  my $fname = $id . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  io->catfile($self->dir, $fname) . '';
}

sub exists ($self, $id) {
  io($self->filepath($id))->exists;
}

sub read ($self, $id) {
  Imager::->new(
    file => $self->filepath($self->check_id->($id)),
    %{$self->read_options || {}}
  );
}

sub write($self, $id, $img) {
  my $filepath = $self->filepath($id);
  my $dir      = io->file($filepath)->filepath;
  io->dir($dir)->mkpath unless io->dir($dir)->exists;
  my $new;
  my $trans = $self->transform;

  if (ref $trans eq 'CODE') {
    $new = $trans->($img);
  }
  else {
    $new = $img;
  }

  $new->write(file => $filepath, %{$self->write_options || {}})
    or die Imager::->errstr;
}

1;

