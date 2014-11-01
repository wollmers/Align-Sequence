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
sub align2 { shift->_align3(@_,1) }

##################################################
sub _align3 {
  my ($self, $X, $Y, $align) = @_;
  
  my ($amin, $amax, $bmin, $bmax) = (0, $#$X, 0, $#$Y);

  while ($amin <= $amax and $bmin <= $bmax and $X->[$amin] eq $Y->[$bmin]) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and $X->[$amax] eq $Y->[$bmax]) {
    $amax--;
    $bmax--;
  }
  
  my $YPos;
  my $index;
  push @{ $YPos->{$_} },$index++ for @$Y[$bmin..$bmax]; # @$b[$bmin..$bmax]
    
  my $Xmatches;
  @$Xmatches = grep { exists( $YPos->{$X->[$amin+$_]} ) } 0..$amax-$amin;
    
  my $L = []; # LCS
  my $R = -1;  # records the position of last selected symbol
  my $i;
  
  my $Pi;
  my $Pi1;
  
  for ($i = 0; $i <= $#$Xmatches; $i++) {
    #$Pi = [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i]]} } ]->[0] //= $bmax+1;
    $Pi = $bmax+1;
    for (@{ $YPos->{$X->[$amin+$Xmatches->[$i]]} }) {
      if ($R < $_) {
        $Pi = $_;
        last;
      }
    }
    #$Pi1 = ($i < $#$Xmatches) ? [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i+1]]} } ]->[0] : -1;
    $Pi1 =  -1;
    if ($i < $#$Xmatches) {
      for (@{ $YPos->{$X->[$amin+$Xmatches->[$i+1]]} }) {
        if ($R < $_) {
          $Pi1 = $_;
          last;
        }
      }
    }
    
    if ($Pi > $Pi1 && $Pi1 > $R) {
      push @$L, [$amin+$Xmatches->[$i+1],$bmin+$Pi1];
      $R = $Pi1;
      $i++;
    } 
    elsif ($Pi <= $bmax) {
      push @$L, [$amin+$Xmatches->[$i],$bmin+$Pi];
      $R = $Pi;
    }
    while (1 and @$L and $L->[-1][0]+1 <= $amax and $L->[-1][1]+1 <= $bmax and $X->[$L->[-1][0]+1] eq $Y->[$L->[-1][1]+1]) {    
      $i++;
      $R++;
      #push @$L, [ $L->[-1][0]+1, $L->[-1][0]+1 ]; # seems slower
      push @$L, [$amin+$Xmatches->[$i],$bmin+$R];
    }    
  }

  #print Dumper($L), "\n";
  map([$_ => $_], 0 .. ($amin-1)),
    @$L,
      map([$_ => ++$bmax], ($amax+1) .. $#$X);
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
  if (0) {
    print '$bMatches: ',Dumper($bMatches),"\n";
    print '$thresh: ',Dumper($thresh),"\n";
    print '$links: ',Dumper($links),"\n";
    print '$matchVector: ',Dumper($matchVector),"\n";
    print '$L: ',Dumper($L),"\n";
  }  

if (0) {
  for my $hunk (@$L) {
  
  }
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
