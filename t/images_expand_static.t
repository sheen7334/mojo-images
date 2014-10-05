use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Util ':all';

my $options = {first => {}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c        = $app->build_controller;
my $paths    = $app->static->paths;
my $pristine = [@{$app->static->paths}];
my $first    = $c->images->first;
my $home     = $app->home;

expand_static($app, $first);
is_deeply $paths, $pristine, "Nothing changed yet";

# my/
$first->url_prefix('/images')->dir('my/images');
expand_static($app, $first);
is_deeply $paths, [@$pristine, "$home/my"], "Path added";

# one more time
expand_static($app, $first);
is_deeply $paths, $pristine = [@$pristine, "$home/my"], "Duplicates avoided";

# no static_path
$first->url_prefix('/images')->dir('foo/bar');
expand_static($app, $first);
is_deeply $paths, $pristine, "Nothing changed";

# /absolute dir
$first->url_prefix('/images')->dir('/my/images');
expand_static($app, $first);
is_deeply $paths, $pristine = [@$pristine, "/my"], "Root path added";

# hidden img withour url_prefix
$first->url_prefix(undef)->dir('/second/photo');
expand_static($app, $first);
is_deeply $paths, $pristine, "Hidden images don't affect paths";

# empty != undef
$first->url_prefix('')->dir('/second/photo');
expand_static($app, $first);
is_deeply $paths, [@$pristine, '/second/photo'],
  "Added with url prefix not undefined";
done_testing;

