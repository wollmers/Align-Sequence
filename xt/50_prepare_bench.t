#!perl
use 5.010;
use open qw(:locale);
use strict;
use warnings;
use utf8;

use lib qw(../lib/);

#use Test::More;
use List::Util qw(first);


use Benchmark qw(:all) ;

my $data = [
  [split(//,'Chrerrplzon')], 
  [split(//,'Choerephon')]
];

my $X = $data->[0];
my $Y = $data->[1];

my $YPos;
my $index;
push @{ $YPos->{$_} },$index++ for @$Y;

my $short = [
  [split(//,'rerrplz')], 
  [split(//,'oereph')]
];

my $x = $short->[0];
my $y = $short->[1];

my $ypos;
my $i;
push @{ $ypos->{$_} },$i++ for @$y;


sub binsearch {
  my ($self, $positions, $R) = @_;
  
  #return $positions->[0] if (@$positions && $positions->[0] > $R);
  return $positions->[0] if ($positions->[0] > $R);
  
  # binary search for insertion point...
  my $low = 0;
  my $index;
  my $found;
  my $high = $#$positions;
  while ( $low <= $high ) {
    # $index = ( $high + $low ) / 2; # with use integer
    $index = int(( $high + $low ) / 2);  # without 'use integer'
    $found = $positions->[$index];

    if ( $R < $found ) {
      return $found;
    }
    elsif ( $R >= $found ) {
      $low = $index + 1;
    }
    else {
      $high = $index - 1;
    }
  }
  return undef;
}

sub search {
  my ($self, $positions, $R) = @_;
  
  for my $position (@$positions) {
    return $position if ($R < $position);
  }
  return undef;
}

sub search2 {
  #my ($self, $positions, $R) = @_;
  
  for  ( @{$_[1]} ) {
    return $_ if ($_[2] < $_);
  }
  return undef;
}

sub search3 {
  first { $_[2] < $_ } @{$_[1]}  
}

sub map2int {
  my ($a,$b,$a2i,$i2a) = @_;
  
  my $i = 0;
  my $c = sub {
    if (!exists $a2i->{$_[0]}) {
      $i++;
      $a2i->{$_[0]} = $i;
      $i2a->{$i} = $_[0];
    }
  };
  return (
    [map { $c->($_); $a2i->{$_} } @$a],
    [map { $c->($_); $a2i->{$_} } @$b],
  
  );
}


if (1) {
    #cmpthese( 50_000, {
    timethese( 250_000, {
    
'Uniq' => sub {
  my %uniq;
  @uniq{@{$Y}} = ();
  grep { exists $uniq{$_} } @{$X};
},

'Pos' => sub {  
  my ($YPos,$index);
  push @{ $YPos->{$_} },$index++ for @$Y;
},
  
'Match' => sub {  
  grep { exists( $YPos->{$X->[$_]} ) } 0..$#$X;
},

'uniq' => sub {
  my %uniq;
  @uniq{@{$y}} = ();
  grep { exists $uniq{$_} } @{$x};
},

'pos' => sub {  
  my ($ypos,$index);
  push @{ $ypos->{$_} },$index++ for @$y;
},
  
'match' => sub {  
  grep { exists( $ypos->{$x->[$_]} ) } 0..$#$x;
},

'a2int' => sub {
   my ($a2i, $i2a);
   my ($a,$b) = map2int($X, $Y, $a2i, $i2a);
},

  });
}
  
if (0) {
    #cmpthese( 50_000, {
    timethese( 1_000_000, {
  

'binsearch' => sub {  
  binsearch(1,[0,1,2,3,4,5,6,7,8,9],8);
},

'search' => sub {  
  search(1,[0,1,2,3,4,5,6,7,8,9],8);
 },
'search2' => sub {  
  search2(1,[0,1,2,3,4,5,6,7,8,9],8);
 },
'search3' => sub {  
  search3(1,[0,1,2,3,4,5,6,7,8,9],8);
 },

  });
}
    

