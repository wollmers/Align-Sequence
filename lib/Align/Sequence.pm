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


sub LCSidx { shift->_align4(@_,0) }
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
    #if ($hunk) {
      #print STDERR 'hunk: ',$hunk->[0],' ',$hunk->[1],' $Xcurrent: ',$Xcurrent,' $Ycurrent: ',$Ycurrent,' $i: ',$i,"\n";

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
    #}    
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
sub _align4 {
  my $self     = shift;
  my $a        = shift;    
  my $b        = shift;    

    
  my ($amin, $amax, $bmin, $bmax) = (0, $#$a, 0, $#$b);

if (1) {
  while ($amin <= $amax and $bmin <= $bmax and $a->[$amin] eq $b->[$bmin]) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and $a->[$amax] eq $b->[$bmax]) {
    $amax--;
    $bmax--;
  }
  #print '($amin, $amax, $bmin, $bmax): ',join(' ',($amin, $amax, $bmin, $bmax)),"\n";
}

  

  my $bMatches;
  my $index;
  unshift @{ $bMatches->{$_} },$index++ for @$b[$bmin..$bmax]; # @$b[$bmin..$bmax]
    
  #my $aMatches;
  #@$aMatches = grep { exists( $bMatches->{$a->[$amin+$_]} ) } 0..$amax-$amin;

  my $matchVector = [];

  my $thresh = [];
  my $links  = [];

  my ( $i, $ai, $j, $k );
  for ( $i = $amin ; $i <= $amax ; $i++ ) {
    $ai = $a->[$i];
    # the matching token
    if ( exists( $bMatches->{$ai} ) ) {
      $k = 0;
      for $j ( @{ $bMatches->{$ai} } ) {
        # optimization: most of the time this will be true
        if ( $k and $thresh->[$k] > $j and $thresh->[ $k - 1 ] < $j ) {
            $thresh->[$k] = $j;
        }
        else {
          $k = _replaceNextLargerWith( $thresh, $j, $k );
          #$k = _search( $thresh, $j, $k );
        }
        if (defined $k) {
          $links->[$k] = [ ( $k ? $links->[ $k - 1 ] : undef ), $i, $j ];
        }
      }
    }
  }

  if (@$thresh) {
    for ( my $link = $links->[$#$thresh] ; $link ; $link = $link->[0] ) {
      #print '$link: ',Dumper($link),"\n";
      #$matchVector->[ $link->[1] ] = $link->[2];
      $matchVector->[ $link->[1] ] = [$link->[1],$link->[2]+$bmin] if (defined $link->[2]);
    }
  }

  
  my $L = [ 
    map([$_ => $_], 0 .. ($amin-1)),
    grep { defined $_ } @$matchVector,
    map([$_ => ++$bmax], ($amax+1) .. $#$a)
  ];
  if (1) {
    print '$bMatches: ',Dumper($bMatches),"\n";
    print '$thresh: ',Dumper($thresh),"\n";
    print '$links: ',Dumper($links),"\n";
    print '$matchVector: ',Dumper($matchVector),"\n";
    print '$L: ',Dumper($L),"\n";
  }  

  #my $L = [ grep { defined $_ } @$matchVector ];
  return $L;
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

sub _replaceNextLargerWith {
    my ( $thresh, $j, $high ) = @_;
    $high ||= $#$thresh;

    # off the end?
    if ( $high == -1 || $j > $thresh->[-1] ) {
        push ( @$thresh, $j );
        return $high + 1;
    }
    # binary search for insertion point...
    my $low = 0;
    my $index;
    my $found;
    while ( $low <= $high ) {
        use integer;
        $index = ( $high + $low ) / 2;
        #$index = int(( $high + $low ) / 2);  # without 'use integer'
        $found = $thresh->[$index];
        if ( $j == $found ) { return undef; }
        elsif ( $j > $found ) { $low = $index + 1; }
        else { $high = $index - 1; }
    }
    # now insertion point is in $low.
    $thresh->[$low] = $j;    # overwrite next larger
    return $low;
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
    # vector< vector<int> > c(2, vector<int>(n+1,0));
    
  my $c = [];
  
  for my $i (0..1) {
    for my $j (0..$n) {
      $c->[$i][$j]=0;
    }
  }
  
  #print '$c: ',Dumper($c),"\n";
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
  #print '$c: ',Dumper($c),"\n";
  #print 'llcs: ',$c->[1][$n],"\n";
  return ($c->[1][$n]);
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
  #return $c;
  #print '$c: ',Dumper($c),"\n";
  #print '$X: ',Dumper($X),"\n";
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
  
  my $L = [];
  $L = $self->print_lcs($X,$Y,$c,$m,$n,$L);
  #print '$L: ',Dumper($L),"\n";
  return $L;
}

sub max {
  ($_[0] > $_[1]) ? $_[0] : $_[1];
}

sub print_lcs {
  my ($self,$X,$Y,$c,$i,$j,$L) = @_;

  #print '$i: ',$i,' $j: ',$j,"\n";
  #print '$L: ',Dumper($L),"\n";

  if ($i==0 || $j==0) { return $L; }
  if ($X->[$i-1] eq $Y->[$j-1]) {
       $L = $self->print_lcs($X,$Y,$c,$i-1,$j-1,$L);
       #print $X->[$i-1];
       push @{$L},[$i-1,$j-1];
  }
  elsif ($c->[$i][$j] eq $c->[$i-1][$j]) {
      $L = $self->print_lcs($X,$Y,$c,$i-1,$j,$L);
  }
  else {
      $L = $self->print_lcs($X,$Y,$c,$i,$j-1,$L);
  }
  return $L;
}

=comment

  function backtrackAll(C[0..m,0..n], X[1..m], Y[1..n], i, j)
  if i = 0 or j = 0
    return {""}
    else if X[i] = Y[j]
    return {Z + X[i] for all Z in backtrackAll(C, X, Y, i-1, j-1)}
   else
    R := {}
    if C[i,j-1] ≥ C[i-1,j]
        R := backtrackAll(C, X, Y, i, j-1)
    if C[i-1,j] ≥ C[i,j-1]
        R := R ∪ backtrackAll(C, X, Y, i-1, j)
    return R

=cut

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
