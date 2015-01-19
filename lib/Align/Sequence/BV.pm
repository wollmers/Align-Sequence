package Align::Sequence::BV;

use 5.008;
use strict;
use warnings;
our $VERSION = '0.01';

use Data::Dumper;

### test size of integer: print length  pack 'j', -1;" 8 for 64 bit, 4 for 32 bit
our $width = length(pack('j', -1)) * 8;

no warnings 'portable';

sub index_bits {
  my $b = shift;
  use integer;

  my $positions = {};
  $positions->{substr($b,$_,1)} |= 1 << ($_ % 64) for 0..length($b)-1;

  return $positions;
}

sub count_bits_64 {
  my $self = shift;
  my $bits = shift;

  $bits = ($bits & 0x5555555555555555) + (($bits & 0xaaaaaaaaaaaaaaaa) >> 1);
  $bits = ($bits & 0x3333333333333333) + (($bits & 0xcccccccccccccccc) >> 2);
  $bits = ($bits & 0x0f0f0f0f0f0f0f0f) + (($bits & 0xf0f0f0f0f0f0f0f0) >> 4);
  $bits = ($bits & 0x00ff00ff00ff00ff) + (($bits & 0xff00ff00ff00ff00) >> 8);
  $bits = ($bits & 0x0000ffff0000ffff) + (($bits & 0xffff0000ffff0000) >>16);
  return  ($bits & 0x00000000ffffffff) + (($bits & 0xffffffff00000000) >>32);
}

sub count_bits_32 {
  my $self = shift;
  my $bits = shift;

  $bits = ($bits & 0x55555555) + (($bits & 0xaaaaaaaa) >> 1);
  $bits = ($bits & 0x33333333) + (($bits & 0xcccccccc) >> 2);
  $bits = ($bits & 0x0f0f0f0f) + (($bits & 0xf0f0f0f0) >> 4);
  $bits = ($bits & 0x00ff00ff) + (($bits & 0xff00ff00) >> 8);
  return  ($bits & 0x0000ffff) + (($bits & 0xffff0000) >>16);
}

sub LLCS_64 {
  my ($self,$a,$b) = @_;

  use integer;

  my $positions;
  $positions->{substr($b,$_,1)} |= 1 << ($_ % 64) for 0..length($b)-1;

  my $v = ~0;

  for (0..length($a)-1) {
    my $p = $positions->{substr($a,$_,1)} // 0;
    my $u = $v & $p;
    #my $u = $v & ($positions->{substr($a,$_,1)} // 0); # slower
    $v = ($v + $u) | ($v - $u);
  }
  $v = ~$v;
  if (0) {
    my $n = length($b);
    print $a,"\n",$b,"\n",sprintf("%0${n}b",$v),"\n";
  }
  $v = ($v & 0x5555555555555555) + (($v & 0xaaaaaaaaaaaaaaaa) >> 1);
  $v = ($v & 0x3333333333333333) + (($v & 0xcccccccccccccccc) >> 2);
  $v = ($v & 0x0f0f0f0f0f0f0f0f) + (($v & 0xf0f0f0f0f0f0f0f0) >> 4);
  $v = ($v & 0x00ff00ff00ff00ff) + (($v & 0xff00ff00ff00ff00) >> 8);
  $v = ($v & 0x0000ffff0000ffff) + (($v & 0xffff0000ffff0000) >>16);
  $v = ($v & 0x00000000ffffffff) + (($v & 0xffffffff00000000) >>32);

  return $v;
}

sub match_vector {
  my ($a,$b,$b_positions) = @_;

  use integer;

  my $b_v = ~0;

  for (0..length($a)-1) {
    my $p = $b_positions->{substr($a,$_,1)} // 0;
    my $u = $b_v & $p;
    $b_v = ($b_v + $u) | ($b_v - $u);
  }
  $b_v = ~$b_v;
  if (0) {
    my $n = length($b);
    print $a,"\n",$b,"\n",sprintf("%0${n}b",$b_v),"\n";
  }

  return $b_v;
}

