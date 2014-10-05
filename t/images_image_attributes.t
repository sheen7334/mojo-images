use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';

my $options = {first => {}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first = $c->images->first;

# utf8
is $first->canonpath('привет'), 'public/images/привет-first.jpg',
  'right url';
is $first->url('я'), '/images/%D1%8F-first.jpg';

# some wied things
is $first->url_prefix('/foo///')->url('bar//baz'),  '/foo/bar/baz-first.jpg';
is $first->url_prefix('/foo///')->url('/bar//baz'), '/foo/bar/baz-first.jpg';
is $first->url_prefix('foo')->url('bar'),           'foo/bar-first.jpg';

is $first->dir('привет/foo//')->canonpath('пока//bar//baz'),
  'привет/foo/пока/bar/baz-first.jpg';
is $first->dir('//привет/foo//')->canonpath('//пока//bar//baz'),
  '/привет/foo/пока/bar/baz-first.jpg';

is $first->dir('/привет/foo')->canonpath('//пока//bar//baz'),
  '/привет/foo/пока/bar/baz-first.jpg';

done_testing;
