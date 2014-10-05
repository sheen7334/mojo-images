package Mojolicious::Plugin::Images::Image::Origin;
use Mojo::Base 'Mojolicious::Plugin::Images::Image';
use 5.20.0;
use experimental 'signatures';
use Imager;

sub upload ($self, $id, $upload) {
  $upload = $self->controller->req->upload($upload) unless ref $upload;
  my $img = Imager::->new(data => $upload->slurp) or die Imager::->errstr;
  $self->write($id, $img);
}

1;
