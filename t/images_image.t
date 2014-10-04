use Mojo::Base -strict;

use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Mojolicious::Plugin::Images::Image::Dest;
use Mojolicious::Plugin::Images::Image::Origin;
use Imager;

use IO::All 'tmpdir';
my $tmpdir = io()->tmpdir;

my $app = Mojolicious->new;
$app->helper(
  'images.origin' => sub {
    my $c = shift;
    Mojolicious::Plugin::Images::Image::Origin->new(
      dir        => "$tmpdir/images/media/",
      suffix     => '-origin',
      url_prefix => '/media',
      controller => $c,
    );

  }
);

$app->helper(
  'images.dest' => sub {
    my $c = shift;
    Mojolicious::Plugin::Images::Image::Dest->new(
      dir        => "$tmpdir/images/media/",
      suffix     => '-dest',
      url_prefix => '/media',
      from       => 'origin',
      transform =>
        sub { shift()->scale(xpixels => 69, ypixels => 69, type => 'nonprop') }
      ,
      controller => $c,
    );

  }
);


my $origin = $app->build_controller->images->origin;
my $dest   = $app->build_controller->images->dest;

my $id   = rand();
my $path = $origin->filepath($id);

is $path, "$tmpdir/images/media/$id-origin.jpg", "right path";
ok !$origin->exists($id), "not exists yet";

# dest
# bad image
my $upload
  = Mojo::Upload->new(asset => Mojo::Asset::Memory->new->add_chunk('fff'));
die "bad upload " unless $upload->slurp eq 'fff';
ok !eval { $origin->upload($id, $upload) }, "bad image";
ok !$origin->exists($id), "not exists yet";
ok !$origin->read($id),   "read returned false";

# good
$upload = test_upload(123, 456);
$origin->upload($id, $upload);
ok $origin->exists($id),   "already exists";
isa_ok $origin->read($id), 'Imager', 'Right class';
is $origin->url($id),      "/media/$id-origin.jpg";

my $img = $origin->read($id);
is $img->getwidth,  123, "right width";
is $img->getheight, 456, "right height";

# dest
# before sync
ok !$dest->exists($id), "not exists yet";

# after sync
isa_ok my $sync = $dest->sync($id), 'Imager', 'synced correctly';

is $sync->getwidth,  '69', "right width of sync result";
is $sync->getheight, '69', "right height of sync result";
ok $dest->exists($id),   "exists after sync";
isa_ok $dest->read($id), 'Imager', 'Right class';
is $dest->filepath($id), "$tmpdir/images/media/$id-dest.jpg", "right path";


# read includes sync
$id = rand;
$origin->upload($id, test_upload);
ok $dest->read($id),   "read method also syncronized";
ok $dest->exists($id), "exists after read";

is $dest->read($id)->getwidth,  '69', "right width";
is $dest->read($id)->getheight, '69', "right height";
done_testing;


