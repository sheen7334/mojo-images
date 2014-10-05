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

$first->dir('public/images')->url_prefix('images/');
is io($first->static_path)->relative . '', 'public';
ok io($first->static_path)->is_absolute, "path is abs";

$first->dir('public/images/')->url_prefix('images');
is io($first->static_path)->relative . '', 'public';

$first->dir('public/images/')->url_prefix('/images/');
is io($first->static_path)->relative . '', 'public';

$first->dir('/images/')->url_prefix('/images/');
is io($first->static_path)->relative . '', '.';

$first->dir('/root/images/')->url_prefix('images');
is io($first->static_path) . '', '/root';

$first->dir('public/foo/images/')->url_prefix('/images');
is io($first->static_path)->relative . '', 'public/foo';

# can't be found
$first->dir('public/foo/images/bar')->url_prefix('/images');
is $first->static_path, undef, "right undef value";

$first->dir('foo')->url_prefix('bar');
is $first->static_path, undef, "right undef value";

done_testing;

