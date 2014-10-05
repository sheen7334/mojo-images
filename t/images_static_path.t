use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use IO::All;

my $options = {first => {}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first = $c->images->first;

# public
my $dir = $app->home->rel_dir('public');
$first->dir('public/images')->url_prefix('images/');
is $first->static_path, $dir, "right dir";
ok io->dir($first->static_path)->is_absolute, "path is abs";

$first->dir('public/images/')->url_prefix('images');
is $first->static_path, $dir, "right dir";

$first->dir('public/images/')->url_prefix('/images/');
is $first->static_path, $dir, "right dir";

# home
$dir = $app->home->rel_dir('/');
$first->dir('/images/')->url_prefix('/images/');
is $first->static_path, $dir, "right dir";

# outside
$first->dir('/root/images/')->url_prefix('images');
is io($first->static_path) . '', '/root';

# deeper
$dir = $app->home->rel_dir('public/foo');
$first->dir('public/foo/images/')->url_prefix('/images');
is $first->static_path, $dir;


# /  means root of site
$dir = $app->home->rel_dir('public/images');
$first->dir('public/images')->url_prefix('/');
is $first->static_path, $dir, "right value";

# '' != undef
$first->dir('public/images')->url_prefix('');
is $first->static_path, $dir, "right value";

# is hidden (without url_prefix)
$first->dir('public/images')->url_prefix(undef);
is $first->static_path, undef, "right undef value for hidden";

# can't be found
$first->dir('public/foo/images/bar')->url_prefix('/images');
is $first->static_path, undef, "right undef value";

$first->dir('foo')->url_prefix('bar');
is $first->static_path, undef, "right undef value";


done_testing;

