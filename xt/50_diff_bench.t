#!perl
use 5.010;
use open qw(:locale);
use strict;
use warnings;
use utf8;

use lib qw(../lib/);

#use Test::More;

use Algorithm::Diff;
use Algorithm::Diff::XS;
#use Algorithm::LCS;

use Benchmark qw(:all) ;
use Data::Dumper;

use Align::Sequence;
use Align::Sequence::BV;

my $align = Align::Sequence->new;

my $align_bv = Align::Sequence::BV->new;

#my $A_LCS = Algorithm::LCS->new();

my @data = (
  [split(//,'Chrerrplzon')],
  [split(//,'Choerephon')]
);

my @data2 = (
  [split(//,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY')],
  [split(//, 'bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')]
);

#my @data = (
#  [split(//,'rerrplz')],
#  [split(//,'oereph')]
#);


#print 'adiff: ',Dumper([Algorithm::Diff::compact_diff(@data)]),"\n";
#print 'adiffxs: ',Dumper([Algorithm::Diff::XS::compact_diff(@data)]),"\n";
#print 'LCSidxXS: ',Dumper([Algorithm::Diff::XS::LCSidx(@data)]),"\n";

=comment

my $idx = [Algorithm::Diff::XS::LCSidx(@data)];
print join('',@{$data[0]}),"\n";
print join(' ',@{$idx->[0]}),"\n";
print join('',@{$data[0]}[ @{$idx->[0]} ]),"\n";
print join('',@{$data[1]}),"\n";
print join(' ',@{$idx->[1]}),"\n";
print join('',@{$data[1]}[ @{$idx->[1]} ]),"\n";

=cut

sub align {
  my ($a,$b) = @_;
  my $idx = [Algorithm::Diff::XS::LCSidx($a,$b)];
  my $imax = @{$idx->[0]};
  my $jmax = @{$idx->[1]};
  my $i;
  my $j;
  my $ai;
  my $bi;
  my $aimax = @{$a};
  my $bimax = @{$b};
  my $ar;
  my $br;

  while ($i < $imax && $j < $jmax) {}
}

=comment

if (0) {

    my @dataL = ([qw/a b d/ x 50], [qw/b a d c/ x 50]);
    cmpthese( 500, {
        'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@dataL)
        },
        'LCSidxXS' => sub {
            Algorithm::Diff::XS::LCSidx(@dataL)
        },
        'lcs_idx2' => sub {
             $align->LCSidx(@dataL)
        },
        'A_LCS' => sub {
            [ $A_LCS->LCS(@dataL) ]
        },
        'align' => sub {
            [ $align->align(@dataL) ]
        },
        'align2' => sub {
            [ $align->align2(@dataL) ]
        },
        'align_bv' => sub {
            [ $align_bv->LCS_64(@dataL) ]
        },
    });
}

if (0) {

    cmpthese( 10_000, {
        'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data2)
        },
        'LCSidxXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data2)
        },
        'lcs_idx2' => sub {
             $align->LCSidx(@data2)
        },
        'A_LCS' => sub {
            [ $A_LCS->LCS(@data2) ]
        },
        'align' => sub {
             $align->align(@data2)
        },
        'align2' => sub {
             $align->align2(@data2)
        },
        'align_bv' => sub {
            [ $align_bv->LCS_64(@data2) ]
        },
    });
}

=cut

if (1) {

    cmpthese( 50_000, {
    #timethese( 50_000, {
       # 'cdiff' => sub {
       #     Algorithm::Diff::compact_diff(@data)
       # },
       # 'cdiffXS' => sub {
       #     Algorithm::Diff::XS::compact_diff(@data)
       # },
       # 'sdiff' => sub {
       #     Algorithm::Diff::sdiff(@data)
       # },
       # 'sdiffXS' => sub {
       #     Algorithm::Diff::XS::sdiff(@data)
       # },
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data)
        },
        'LCSidxXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data)
        },
        #'fast_sdiff' => sub {
        #    fast_sdiff(@data)
        #},
        #'lcs2hunks' => sub {
        #     $align->lcs2hunks(@data)
        #},
        #'lcs_greedy' => sub {
        #     $align->align(@data)
        #},
        #'lcs_greedy2' => sub {
        #     $align->align2(@data)
        #},
        #'lcs_idx2' => sub {
        #     $align->LCSidx(@data)
        #},
        #'align' => sub {
        #     $align->align(@data)
        #},
        #'align2' => sub {
        #     $align->align2(@data)
        #},
        #'A_LCS' => sub {
        #    [ $A_LCS->LCS(@data) ]
        #},
        'align_bv' => sub {
            [ $align_bv->LCS_64(@data) ]
        },
        'align_LCS' => sub {
            [ $align_bv->LCS(@data) ]
        },
        'align_bvi' => sub {
            [ $align_bv->LCS_64i(@data) ]
        },
    });

}

use POSIX qw//;

  sub fast_sdiff {
    my $x = shift;
    my $y = shift;
    my $keyfunc = shift;
    my @keyargs = @_;
    my @cdiff;

    if ($keyfunc) {
      my @dx = map { $keyfunc->($_, @keyargs) } @$x;
      my @dy = map { $keyfunc->($_, @keyargs) } @$y;
      @cdiff = Algorithm::Diff::XS::compact_diff(\@dx, \@dy);
    } else {
      @cdiff = Algorithm::Diff::XS::compact_diff($x, $y);
    }

    _compact_diff_to_sdiff($x, $y, @cdiff);
  }

  sub _compact_diff_to_sdiff {
    my ($a, $b, @cdiff) = @_;
    my $MIN = -(POSIX::DBL_MAX);
    my @temp;
    my $add = sub {
      my ($op, $ax, $bx, $count) = @_;
      push @temp, [$op, $ax + $_, $bx + $_] for 0 .. $count - 1;
    };

    for (my $ix = 0; $ix < @cdiff - 2; $ix += 2) {
      my ($a_from, $b_from, $a2_from, $b2_from) =
        @cdiff[ $ix .. $ix + 3 ];

      my $a_len = ($a2_from - 1) - $a_from + 1;
      my $b_len = ($b2_from - 1) - $b_from + 1;

      if ($ix & 2) {
        # modified
        if ($a_from == $a2_from) {
          # addition
          $add->('+', $MIN, $b_from, $b_len);
        } elsif ($b_from == $b2_from) {
          # removal
          $add->('-', $a_from, $MIN, $a_len);
        } else {
          # change
          if ($a_len < $b_len) {
            $add->('c', $a_from, $b_from, $a_len);
            $add->('+', $MIN, $b_from + $a_len, $b_len - $a_len);
          } elsif ($a_len > $b_len) {
            $add->('c', $a_from, $b_from, $b_len);
            $add->('-', $a_from + $b_len, $MIN, $a_len - $b_len);
          } else {
            $add->('c', $a_from, $b_from, $a_len);
          }
        }
      } else {
        # unchanged
        $add->('u', $a_from, $b_from, $a_len);
      }
    }

    $_->[1] = $_->[1] >= 0 ? $a->[$_->[1]] : '' for @temp;
    $_->[2] = $_->[2] >= 0 ? $b->[$_->[2]] : '' for @temp;
    @temp;
  }

=result





=cut

