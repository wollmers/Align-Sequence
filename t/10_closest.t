#!perl
use 5.010;
use open qw(:locale);
use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;
use Test::Deep;
#cmp_deeply([],any());
use Data::Dumper;

#use Algorithm::Diff qw(sdiff);

my $class = 'Align::Sequence::BV';

use_ok($class);

my $object = new_ok($class);

if (0) {
ok($object->new());
ok($object->new(1,2));
ok($object->new({}));
ok($object->new({a => 1}));

ok($class->new());
}

=comment

if (0) {
for my $example (@$examples) {
#for my $example ($examples->[22]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;

  #my @lev2 = sdiff(\@a,\@b);
  my $lev2 = $object2->basic_distance(\@a,\@b,2);
  my $lev = $object->lev(\@a,\@b);

  #print '$lev2: ',Dumper(\@lev2);
  is($lev,$lev2,"$a, $b");

}
}

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[5]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;

  #my @lev2 = sdiff(\@a,\@b);
  #my $lev2 = $object2->basic_distance(\@a,\@b);
  my $script = $object->lcs(\@a,\@b);


  print "$a, $b ",'$script: ',Dumper($script);
  #is($lev,$lev2,"$a, $b");

}
}

=cut

#$object->closest(undef);

$object->ag([1,2,3],[2,3,4]);

done_testing;

=comment

l1 a2
a a
a b

l1 2 a2
a aa
a ab
a ba
a bb

l2 a2
aa ab
aa ba
aa bb
