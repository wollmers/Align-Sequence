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

sub align {
  my ($self, $X, $Y) = @_;
  
  my $YPos;
  my $index;
  push @{ $YPos->{$_} },$index++ for @$Y;
  
  my $Xmatches;
  @$Xmatches = grep { exists( $YPos->{$X->[$_]} ) } 0..$#$X;
  
  my $Xcurrent = -1;
  my $Ycurrent = -1;
  my $Xtemp;
  my $Ytemp;
  
  my @L; # LCS
  my $R = 0;  # records the position of last selected symbol
  my $i;
  
  my $Pi;
  my $Pi1;
  
  my $align = 1;
  
  my $hunk;
   
  for ($i = 0; $i <= $#$Xmatches; $i++) {
    $hunk = [];
    $Pi  =  $YPos->{$X->[$Xmatches->[$i]]}->[0] // @$Y; # Position in Y of ith symbol
    $Pi1 =  ($i < $#$Xmatches && defined $YPos->{$X->[$Xmatches->[$i+1]]}->[0]) 
  	  ? $YPos->{$X->[$Xmatches->[$i+1]]}->[0] : -1; # Position in Y of i+1st symbol
    #print STDERR '$i: ',$i,' $Pi: ',$Pi,' $Pi1: ',$Pi1,' $R: ',$R,"\n";
    while ($Pi1 < $R && $Pi1 > -1) { 
      #print STDERR '$Pi1 < $R',"\n";
      shift @{$YPos->{$X->[$Xmatches->[$i+1]]}};
      $Pi1 = $YPos->{$X->[$Xmatches->[$i+1]]}->[0] // -1;
    }
    while ($Pi < $R && $Pi < @$Y) {
      #print STDERR '$Pi < $R',"\n";
      shift @{$YPos->{$X->[$Xmatches->[$i]]}};
      $Pi =  $YPos->{$X->[$Xmatches->[$i]]}->[0] // @$Y;
    }
    if ($Pi > $Pi1 && $Pi1 > $R) {
      $hunk = [$Xmatches->[$i+1],$Pi1];
      shift @{$YPos->{$X->[$Xmatches->[$i+1]]}};
      $R = $Pi1;
      $i++;
    } 
    elsif ($Pi <  @$Y) {
      $hunk = [$Xmatches->[$i],$Pi];
      shift @{$YPos->{$X->[$Xmatches->[$i]]}}; 
      $R = $Pi;
    }

    if (scalar @$hunk) { 
      while ($align && ($Xcurrent+1 < $hunk->[0] ||  $Ycurrent+1 < $hunk->[1]) ) {
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
        push @L,[$Xtemp,$Ytemp];
      }
      $Xcurrent = $hunk->[0];
      $Ycurrent = $hunk->[1];
      #push @L,$hunk; # indices
      push @L,[$X->[$Xcurrent],$Y->[$Ycurrent]]; # elements
    }
  }
  while ($align && ($Xcurrent+1 <= $#$X ||  $Ycurrent+1 <= $#$Y) ) {
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
    push @L,[$Xtemp,$Ytemp];
  }  
  return \@L;
}

sub LCSidx { shift->_align3(@_,0) }
sub align2 { shift->_align2(@_,1) }

sub _align2 {
  my ($self, $X, $Y, $align) = @_;
  
    my ($amin, $amax, $bmin, $bmax) = (0, $#$X, 0, $#$Y);

#if (1) {
    while ($amin <= $amax and $bmin <= $bmax and $X->[$amin] eq $Y->[$bmin]) {
        $amin++;
        $bmin++;
    }
    while ($amin <= $amax and $bmin <= $bmax and $X->[$amax] eq $Y->[$bmax]) {
        $amax--;
        $bmax--;
    }
    #print STDERR '$amin: ',$amin,' $bmin: ',$bmin,' $amax: ', $amax, ' $bmax: ',$bmax,"\n";
#}
  
  my $YPos;
  my $index;
  push @{ $YPos->{$_} },$index++ for @$Y[$bmin..$bmax]; # @$b[$bmin..$bmax]
  
  #print STDERR '$YPos: ',Dumper($YPos),"\n";
  
  
  my $Xmatches;
  @$Xmatches = grep { exists( $YPos->{$X->[$amin+$_]} ) } 0..$amax-$amin;
  #print STDERR '$Xmatches: ',join(' ',@$Xmatches),"\n";
  
  my $Xcurrent = -1;
  my $Ycurrent = -1;
  my $Xtemp;
  my $Ytemp;
  
  my @L; # LCS
  my $R = -1;  # records the position of last selected symbol
  my $i;
  
  my $Pi;
  my $Pi1;
  
  #my $align = 1;
  
  my $hunk;
   
  for ($i = 0; $i <= $#$Xmatches; $i++) {
    $hunk = undef;
    $Pi = [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i]]} } ]->[0] //= $bmax+1;
    $Pi1 = ($i < $#$Xmatches) ? [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i+1]]} } ]->[0] : -1;
    $Pi1 //=  -1;
    #print STDERR ' $Pi1: ',$Pi1,' $Pi: ',$Pi,' $i: ',$i,"\n";
    
    if ($Pi > $Pi1 && $Pi1 > $R) {
      $hunk = [$amin+$Xmatches->[$i+1],$bmin+$Pi1];
      #print STDERR 'hunk: ',$hunk->[0],' ',$hunk->[1],' $Pi1: ',$Pi1,' $i: ',$i,"\n";
      $R = $Pi1;
      $i++;
    } 
    elsif ($Pi <= $bmax) {
      $hunk = [$amin+$Xmatches->[$i],$bmin+$Pi];
      #print STDERR 'hunk: ',$hunk->[0],' ',$hunk->[1],' $Pi: ',$Pi,"\n"; 
      $R = $Pi;
    }

    if ($hunk) {
      #print STDERR 'hunk: ',$hunk->[0],' ',$hunk->[1],' $Xcurrent: ',$Xcurrent,' $Ycurrent: ',$Ycurrent,' $i: ',$i,"\n";

      while ($align && ($Xcurrent+1 < $hunk->[0] ||  $Ycurrent+1 < $hunk->[1]) ) {
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
        push @L,[$Xtemp,$Ytemp];
      }
    
      $Xcurrent = $hunk->[0];
      $Ycurrent = $hunk->[1];
      #push @L,$hunk; # indices
      push @L,[$X->[$Xcurrent],$Y->[$Ycurrent]]; # elements
    }
  }
  #print STDERR '$Xcurrent: ',$Xcurrent,' $Ycurrent: ',$Ycurrent,"\n";

  #while ($align && ($Xcurrent+1 <= $#$X ||  $Ycurrent+1 <= $#$Y) ) {
   while ($align && ($Xcurrent+1 <= $amax ||  $Ycurrent+1 <= $bmax) ) {
   
    $Xtemp = '';
    $Ytemp = '';
    #if ($Xcurrent+1 <= $#$X) {
    if ($Xcurrent+1 <= $amax) {
      $Xcurrent++;
      $Xtemp = $X->[$Xcurrent];
    }
    #if ($Ycurrent+1 <= $#$Y) {
    if ($Ycurrent+1 <= $bmax) {
      $Ycurrent++;
      $Ytemp = $Y->[$Ycurrent];
    }
    push @L,[$Xtemp,$Ytemp];
  } 
  #print STDERR '$Xcurrent: ',$Xcurrent,' $Ycurrent: ',$Ycurrent,"\n";

  while ($align && ($Xcurrent+1 <= $#$X ||  $Ycurrent+1 <= $#$Y) ) {
   
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
    push @L,[$Xtemp,$Ytemp];
  }   

  return \@L;
}
##################################################
sub _align3 {
  my ($self, $X, $Y, $align) = @_;
  
    my ($amin, $amax, $bmin, $bmax) = (0, $#$X, 0, $#$Y);

#if (1) {
    while ($amin <= $amax and $bmin <= $bmax and $X->[$amin] eq $Y->[$bmin]) {
        $amin++;
        $bmin++;
    }
    while ($amin <= $amax and $bmin <= $bmax and $X->[$amax] eq $Y->[$bmax]) {
        $amax--;
        $bmax--;
    }
    #print STDERR '$amin: ',$amin,' $bmin: ',$bmin,' $amax: ', $amax, ' $bmax: ',$bmax,"\n";
#}
  
  my $YPos;
  my $index;
  push @{ $YPos->{$_} },$index++ for @$Y[$bmin..$bmax]; # @$b[$bmin..$bmax]
  
  #print STDERR '$YPos: ',Dumper($YPos),"\n";
  
  
  my $Xmatches;
  @$Xmatches = grep { exists( $YPos->{$X->[$amin+$_]} ) } 0..$amax-$amin;
  #print STDERR '$Xmatches: ',join(' ',@$Xmatches),"\n";
    
  my @L; # LCS
  my $R = -1;  # records the position of last selected symbol
  my $i;
  
  my $Pi;
  my $Pi1;
  
  #my $align = 1;
     
  for ($i = 0; $i <= $#$Xmatches; $i++) {
    #$hunk = undef;
    $Pi = [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i]]} } ]->[0] //= $bmax+1;
    $Pi1 = ($i < $#$Xmatches) ? [ grep {$R < $_ } @{ $YPos->{$X->[$amin+$Xmatches->[$i+1]]} } ]->[0] : -1;
    $Pi1 //=  -1;
    #print STDERR ' $Pi1: ',$Pi1,' $Pi: ',$Pi,' $i: ',$i,"\n";
    
    if ($Pi > $Pi1 && $Pi1 > $R) {
      push @L, [$amin+$Xmatches->[$i+1],$bmin+$Pi1];
      #print STDERR 'hunk: ',$amin+$Xmatches->[$i+1],' ',$bmin+$Pi1,' $Pi1: ',$Pi1,' $i: ',$i,"\n";
      $R = $Pi1;
      $i++;
    } 
    elsif ($Pi <= $bmax) {
      push @L, [$amin+$Xmatches->[$i],$bmin+$Pi];
      #print STDERR 'hunk: ',$amin+$Xmatches->[$i],' ',$bmin+$Pi,' $Pi: ',$Pi,"\n"; 
      $R = $Pi;
    }
  }
  #print STDERR '$Xcurrent: ',$Xcurrent,' $Ycurrent: ',$Ycurrent,"\n";

  map([$_ => $_], 0 .. ($amin-1)),
        @L,
            map([$_ => ++$bmax], ($amax+1) .. $#$X);
}


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
