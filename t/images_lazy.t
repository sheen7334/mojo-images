use Mojo::Base -strict;
use Mojolicious::Lite;
use Test::More;
use Test::Mojo;
use Mojolicious::Plugin::Images::Test ':all';
use Imager;
use IO::All 'tmpdir';

my $tmpdir = io()->tmpdir;
$tmpdir = 'draft/';
my $options = {
  origin =>
    {dir => "$tmpdir/origin/images", suffix => '-origin', url_prefix => undef},
  dest => {
    dir  => "$tmpdir/dest/images",
    from => 'origin',
    transform =>
      sub { shift()->scale(xpixels => 69, ypixels => 69, type => 'nonprop') }
  }
};


my $t   = Test::Mojo->new;
my $app = app();
push @{$app->static->paths}, "$tmpdir/dest";

$app->plugin('Images', $options);
my $c      = $app->build_controller;
my $origin = $c->images->origin;
my $dest   = $c->images->dest;
my $id     = uniq_id;
$origin->upload($id, test_upload(400, 200));

ok !$c->images->dest->exists($id), "not exists yet";
$t->get_ok("/images/$id-dest.jpg")->status_is(200);
ok $c->images->dest->exists($id), "already exists";


$t->get_ok("/images/$id-origin.jpg")->status_is(404);
$t->get_ok("/images/$id-bad.jpg")->status_is(404);
$t->get_ok("/images/$id-dest.JPG")->status_is(404);
$t->get_ok("/images/$id-dest")->status_is(404);


done_testing;


