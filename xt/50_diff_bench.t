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
use LCS;
use LCS::Tiny;


use Benchmark qw(:all) ;
use Data::Dumper;


use Align::Sequence::BV;

my $LCS = LCS->new;
my $tiny = LCS::Tiny->new;

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



if (1) {

    cmpthese( 50_000, {
    #timethese( 50_000, {
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data)
        },
        'LCSidxXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data)
        },
        'align_bv' => sub {
            [ $align_bv->LCS_64(@data) ]
        },
        'LCS' => sub {
            [ $LCS->LCS(@data) ]
        },
        'tiny' => sub {
            [ $tiny->LCS(@data) ]
        },
        'align_bvi' => sub {
            [ $align_bv->LCS_64i(@data) ]
        },
        'align_bvb' => sub {
            [ $align_bv->LCS_64b(@data) ]
        },
    });

}
if (0) {

    cmpthese( 50_000, {
    #timethese( 50_000, {
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data2)
        },
        'LCSidxXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data2)
        },
        'align_bv' => sub {
            [ $align_bv->LCS_64(@data2) ]
        },
        #'align_LCS' => sub {
        #    [ $align_bv->LCS(@data) ]
        #},
        'align_bvi' => sub {
            [ $align_bv->LCS_64i(@data2) ]
        },
    });

}