# nice try, but doesn't work
sub LCS2 {
  my ($self,$a,$b) = @_;

  use integer;

  my $b_positions = index_bits($b);
  my $a_positions = index_bits($a);

  my $b_v = match_vector($a,$b,$b_positions);
  my $a_v = match_vector($b,$a,$a_positions);

  if (1) {
    print $a,"\n";
    my $m = length($a);
    print scalar reverse(split(//,sprintf("%0${m}b",$a_v))),"\n";
    print $b,"\n";
    my $n = length($b);
    print scalar reverse(split(//,sprintf("%0${n}b",$b_v))),"\n";
  }
  my @a = match_list($a_v);
  my @b = match_list($b_v);
  return $self->sequences2hunks(\@a,\@b);
}

#print $j,' ',$bj,' ',sprintf("%0${m}b",$y),' ',sprintf("%0${m}b",$K),"\n";
##############################
# code adapted from Algorithm::Diff

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


sub LCS_64 {
  my ($ctx, $a, $b) = @_;

  use integer;
  no warnings 'portable'; # for 0xffffffffffffffff

  my $m = length($a);
  my $n = length($b);

  my $positions;
  $positions->{substr($a,$_,1)} |= 1 << ($_ % 64) for 0..$m-1;

  my $S = 2**$m-1;

  my $matchVector = [];
  my $thresh = [];
  my $links  = [];
  my $bj;


  for my $j (0..$n-1) {
    $bj = substr($b,$j,1);
    next unless (defined $positions->{$bj});
    my $y = $positions->{$bj} // 0;

    my $SS = ($S + ($S & $y)) | ($S & ~$y);
    my $K = ($S ^ $SS) & $S;

    #print $j,' ',$bj,' ',sprintf("%0${m}b",$y),' ',sprintf("%0${m}b",$K),"\n";
    while ($K > 0) {
      my $i;
      {
        no integer;
        $i = int(log($K)/log(2));
      }
      # find k such that thresh[k-1] < i <= thresh[k-1]
      my $k = 0;
        # optimization: most of the time this will be true
        if ( $k and $thresh->[$k] > $i and $thresh->[ $k - 1 ] < $i ) {
            $thresh->[$k] = $i;
        }
        else {
          $k = _replaceNextLargerWith( $thresh, $i, $k );
        }
        if (defined $k) {
          $links->[$k] = [ ( $k ? $links->[ $k - 1 ] : undef ), $i, $j ];
        }
      #$K -= 2**$i;
      $K = $K & ~2**$i; # clean the bit at position $i
    }
    $S = $SS;
  }

  if (@$thresh) {
    for ( my $link = $links->[$#$thresh] ; $link ; $link = $link->[0] ) {
      $matchVector->[ $link->[1] ] = [$link->[1],$link->[2]] if (defined $link->[2]);
    }
  }

  return [ grep { defined $_ } @$matchVector ];
}


sub match_list {
  my $bit_vector = shift;
  my @matches;
  while ($bit_vector > 0) {
    my $i;
    {
      no integer;
      $i = int(log($bit_vector)/log(2));
    }
    unshift @matches,$i;
    $bit_vector = $bit_vector & ~2**$i;
  }
  return @matches;
}

sub sequences2hunks {
  my $self = shift;
  my ($a, $b) = @_;

  return [ map { [ $a->[$_], $b->[$_] ] } 0..$#$a ];
}


sub _core_loop {}

sub LCS {
    my ($ctx, $a, $b) = @_;
    my ($amin, $amax, $bmin, $bmax) = (0, $#$a, 0, $#$b);

    while ($amin <= $amax and $bmin <= $bmax and $a->[$amin] eq $b->[$bmin]) {
        $amin++;
        $bmin++;
    }
    while ($amin <= $amax and $bmin <= $bmax and $a->[$amax] eq $b->[$bmax]) {
        $amax--;
        $bmax--;
    }

    my $h = $ctx->line_map(@$b[$bmin..$bmax]); # line numbers are off by $bmin

    return $amin + _core_loop($ctx, $a, $amin, $amax, $h) + ($#$a - $amax)
        unless wantarray;

    my @lcs = _core_loop($ctx,$a,$amin,$amax,$h);
    if ($bmin > 0) {
        $_->[1] += $bmin for @lcs; # correct line numbers
    }

    map([$_ => $_], 0 .. ($amin-1)),
        @lcs,
            map([$_ => ++$bmax], ($amax+1) .. $#$a);
}

1;

__END__

=head1 NAME

Align::Sequence::BV - Bit Vector (BV) implementation of the
                 Longest Common Subsequence (LCS) Algorithm

=head1 SYNOPSIS

  use Align::Sequence::BV;

  $alg = Align::Sequence::BV->new;
  @lcs = $alg->LCS(\@a,\@b);

=head1 ABSTRACT

Align::Sequence::BV implements Algorithm::Diff using bit vectors and
is faster in most cases, especially on strings with a length shorter
than the used wordsize of the hardware (32 or 64 bits).

=head1 DESCRIPTION

=head2 CONSTRUCTOR

=over 4

=item new()

Creates a new object which maintains internal storage areas
for the LCS computation.  Use one of these per concurrent
LCS() call.

=back

=head2 METHODS

=over 4


=item LCS(\@a,\@b)

Finds a Longest Common Subsequence, taking two arrayrefs as method
arguments.  In scalar context the return value is the length of the
subsequence.  In list context it yields a list of corresponding
indices, which are represented by 2-element array refs.  See the
L<Algorithm::Diff> manpage for more details.

=back

=head2 EXPORT

None by design.

=head1 SEE ALSO

Algorithm::Diff

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2014 by Helmut Wollmersdorfer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
