#!perl
use 5.010;
use open qw(:locale);
use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;

my $class = 'Align::Sequence';

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
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'],
];

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[2]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my $hunks = $object->align(\@a,\@b);
  
  print Dumper($hunks),"\n";
  
  my ($sa,$sb) = $object->hunks2sequences($hunks);
  
  my $ra = join '', map { $_ ? $_ : '_'} @$sa;
  my $rb = join '', map { $_ ? $_ : '_'} @$sb;
  
  print '$a: ',$a,"\n";
  print '$b: ',$b,"\n";
  print '$ra:',$ra,"\n";
  print '$rb:',$rb,"\n";

  is_deeply([$ra,$rb],[$a, $b],"$a, $b");
  
}
}

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[1]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my $hunks = $object->align2(\@a,\@b);
  
  my ($sa,$sb) = $object->hunks2sequences($hunks);
  my $ra = join '', map { $_ ? $_ : '_'} @$sa;
  my $rb = join '', map { $_ ? $_ : '_'} @$sb;

  is_deeply([$ra,$rb],[$a, $b],"$a, $b");
  
}
}

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[1]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my $hunks = $object->align4(\@a,\@b);
  
  my ($sa,$sb) = $object->hunks2sequences($hunks);
  my $ra = join '', map { $_ ? $_ : '_'} @$sa;
  my $rb = join '', map { $_ ? $_ : '_'} @$sb;

  is_deeply([$ra,$rb],[$a, $b],"$a, $b");
  
}
}

use Algorithm::LCS;
my $lcs = Algorithm::LCS->new();
use Data::Dumper;

if (1) {
for my $example (@$examples) {
#for my $example ($examples->[2]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  
  #print STDERR Dumper([ $object->LCSidx(\@a,\@b) ]),"\n";

  #print STDERR Dumper([ $lcs->LCS(\@a,\@b) ]),"\n";

  is_deeply(
    $object->basic_lcs(\@a,\@b) ,
    [ $lcs->LCS(\@a,\@b) ],
    "$a, $b"
  );
  
}
}

if (0) {
for my $example (@$examples) {
#for my $example ($examples->[2]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  
  #print STDERR Dumper([ $object->LCSidx(\@a,\@b) ]),"\n";

  #print STDERR Dumper([ $lcs->LCS(\@a,\@b) ]),"\n";

  is(
    $object->basic_llcs(\@a,\@b) ,
    $lcs->LCS(\@a,\@b) ,
    "$a, $b"
  );
  
}
}

=comment

is($object->binsearch([0],-1),0,'[0],-1');
is($object->binsearch([0],0),undef,'[0],0');
is($object->binsearch([],-1),undef,'[],-1');
is($object->binsearch([0,1],0),1,'[0,1],1');
is($object->binsearch([0,1,2],0),1,'[0,1,2],1');
is($object->binsearch([0,1,2],3),undef,'[0,1,2],-1');

=cut



done_testing;
