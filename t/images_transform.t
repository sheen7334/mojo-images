use Mojo::Base -strict;
use 5.20.0;
use experimental 'signatures';

use Test::More;
use Mojolicious::Lite;
use Mojolicious::Plugin::Images::Test ':all';
use Imager;
use IO::All 'tmpdir';
use Mojo::Util 'monkey_patch';

my $tmpdir = io()->tmpdir . "/images";

# namespace
@MyApp::ISA = ('Mojolicious::Lite');
my $app = MyApp::->new;
$app->plugin('Images', {foo => {}});
my $c   = $app->build_controller;
my $foo = $c->images->foo;
is $foo->namespace, undef;

@MyApp::ISA = ('Mojolicious');
$app        = MyApp::->new;
$app->plugin('Images', {foo => {}});
$c   = $app->build_controller;
$foo = $c->images->foo;
is $foo->namespace, 'MyApp';


#plugin 'Images' => {foo => {transform => '#trans11', dir => $tmpdir}};
#$c   = app->build_controller;
#
#my $id = uniq_id;
##say $c->images->foo->upload($id, test_upload);


done_testing;

