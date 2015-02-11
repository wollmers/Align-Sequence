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

use Algorithm::Diff qw(sdiff);

my $class = 'Align::Sequence::Ukkonen';

use_ok($class);

my $object = new_ok($class);

if (0) {
ok($object->new());
ok($object->new(1,2));
ok($object->new({}));
ok($object->new({a => 1}));

ok($class->new());
}

my $examples = [
  [ 'a',
    'a' ],
  [ 'a',
    'b' ],
  [ 'ab',
    'ab' ],
  [ 'abcde',
    'abcde' ],
  [ 'abb',
    'bab' ],
  [ 'abbc',
    'babca' ],
  ['ttatc__cg',
   '__agcaact'],
  ['abc',
   'cb_'],
  ['abcabba_',
   'cb_ab_ac'],
   ['ab',
    'cb'],
   ['yqabc_',
    'zq__cb'],
  [ 'aab',
    'acb'],
  [ 'ab',
    'cd' ],
  [ 'ab',
    '_b' ],
  [ 'ab_',
    '_bc' ],
  [ 'abcdef',
    '_bc___' ],
  [ 'abcdef',
    '_bcg__' ],
  [ 'xabcdef',
    'y_bc___' ],
  [ 'öabcdef',
    'ü§bc___' ],
  [ 'o__horens',
    'ontho__no'],
  [ 'Jo__horensis',
    'Jontho__nota'],
  [ 'horen',
    'ho__n'],
  [ 'Chrerrplzon',
    'Choereph_on'],
  [ 'plzon',
    'ph_on'],
  [ 'Chrerr',
    'Choere'],
  [ 'aa',
    'ab'],
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'],
];


my $class2 = 'Align::Sequence';

use_ok($class2);

my $object2 = new_ok($class2);

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

if (1) {
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
