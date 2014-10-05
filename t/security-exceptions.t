use Mojo::Base -strict;
BEGIN { $ENV{IMAGES_ALLOW_INSECURE_IDS} = 1 }
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use IO::All;

my $tmpdir  = io()->tmpdir;
my $id      = uniq_id;
my $options = {first => {dir => $tmpdir}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;
my $first = $c->images->first;

foreach my $meth (qw(url canonpath exists read)) {
  ok eval { $first->$meth('ff/../ff'); 1 }, "not died on insecure $meth";
}

ok eval { $first->write('ff/../ff', test_image); 1 },
  "not died on insecure write";
ok eval { $first->upload('ff/../ff', test_upload); 1 },
  "not died on insecure upload";


done_testing;
