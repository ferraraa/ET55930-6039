#/usr/bin/perl

use lib "./";
use Data::Dumper;

#use System::Info;
use ARFConvert;
use ARFPiAD3552R;
include("ET55930_6039_Environment.pm");
our $SCLK_ABUS;

my $Data = 314;

print Dumper($SCLK_ABUS);

#ARFPiAD3552R::BitBangDACOutput("A0",$Data,0);

