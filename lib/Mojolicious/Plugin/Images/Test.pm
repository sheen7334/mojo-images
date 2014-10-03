package Mojolicious::Plugin::Images::Test;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

use Exporter 'import';
use Imager;
use Mojo::Asset::Memory;
use Mojo::Upload;

our @EXPORT_OK = (qw(test_upload test_image));
our %EXPORT_TAGS = (all => \@EXPORT_OK);

sub test_image($x = 1024, $y = 800) {
  my $blue = Imager::Color->new(0,   0,   255);
  my $gray = Imager::Color->new(125, 125, 125);

  Imager::->new(xsize => $x, ysize => $y)->box(filled => 1, color => $gray)
    ->box(
    filled => 1,
    color  => $blue,
    box    => [int($x / 4), int($x / 4), int($x / 2), int($y / 2)]
    );
}

sub test_upload($x = 1024, $y = 800) {
  test_image($x, $y)->write(data => \my $data, type => 'jpeg');
  my $asset = Mojo::Asset::Memory->new->add_chunk($data);
  my $upload = Mojo::Upload->new(asset => $asset);
}

1;

=head1 SYNOPSIS

  use Mojolicious::Plugin::Images::Test qw(test_image test_upload);

  # create test image
  my $img = test_image;  

  # create a Mojo::Upload object containing jpeg data
  my $upload = test_upload;
  my $img = Imager::->new(data => $upload->slurp);

=head1 DESCRIPTION

Helpful functions for testing purposes

=method test_image($w, $h)

  my $img = test_image;
  $img = test_image(1024, 800);

Returns an L<Imager> object. If arguments were provided, they will be used as
width and height of a created image. Defaults are (1024, 800)

=method test_upload($w, $h)

  my $upload = test_upload;
  $upload = test_upload(1024, 800);

Returns a L<Mojo::Upload> object with valid jpeg binary data (1024x800 by default)
