use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';

my $options = {first => {}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first = $c->images->first;

# security for dummies
foreach my $meth (qw(url canonpath exists read)) {
  is eval { $first->$meth('../ff') }, undef, "right death on $meth";
  like $@, qr/bad id/, "right error";
}

is eval { $first->write('../ff', test_image) }, undef, "right death on write";
like $@, qr/bad id/, "right error";
is eval { $first->upload('../ff', test_upload) }, undef,
  "right death on upload";
like $@, qr/bad id/, "right error";


done_testing;
