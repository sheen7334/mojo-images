use Mojo::Base -strict;
use Mojolicious::Lite;
use Test::More;
use Test::Mojo;
use Mojolicious::Plugin::Images::Test ':all';
use Imager;
use IO::All 'tmpdir';

my $tmpdir  = io()->tmpdir;
my $options = {
  origin => {dir => "$tmpdir/images/media/", suffix => '-origin',},
  dest   => {
    dir        => "$tmpdir/images/media/",
    suffix     => '-dest',
    url_prefix => '/media/',
    from       => 'origin',
    transform =>
      sub { shift()->scale(xpixels => 69, ypixels => 69, type => 'nonprop') }
  }
};


my $t   = Test::Mojo->new;
my $app = app();
$app->plugin('Images', $options);
my $c      = $app->build_controller;
my $origin = $c->images->origin;
my $dest   = $c->images->dest;
my $id     = int(rand() * 10000);


$origin->upload($id, test_upload(400, 200));
$t->get_ok("/media/$id-dest.jpg")->status_is(200);
$t->get_ok("/media/$id-origin.jpg")->status_is(404);
$t->get_ok("/media/$id-bad.jpg")->status_is(404);
$t->get_ok("/media/$id-dest.JPG")->status_is(404);
$t->get_ok("/media/$id-dest")->status_is(404);


done_testing;


