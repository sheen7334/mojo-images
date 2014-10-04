package Mojolicious::Plugin::Images::Image;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::Path;

has [qw(url_prefix write_options read_options)];
has [qw(prefix suffix )] => '';
has ext => 'jpg';
has dir => sub { die "You have to define a 'dir' attribute value" };


sub url($self, $id) {
  Mojo::Path->new($self->url_prefix)->trailing_slash(1)
    ->merge("${id}${\$self->suffix}.${\$self->ext}");
}

sub filepath($self, $id) {
  my $dir = Mojo::Path->new($self->dir)->trailing_slash(1)
    ->merge("${id}${\$self->suffix}.${\$self->ext}");
}

sub exists ($self, $id) { io($self->filepath($id))->exists; }

sub read ($self, $id) {
  Imager::->new(file => $self->filepath($id), %{$self->read_options || {}});
}

sub write($self, $id, $img) {
  my $filepath = $self->filepath($id);
  my $dir      = io->file($filepath)->filepath;
  io->dir($dir)->mkpath unless io->dir($dir)->exists;
  $img->write(file => $filepath, %{$self->write_options || {}})
    or die Imager::->errstr;
}

1;

