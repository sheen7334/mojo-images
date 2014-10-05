use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';

my $options = {
  first  => {},
  second => {ext => '', suffix => '', from => 'first'},
  third  => {
    check_id => sub {shift}
  }
};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first  = $c->images->first;
my $second = $c->images->second;
my $third  = $c->images->third;

use IO::All;
is $first->canonpath('foo/bar'), 'public/images/foo/bar-first.jpg',
  'right canonpath';

is $first->dir,        'public/images', 'dir is public/images by default';
is $first->url_prefix, '/images',       'dir is public/images by default';
is $first->suffix,     "-first",        'Right default suffix';
is $first->ext,        'jpg';
is $first->canonpath('foo/bar'), 'public/images/foo/bar-first.jpg',
  'right canonpath';
is $first->url('foo/bar'), '/images/foo/bar-first.jpg';
'right url';

is $second->ext,    '', 'no ext';
is $second->suffix, '', 'no suffix';
is $second->canonpath('foo/bar'), 'public/images/foo/bar',
  'right default name';
is $second->url('foo/bar'), '/images/foo/bar', 'right url';

# utf8
is $second->canonpath('привет'), 'public/images/привет',
  'right url';

done_testing;
