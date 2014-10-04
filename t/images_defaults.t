use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Data::Dumper;

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
is $first->filepath('foo/bar'), 'public/images/foo/bar-first.jpg',
  'right filepath';

is $first->dir,        'public/images', 'dir is public/images by default';
is $first->url_prefix, '/images',       'dir is public/images by default';
is $first->suffix,     "-first",        'Right default suffix';
is $first->ext,        'jpg';
is $first->filepath('foo/bar'), 'public/images/foo/bar-first.jpg',
  'right filepath';
is $first->url('foo/bar'), '/images/foo/bar-first.jpg';
'right url';

is $second->ext,    '', 'no ext';
is $second->suffix, '', 'no suffix';
is $second->filepath('foo/bar'), 'public/images/foo/bar', 'right default name';
is $second->url('foo/bar'),      '/images/foo/bar',       'right url';

# utf8
is $second->filepath('привет'), 'public/images/привет',
  'right url';

# security for dummies
foreach my $meth (qw(url filepath exists read)) {
  is eval { $first->$meth('../ff') }, undef, "right death on $meth";
  like $@, qr/bad id/, "right error";
}

is eval { $first->write('../ff', test_image) }, undef, "right death on write";
like $@, qr/bad id/, "right error";
is eval { $first->upload('../ff', test_upload) }, undef,
  "right death on upload";
like $@, qr/bad id/, "right error";

# utf8
is $third->url('❤'),      '/images/%E2%9D%A4-third.jpg';
is $third->filepath('❤'), 'public/images/❤-third.jpg';

done_testing;
