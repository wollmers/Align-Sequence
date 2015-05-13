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

my $class = 'LCS';

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
  [ 'abcdefg_',
    '_bcdefgh'],
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVYZ'],
];


use Align::Sequence::BV;

if (1) {
for my $example (@$examples) {
#for my $example ($examples->[1]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;

  my $as = $a;
  my $bs = $b;
  $as =~ s/_//g;
  $bs =~ s/_//g;

  #print STDERR Dumper($object->wollmers(\@a,\@b)),"\n";

  #print STDERR Dumper([ $lcs->LCS(\@a,\@b) ]),"\n";

  #is_deeply(
  cmp_deeply(
    Align::Sequence::BV->LCS_64i(\@a,\@b),
    any(@{$object->allLCS(\@a,\@b)} ),

    "$a, $b"
  );
  if (0) {
    $Data::Dumper::Deepcopy = 1;
    #print STDERR Dumper($object->wollmers(\@a,\@b)),"\n";
    print STDERR 'wollmers: ',Data::Dumper->Dump($object->wollmers(\@a,\@b)),"\n";

    print STDERR Dumper(Align::Sequence::BV->LCS3($as,$bs)),"\n";
  }
}
}



done_testing;
