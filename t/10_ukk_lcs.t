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
  [ 'ab',
    'ab' ],
  ['ttatc__cg',
   '__agcaact'],
  ['abcabba_',
   'cb_ab_ac'],
   ['yqabc_',
    'zq__cb'],
  [ 'rrp',
    'rep'],
  [ 'a',
    'b' ],
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
  [ 'Chrerr',
    'Choere'],
  [ 'rr',
    're'],
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'],
];

sub is_in {
  my ($needle,$hay) = @_;

ARRAY:  for my $array (@$hay) {
    next ARRAY unless (@$needle == @$array);
    for my $i (0..$#$array) {
      next ARRAY unless (@{$needle->[$i]} == @{$needle->[$i]});
      for my $j (0..$#{$array->[$i]}) {
        next ARRAY unless (@{$needle->[$i][$j]} eq @{$needle->[$i][$j]});
      }
    }
   return $array;
  }
  return [];
}

if (0) {
  is($object->max3(1,1,1),1,'1,1,1');
  is($object->max3(1,1,0),1,'1,1,0');
  is($object->max3(1,0,0),1,'1,0,0');
  is($object->max3(1,0,1),1,'1,0,1');
  is($object->max3(0,1,1),1,'0,1,1');
  is($object->max3(0,0,1),1,'0,0,1');
  is($object->max3(0,1,0),1,'0,1,0');
  is($object->max3(0,0,0),0,'0,0,0');
  is($object->max3(1,2,3),3,'1,2,3');
  is($object->max3(3,2,1),3,'3,2,1');
  is($object->max3(1,3,2),3,'1,1,1');
}

if (0) {
  is($object->max(1,1),1,'1,1');
  is($object->max(1,0),1,'1,0');
  is($object->max(0,1),1,'0,1');
  is($object->max(0,0),0,'0,0');

}

if (0) {
  is($object->min(1,1),1,'1,1');
  is($object->min(1,0),0,'1,0');
  is($object->min(0,1),0,'0,1');
  is($object->min(0,0),0,'0,0');

}



if (1) {
#for my $example (@$examples) {
for my $example ($examples->[6]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;

  my @lev2 = sdiff(\@a,\@b);

  my $lev = $object->lev(\@a,\@b);

  print '$lev2: ',Dumper(\@lev2);
  is($lev,scalar @lev2);

}
}



done_testing;
