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

  if (exists $F->{$k}->{$p}) {
    return $F->{$k}->{$p};
  }
  elsif ($k < 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = abs($k)-1;
    return $F->{$k}->{$p};
  }
  elsif ($k >= 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = -1;
    return $F->{$k}->{$p};
  }
  elsif ($p < abs($k)-1 ) {
  	$F->{$k}->{$p} = -($m+$n);
    return $F->{$k}->{$p};
  }
  #elsif ($k < 0 && abs($k) > $m ) {
  #	$F->{$k}->{$p} = -($m+$n);
  #  return $F->{$k}->{$p};
  #}
  #elsif ($k > 0 && abs($k) > $n ) {
  #	$F->{$k}->{$p} = -($m+$n);
  #  return $F->{$k}->{$p};
  #}

  my $t = $self->max3(
  	#$self->alg8($k,  $p-1,$a,$b,$m,$n,$F)+1, # for lev (insert, delete, change)
  	$self->min(0,$p), # for distance LCS (only insert, delete)
  	$self->alg8($k-1,$p-1,$a,$b,$m,$n,$F),
  	#-($m+$n),
  	$self->alg8($k+1,$p-1,$a,$b,$m,$n,$F)+1
  	#-($m+$n),
  );
  while (($t > -1) && ($t < $m) && (($t+$k) > -1) && (($t+$k) < $n) && ($a->[$t] eq $b->[$t+$k])) {
    $t++;
  }

  $F->{$k}->{$p} = $t;

  return $t;
}

sub alg8a {
  my ($self,$k,$p,$a,$b,$m,$n,$F) = @_;

  if (exists $F->{$k}->{$p}) {
    return $F->{$k}->{$p};
  }
  elsif ($k < 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = abs($k)-1;
    return $F->{$k}->{$p};
  }
  elsif ($k >= 0 && $p == abs($k)-1) {
    $F->{$k}->{$p} = -1;
    return $F->{$k}->{$p};
  }
  elsif ($p < abs($k)-1 ) {
  	$F->{$k}->{$p} = -($m+$n);
    return $F->{$k}->{$p};
  }

  my $t = $self->max3(
  	#$self->alg8($k,  $p-1,$a,$b,$m,$n,$F)+1, # for lev (insert, delete, change)
  	$self->min(0,$p), # for distance LCS (only insert, delete)
  	$self->alg8a($k-1,$p-1,$a,$b,$m,$n,$F),
  	#-($m+$n),
  	$self->alg8a($k+1,$p-1,$a,$b,$m,$n,$F)+1
  	#-($m+$n),
  );
  while (($t > -1) && ($t < $m) && (($t+$k) > -1) && (($t+$k) < $n) && ($a->[$t] eq $b->[$t+$k])) {
    $t++;
  }

  $F->{$k}->{$p} = $t;

  return $t;
}


sub alg11 {
  my ($self,$a,$b,$m,$n,$F) = @_;

  my $debug = 0;

  my $p = -1;
  my $r = $p - $self->min($m,$n);

  # check, if a diagonal path reached the end
  while (!exists($F->{$n-$m}->{$p}) || $F->{$n-$m}->{$p} < $m) {
    $p++;
    $r++;
    if ($r <= 0) {
      for my $k (-$p .. $p) {
        $self->alg8($k,$p,$a,$b,$m,$n,$F);
      }
    }
    else {
      for my $k ($self->min(-$m,-$p) .. $self->min($n,$p)) {
        $self->alg8($k,$p,$a,$b,$m,$n,$F);
      }
    }
  }
  print Dumper($F) if $debug;
  $self->print_matrix($a,$b,$m,$n,$F) if $debug;
  return $p;
}

sub alg11a {
  my ($self,$a,$b,$m,$n,$F) = @_;

  my $debug = 0;

  my $p = -1;
  my $r = $p - $self->min($m,$n);

  # check, if a diagonal path reached the end
  while (!exists($F->{$n-$m}->{$p}) || $F->{$n-$m}->{$p} < $m) {
    $p++;
    $r++;
    if ($r <= 0) {
      for my $k (-$p .. $p) {
        $self->alg8a($k,$p,$a,$b,$m,$n,$F);
      }
    }
    else {
      for my $k ($self->min(-$m,-$p) .. $self->min($n,$p)) {
        $self->alg8a($k,$p,$a,$b,$m,$n,$F);
      }
    }
  }
  print Dumper($F) if $debug;
  $self->print_matrix($a,$b,$m,$n,$F) if $debug;
  return $p;
}


