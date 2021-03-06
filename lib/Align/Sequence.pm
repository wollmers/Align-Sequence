package Align::Sequence;

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

sub align2 { shift->align(@_,1) }

##################################################
sub align {
  my ($self, $X, $Y) = @_;

  #my $LCS = [$self->_align3($X, $Y)];

  my $hunks = [];

  my $Xcurrent = -1;
  my $Ycurrent = -1;
  my $Xtemp;
  my $Ytemp;

  #for my $hunk (@$LCS) {
  for my $hunk ( @{ $self->_align4($X, $Y) } ) {
      while ( ($Xcurrent+1 < $hunk->[0] ||  $Ycurrent+1 < $hunk->[1]) ) {
        $Xtemp = '';
        $Ytemp = '';
        if ($Xcurrent+1 < $hunk->[0]) {
          $Xcurrent++;
          $Xtemp = $X->[$Xcurrent];
        }
        if ($Ycurrent+1 < $hunk->[1]) {
          $Ycurrent++;
          $Ytemp = $Y->[$Ycurrent];
        }
        push @$hunks,[$Xtemp,$Ytemp];
      }

      $Xcurrent = $hunk->[0];
      $Ycurrent = $hunk->[1];
      push @$hunks,[$X->[$Xcurrent],$Y->[$Ycurrent]]; # elements
  }
  while ( ($Xcurrent+1 <= $#$X ||  $Ycurrent+1 <= $#$Y) ) {

    $Xtemp = '';
    $Ytemp = '';
    if ($Xcurrent+1 <= $#$X) {
      $Xcurrent++;
      $Xtemp = $X->[$Xcurrent];
    }
    if ($Ycurrent+1 <= $#$Y) {
      $Ycurrent++;
      $Ytemp = $Y->[$Ycurrent];
    }
    push @$hunks,[$Xtemp,$Ytemp];
  }
  return $hunks;
}


#################################
sub sequences2hunks {
  my $self = shift;
  my ($a, $b) = @_;

  return [ map { [ $a->[$_], $b->[$_] ] } 0..$#$a ];
}


sub hunks2sequences {
  my $self = shift;
  my $hunks = shift;

  my $gap = '';

  my $a = [];
  my $b = [];

  for my $hunk (@$hunks) {
    push @$a, $hunk->[0];
    push @$b, $hunk->[1];
  }
  return ($a,$b);
}

sub _search {
  my ( $thresh, $j, $high ) = @_;
  $high ||= $#$thresh;

  if ( $high == -1 || $j > $thresh->[-1] ) {
        push ( @$thresh, $j );
        return $high + 1;
  }

  for my $k (0..$#$thresh) {
    if ( $j == $thresh->[$k] ) { return undef; }
    elsif ( $k and $thresh->[$k] > $j and $thresh->[ $k - 1 ] < $j) {
      $thresh->[$k] = $j;
      return $k;
    }
  }
}

sub basic_llcs {
  my ($self,$X,$Y) = @_;

  if (scalar @$Y > scalar @$X) {
    my $temp = $X;
    $X = $Y;
    $Y = $temp;
  }

  my $m = scalar @$X;
  my $n = scalar @$Y;

  my $c = [];

  for my $i (0..1) {
    for my $j (0..$n) {
      $c->[$i][$j]=0;
    }
  }

  my ($i,$j);

  for ($i=1; $i <= $m; $i++) {
    for ($j=1; $j <= $n; $j++) {
      if ($X->[$i-1] eq $Y->[$j-1]) {
        $c->[1][$j] = $c->[0][$j-1]+1;
      }
      else {
        $c->[1][$j] = max($c->[1][$j-1],$c->[0][$j]);
      }
    }
    for ($j = 1; $j <= $n; $j++) {
      $c->[0][$j] = $c->[1][$j];
    }
  }
  return ($c->[1][$n]);
}

sub basic_distance {
  my ($self,$X,$Y,$change_cost) = @_;

  my $m = scalar @$X;
  my $n = scalar @$Y;

  $change_cost = 1;

  my $c = [];
  my ($i,$j);
  for ($i=0;$i<=$m;$i++) {
    for ($j=0;$j<=$n;$j++) {
             $c->[$i][$j]=0;
    }
  }
  for ($i=0;$i<=$m;$i++) {
    $c->[$i][0]=$i;
  }
  for ($j=0;$j<=$n;$j++) {
    $c->[0][$j]=$j;
  }
  for ($i=1;$i<=$m;$i++) {
    for ($j=1;$j<=$n;$j++) {
      my $change = $change_cost;
      if ($X->[$i-1] eq $Y->[$j-1]) {
        $change = 0;
      }
      $c->[$i][$j] = $self->min3(
          $c->[$i][$j-1]+1,
          $c->[$i-1][$j]+1,
          $c->[$i-1][$j-1]+$change
      );
    }
  }
  if (0 && ($m < 20)) {
    print "\n",'    ',join(' ',@$Y),"\n";
    print '  ';
    for my $j (0..$n) { my $a = $c->[0][$j]; print $a,' ';}
    print "\n";
    for ($i=1;$i<=$m;$i++) {
      my $x = $X->[$i-1];print $x,' ';
      for my $j (0..$n) { my $a = $c->[$i][$j]; print $a,' ';}
      print "\n";
    }
    print "\n";
  }

  my $distance = $c->[$m][$n];
  return $distance;
}

sub one_edit {
  my ($self,$a,$b,$D) = @_;
  my $i = scalar @$a;
  my $j = scalar @$b;
  my $S = [];
  while ($i > 0 or $j > 0) {
    if ($D->[$i]->[$j] == $D->[$i-1]->[$j] +1) {
      unshift @$S,[$i,undef];
      $i--;
    }
    elsif ($D->[$i]->[$j] == $D->[$i]->[$j-1] +1) {
      unshift @$S,[undef,$j];
      $i--;
    }
    else {
      unshift @$S,[$i,$j];
      $i--;
      $j--;
    }
  }
  return $S;
}

sub all_edits {
  my ($self,$a,$b,$D,$i,$j,$S) = @_;
  $i //= scalar @$a;
  $j //= scalar @$b;
  my $S = [];
  unless ($i or $j) {return [[]] }

  while ($i > 0 or $j > 0) {
    my $min = $self->min3(
      $D->[$i-1]->[$j],
      $D->[$i]->[$j-1],
      $D->[$i-1]->[$j-1],
    );
    if ($i && $min == $D->[$i-1]->[$j]) {
      my $heads = $self->all_edits($a,$b,$D,$i-1,$j);
      for my $head (@$heads) {
        push @$S,[@$head,[$i,undef]];
      }
    }
    if ($j && $min == $D->[$i]->[$j-1]) {
      my $heads = $self->all_edits($a,$b,$D,$i,$j-1);
      for my $head (@$heads) {
         push @$S,[@$head,[undef,$j]];
    }
    if ($i && $j && $min == $D->[$i-1]->[$j-1]) {
      my $heads = $self->all_edits($a,$b,$D,$i-1,$j-1);
      for my $head (@$heads) {
        push @$S,[@$head,[$i,$j]];
    }
  }
  return $S;
}


sub basic_lcs {
  my ($self,$X,$Y) = @_;

  my $m = scalar @$X;
  my $n = scalar @$Y;

  my $c = [];
  my ($i,$j);
  for ($i=0;$i<=$m;$i++) {
    for ($j=0;$j<=$n;$j++) {
      $c->[$i][$j]=0;
    }
  }
  for ($i=1;$i<=$m;$i++) {
    for ($j=1;$j<=$n;$j++) {
      if ($X->[$i-1] eq $Y->[$j-1]) {
        $c->[$i][$j] = $c->[$i-1][$j-1]+1;
      }
      else {
        $c->[$i][$j] = max($c->[$i][$j-1], $c->[$i-1][$j]);
      }
    }
  }

  if (1 && ($m < 20)) {
    print '    ',join(' ',@$Y),"\n";
    print '  ';
    for my $j (0..$n) { my $a = $c->[0][$j]; print $a,' ';}
    print "\n";
    for ($i=1;$i<=$m;$i++) {
      my $x = $X->[$i-1];print $x,' ';
      for my $j (0..$n) { my $a = $c->[$i][$j]; print $a,' ';}
      print "\n";
    }
  }

  my $path = $self->greenberg($X,$Y,$c,$m,$n);
  return $path;
}


sub max {
  ($_[0] > $_[1]) ? $_[0] : $_[1];
}

sub print_lcs {
  my ($self,$X,$Y,$c,$i,$j,$L) = @_;

  if ($i==0 || $j==0) { return ([]); }
  if ($X->[$i-1] eq $Y->[$j-1]) {
    $L = $self->print_lcs($X,$Y,$c,$i-1,$j-1,$L);
    #print $X->[$i-1];
    push @{$L},[$i-1,$j-1];
  }
  elsif ($c->[$i][$j] == $c->[$i-1][$j]) {
    $L = $self->print_lcs($X,$Y,$c,$i-1,$j,$L);
  }
  else {
    $L = $self->print_lcs($X,$Y,$c,$i,$j-1,$L);
  }
  return $L;
}


sub wollmersAll {
  my ($self,$ranks,$rank,$max) = @_;

  my $R;
  if ($rank > $max) {return [[]]} # no matches
  if ($rank == $max) {
    return [ map { [$_] } @{$ranks->{$rank}} ];
  }

  my $tails = $self->wollmersAll($ranks,$rank+1,$max);
  for my $tail (@$tails) {
    for my $hunk (@{$ranks->{$rank}}) {
      if (($tail->[0][0] > $hunk->[0]) && ($tail->[0][1] > $hunk->[1])) {
        push @$R,[$hunk,@$tail];
      }
    }
  }
  return $R;
}

# get all LCS of two arrays
# records the matches by rank
sub wollmers {
  my ($self,$X,$Y) = @_;

  my $m = scalar @$X;
  my $n = scalar @$Y;

  my $ranks = {}; # e.g. '4' => [[3,6],[4,5]]
  my $c = [];
  my ($i,$j);

  for (0..$m) {$c->[$_][0]=0;}
  for (0..$n) {$c->[0][$_]=0;}
  for ($i=1;$i<=$m;$i++) {
    for ($j=1;$j<=$n;$j++) {
      if ($X->[$i-1] eq $Y->[$j-1]) {
        $c->[$i][$j] = $c->[$i-1][$j-1]+1;
        push @{$ranks->{$c->[$i][$j]}},[$i-1,$j-1];
      }
      else {
        $c->[$i][$j] =
          ($c->[$i][$j-1] > $c->[$i-1][$j])
            ? $c->[$i][$j-1]
            : $c->[$i-1][$j];
      }
    }
  }
  if (0 && ($m < 20)) {
    print '    ',join(' ',@$Y),"\n";
    print '  ';
    for my $j (0..$n) { my $a = $c->[0][$j]; print $a,' ';}
    print "\n";
    for ($i=1;$i<=$m;$i++) {
      my $x = $X->[$i-1];print $x,' ';
      for my $j (0..$n) { my $a = $c->[$i][$j]; print $a,' ';}
      print "\n";
    }
  }
  my $max = scalar keys %$ranks;
  return $self->wollmersAll($ranks,1,$max);
}


sub max3 {
  ( ($_[1] > $_[2])
    ? (($_[1] >= $_[3]) ? $_[1] : $_[3])
    : (($_[2] >= $_[3]) ? $_[2] : $_[3])
  )
}

sub min3 {
  ( ($_[1] < $_[2])
    ? (($_[1] <= $_[3]) ? $_[1] : $_[3])
    : (($_[2] <= $_[3]) ? $_[2] : $_[3])
  )
}


sub score {
  #print STDERR $_[0],$_[1],"\n";
  ($_[1] eq $_[2]) ? 1 : 0
}

sub needleman_wunsch {


#for i=1 to length(A)
#  for j=1 to length(B) {
#    Match ← F(i-1,j-1) + S(Ai, Bj)
#    Delete ← F(i-1, j) + d
#    Insert ← F(i, j-1) + d
#    F(i,j) ← max(Match, Insert, Delete)
#  }

  my ($self,$X,$Y) = @_;

  #my $score = sub { ($_[0] eq $_[1]) ? 1 : 0 };
  my $d = 0; # gap penalty

  my $m = scalar @$X;
  my $n = scalar @$Y;

  my $c = [];
  my ($i,$j);
  for ($i=0;$i<=$m;$i++) {
    $c->[$i][0] = $d*$i;
  }
  for ($j=0;$j<=$n;$j++) {
    $c->[0][$j] = $d*$j;
  }
  for ($i=1;$i<=$m;$i++) {
    for ($j=1;$j<=$n;$j++) {
      #print STDERR '$i: ',$i,' $j: ',$j,"\n";
      my $match  = $c->[$i-1][$j-1] + $self->score($X->[$i-1],$Y->[$j-1]);
      my $delete = $c->[$i-1][$j] + $d;
      my $insert = $c->[$i][$j-1] + $d;
      $c->[$i][$j] = $self->max3($match, $insert, $delete);
    }
  }

  $self->print_matrix($X,$Y,$m,$n,$c) if (1);

  my $align_a = '';
  my $align_b = '';

  $i = scalar @$X;
  $j = scalar @$Y;

while ($i > 0 || $j > 0) {
  if ($i > 0 && $j > 0 && ($c->[$i][$j] == ($c->[$i-1][$j-1] + $self->score($X->[$i-1],$Y->[$j-1])) )) {
    $align_a = $X->[$i-1] . $align_a;
    $align_b = $Y->[$j-1] . $align_b;
    $i--;
    $j--;
  }
  elsif ($i > 0 && $c->[$i][$j] == ($c->[$i-1][$j] + $d)) {
    $align_a = $X->[$i-1] . $align_a;
    $align_b = "_" . $align_b;
    $i--;
  }
  elsif ($j > 0 && $c->[$i][$j] == $c->[$i][$j-1] + $d) {
    $align_a = "_" . $align_a;
    $align_b = $Y->[$j-1] . $align_b;
    $j--;
  }
}
  print STDERR $align_a,"\n",$align_b,"\n";
  return $align_a, $align_b;

}

sub print_matrix {
  my ($self,$X,$Y,$m,$n,$c) = @_;

  if (1 && ($m < 20)) {
    print join('',map { sprintf('%4s',$_) } '','','',1..$n),"\n";
    print join('',map { sprintf('%4s',$_) } '','','',@$Y),"\n";
    print join('',map { sprintf('%4s',$_) } '','');
    for my $j (0..$n) { my $a = $c->[0][$j]; print sprintf('%4s',$a);}
    print "\n";
    my $i;
    for ($i=1;$i<=$m;$i++) {
      my $x = $X->[$i-1];print join('',map { sprintf('%4s',$_) } ($i,$x));
      for my $j (0..$n) { my $a = $c->[$i][$j]; print sprintf('%4s',$a);}
      print "\n";
    }
  }

}



1;
__END__

=encoding utf-8

=head1 NAME

Align::Sequence - Align two sequences

=head1 SYNOPSIS

  use Align::Sequence;

=head1 DESCRIPTION

Align::Sequence is an implementation based on a LCS algorithm.

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Helmut Wollmersdorfer

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
