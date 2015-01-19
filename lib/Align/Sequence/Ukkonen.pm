package Align::Sequence::Ukkonen;

use strict;
use warnings;

use 5.010_001;
our $VERSION = '0.01';

use Data::Dumper;

sub new {
  my $class = shift;
  # uncoverable condition false
  bless @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}, ref $class || $class;
}


sub alg8 {
  my ($self,$k,$p,$a,$b,$m,$n,$F) = @_;

  print '$k: ',$k,' $p: ',$p,"\n";
  if (defined $F->{$k}->{$p}) {
    print 'defined: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }
  #if ($k < 0) {return abs($k)-1;}
  elsif ($k < 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = abs($k)-1;
    print 'k < 0: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }
  elsif ($k >= 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = -1;
    print 'k >= 0: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }
  elsif ($p < 0 ) {
  	$F->{$k}->{$p} = -($m+$n);
    print 'p < -1: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }
  elsif ($k < 0 && abs($k) > $m ) {
  	$F->{$k}->{$p} = -($m+$n);
    print 'p < -1: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }
  elsif ($k > 0 && abs($k) > $n ) {
  	$F->{$k}->{$p} = -($m+$n);
    print 'p < -1: ',$F->{$k}->{$p},"\n";
    return $F->{$k}->{$p};
  }

  #print 'alg8 $F: ',Dumper($F);
  #print '$k: ',$k,' $p: ',$p,"\n";
  #exit;

  my $t = $self->max3(
  	$self->alg8($k,  $p-1,$a,$b,$m,$n,$F),
  	$self->alg8($k-1,$p-1,$a,$b,$m,$n,$F),
  	$self->alg8($k+1,$p-1,$a,$b,$m,$n,$F)
  );
  print '$t: ',$t,"\n";
  #exit;
  # TODO: should be $t, because index origin is 0, not 1
  # while ($a->[$t+1] eq $b->[$t+1+$k]) {
  while (($t >= -1) && ($t+1 < $m) && ($t+1+$k < $n) && ($a->[$t+1] eq $b->[$t+1+$k])) {
    $t++;
  }
  #my $f;
  #if (($t > $m) || ($t+$k > $n)) {
  #  $f = undef;
  #}
  #else { $f = $t }

  $F->{$k}->{$p} = $t;

  return $t;
}

sub alg11 {
  my ($self,$a,$b,$m,$n,$F) = @_;

  my $p = -1;
  my $r = $p - $self->min($m,$n);

  print STDERR '$p: ',$p,' $r: ',$r,"\n";
  #exit;
  my $f;

#  while ($self->alg8($n-$m,$p,$a,$b,$m,$n,$F) < $m-1) {
  while (!exists($F->{$n-$m}->{$p}) || $F->{$n-$m}->{$p} < $m-1) {
#  while ($p < 0) {

    $p++;
    $r++;
    if ($r <= 0) {
      print STDERR '$p: ',$p,' $r: ',$r,"\n";
      #print STDERR 'alg11 $F: ',Dumper($F);
      #exit;
      for my $k (-$p .. $p) {
        #print STDERR '$k: ',$k,' $p: ',$p,"\n";
        #exit;
        $f = $self->alg8($k,$p,$a,$b,$m,$n,$F);
      }
    }
    else {
      for my $k (min(-$m,-$p) .. min($n,$p)) {
        $f = $self->alg8($k,$p,$a,$b,$m,$n,$F);
      }
    }
    #exit
  }
  print STDERR 'alg11 $F: ',Dumper($F);
  print STDERR 'return $p: ',$p,' $r: ',$r,"\n";
  return $p;
}

# reading out the edit script
sub alg12 {
  my ($self,$s,$m, $n,$a,$b) = @_;

  my $p = $s;
  my $k = $m - $n;

  while ($p > 0) {
    my $t = $self->max3(
      f($k,$p-1)+1,
      f($k-1,$p-1),
      f($k+1,$p-1)+1,
    );
    # let 1 <= i <= 3 be such that
    # the ith of expressions
    # f($k,$p-1)+1,f(k-1,p-1),f(k+1,p-1)+1,
    # has the largest value
    my $i;
    for (1 .. 3) {

    }
    if ($i = 1) {
      $self->change($a->[$t],$b->[$t+$k]);
    }
    elsif ($i = 2) {
      $self->insert($a->[$t],$b->[$t+$k]);
      $k = $k-1;
    }
    else {
      $self->delete($a->[$t]);
      $k = $k+1;
    }
    $p--;
  }
  # return what?
}

sub lev {
  my ($self,$a,$b) = @_;

  my $m = scalar @$a;
  my $n = scalar @$b;

  print STDERR '$m: ',$m,' $n: ',$n,"\n";

  my $F = {};

  my $lev = $self->alg11($a,$b,$m,$n,$F);
  return $lev;
}

sub max3 {
  ( ($_[1] > $_[2])
    ? (($_[1] >= $_[3]) ? $_[1] : $_[3])
    : (($_[2] >= $_[3]) ? $_[2] : $_[3])
  )
}

sub max {
  ($_[1] > $_[2]) ? $_[1] : $_[2];
}

sub min {
  ($_[1] < $_[2]) ? $_[1] : $_[2];
}
