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
  [ 'abcdefg_',
    '_bcdefgh'],
  [ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVY_',
    '_bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVYZ'],
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

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[18]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my ($ra,$rb) = $object->needleman_wunsch(\@a,\@b);

  is_deeply([$ra,$rb],[$a, $b],"$a, $b");

}
}

if (0) {
for my $example (@$examples) {
#for my $example ($examples->[1]) {
  my $a = $example->[0];
  my $b = $example->[1];
  $a =~ s/_//g;
  $b =~ s/_//g;
  my $ra = $object->lcs_greedy($a,$b);
  print STDERR $ra,"\n";
  #is_deeply([$ra,$rb],[$a, $b],"$as, $bs");

}
}

use Align::Sequence::BV;

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[1]) {
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
    Align::Sequence::BV->LCS3($as,$bs),
    #any($object->basic_lcs(\@a,\@b) ),
    any(@{$object->wollmers(\@a,\@b)} ),

    "$a, $b"
  );
  if (1) {
    $Data::Dumper::Deepcopy = 1;
    #print STDERR Dumper($object->wollmers(\@a,\@b)),"\n";
    print STDERR 'wollmers: ',Data::Dumper->Dump($object->wollmers(\@a,\@b)),"\n";

    print STDERR Dumper(Align::Sequence::BV->LCS3($as,$bs)),"\n";
  }
}
}

if (1) {
#for my $example (@$examples) {
for my $example ($examples->[15]) {
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
    #Align::Sequence::BV->LCS_64(\@a,\@b),
    Align::Sequence::BV->LCS(\@a,\@b),
    any(@{$object->wollmers(\@a,\@b)} ),

    "$a, $b"
  );
  if (0) {
    $Data::Dumper::Deepcopy = 1;
    print STDERR Data::Dumper->Dump($object->wollmers(\@a,\@b)),"\n";
    print STDERR 'ag: ',Dumper(Align::Sequence::BV->LCS(\@a,\@b)),"\n";
  }
}
}

if (0) {
#for my $example (@$examples) {
for my $example ($examples->[0]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;

  #print STDERR Dumper([ $object->LCSidx(\@a,\@b) ]),"\n";

  #print STDERR Dumper([ $lcs->LCS(\@a,\@b) ]),"\n";

  is(
    $object->basic_distance(\@a,\@b) ,
    $object->basic_distance(\@a,\@b) ,
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