# reading out the edit script
# TODO: debug
sub alg12 {
  my ($self,$s,$m, $n,$a,$b,$F) = @_;

  my $p = $s; # distance from alg11
  my $k = $m - $n;

  my @edit_script;

  while ($p > 0) {
    my ($t,$i) = $self->max3index(
      $F->{$k}->{$p-1}+1, # for lev
      #-1, # for LCS
      $F->{$k-1}->{$p-1},
      $F->{$k+1}->{$p-1}+1,
    );
    # let 1 <= i <= 3 be such that
    # the ith of expressions
    # f($k,$p-1)+1,f(k-1,p-1),f(k+1,p-1)+1,
    # has the largest value
    print '$t : ',$t,' $i: ',$i,"\n";
    if ($i == 1) {
      unshift @edit_script,['change',$a->[$t-1],$b->[$t+$k-1],$t-1,$t+$k-1];
    }
    elsif ($i == 2) {
      unshift @edit_script,['insert','',$b->[$t+$k-1],'',$t+$k-1];
      $k = $k-1;
    }
    else {
      unshift @edit_script,['delete',$a->[$t-1],'',$t-1,''];
      $k = $k+1;
    }
    $p--;
  }
  return @edit_script;
}

sub alg12a {
  my ($self,$s,$m, $n,$a,$b,$F) = @_;

  my $p = $s; # distance from alg11
  my $k = $m - $n;

  my @edit_script;

  my $x = $m-1;
  my $y = $n-1;

  while ($p > 0) {
    my ($t,$i) = $self->max3index(
      #$F->{$k}->{$p-1}+1, # for lev
      -1, # for LCS
      $F->{$k-1}->{$p-1},
      $F->{$k+1}->{$p-1}+1,
    );
    # let 1 <= i <= 3 be such that
    # the ith of expressions
    # f($k,$p-1)+1,f(k-1,p-1),f(k+1,p-1)+1,
    # has the largest value
    print '$t : ',$t,' $i: ',$i,"\n";
    if (1) {
      # record match point
      while ($t-1 < $x && $t+$k-1 < $y) {
        unshift @edit_script,['match',$a->[$x],$b->[$y],$x,$y];
        $x--;
        $y--;
      }
    }
    if ($i == 1) {
      unshift @edit_script,['change',$a->[$t-1],$b->[$t+$k-1],$t-1,$t+$k-1];
    }
    elsif ($i == 2) {
      unshift @edit_script,['insert','',$b->[$t+$k-1],'',$t+$k-1];
      $k = $k-1;
      $y--;
    }
    elsif ($i == 3) {
      unshift @edit_script,['delete',$a->[$t-1],'',$t-1,''];
      $k = $k+1;
      $x--;
    }
    $p--;
  }
  return @edit_script;
}


sub lev {
  my ($self,$a,$b) = @_;

  my $m = scalar @$a;
  my $n = scalar @$b;

  #print STDERR '$m: ',$m,' $n: ',$n,"\n";

  my $F = {};

  my $lev = $self->alg11($a,$b,$m,$n,$F);
}

sub lcs {
  my ($self,$a,$b) = @_;

  my $m = scalar @$a;
  my $n = scalar @$b;

  #print STDERR '$m: ',$m,' $n: ',$n,"\n";

  my $F = {};

  my $lev = $self->alg11a($a,$b,$m,$n,$F);
  my @script = $self->alg12a($lev,$m, $n,$a,$b,$F);

  return \@script;
}


sub edit_script {
  my ($self,$a,$b) = @_;

  my $m = scalar @$a;
  my $n = scalar @$b;

  #print STDERR '$m: ',$m,' $n: ',$n,"\n";

  my $F = {};

  my $lev = $self->alg11($a,$b,$m,$n,$F);
  my @script = $self->alg12($lev,$m, $n,$a,$b,$F);

  return \@script;
}


sub max3 {
  ( ($_[1] > $_[2])
    ? (($_[1] >= $_[3]) ? $_[1] : $_[3])
    : (($_[2] >= $_[3]) ? $_[2] : $_[3])
  )
}

sub max3index {
  ( ($_[1] > $_[2])
    ? (($_[1] >= $_[3]) ? ($_[1],1) : ($_[3],3))
    : (($_[2] >= $_[3]) ? ($_[2],2) : ($_[3],3))
  )
}


sub max {
  ($_[1] > $_[2]) ? $_[1] : $_[2];
}

sub min {
  ($_[1] < $_[2]) ? $_[1] : $_[2];
}

sub print_matrix {
  my ($self,$a,$b,$m,$n,$F) = @_;

  if (1 && ($m < 20)) {
    print join('',map { sprintf('%4s',$_) } '','','',1..$n),"\n";
    print join('',map { sprintf('%4s',$_) } '','','',@$b),"\n";
    #print join('',map { sprintf('%4s',$_) } '','');
    #print "\n";
    my $i;
    for ($i=0;$i<=$m;$i++) {
      if ($i) {
        my $x = $a->[$i-1];print join('',map { sprintf('%4s',$_) } ($i,$x));
      }
      else {print join('',map { sprintf('%4s',$_) } ($i,' '));}
      for my $j (0..$n) {
        my $f;
        if (exists $F->{$j-$i}->{$i}) {
          $f = $F->{$j-$i}->{$i};
          print sprintf('%4s',$f);
        }
        else {print '   _';}

      }
      print "\n";
    }
  }
}

