#!perl
use 5.010;
use open qw(:locale);
use strict;
use warnings;
use utf8;

use lib qw(../lib/);

my $class = 'Align::Sequence';
use Align::Sequence;

my $object = $class->new;

my $examples = [
  ['abcabba_',
   'cb_ab_ac'],
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


#for my $example (@$examples) {
for my $example ($examples->[16]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my $hunks = $object->align(\@a,\@b);
  
  my ($sa,$sb) = $object->hunks2sequences($hunks);
  my $ra = join '', map { $_ ? $_ : '_'} @$sa;
  my $rb = join '', map { $_ ? $_ : '_'} @$sb;  
}
#for my $example (@$examples) {
for my $example ($examples->[16]) {
  my $a = $example->[0];
  my $b = $example->[1];
  my @a = $a =~ /([^_])/g;
  my @b = $b =~ /([^_])/g;
  my $hunks = $object->align2(\@a,\@b);
  
  my ($sa,$sb) = $object->hunks2sequences($hunks);
  my $ra = join '', map { $_ ? $_ : '_'} @$sa;
  my $rb = join '', map { $_ ? $_ : '_'} @$sb;  
}

