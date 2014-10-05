use Mojo::Base -strict;
use Test::More;
use Mojolicious::Lite;
use Mojolicious::Plugin::Images::Util ':all';

my $options = {first => {}};

my $app = app;
$app->plugin('Images', $options);
my $c = $app->build_controller;


say $app->home;
my $first = $c->images->first;


use Data::Printer;
#expand_static($app, $first);


done_testing;

