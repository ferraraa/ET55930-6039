#/usr/bin/perl

use lib "./";
use Data::Dumper;
#use System::Info;
use ET55930_6039_Environment;
use ARFConvert;
use ARFPiAD3552R;


my $Data = 314;

print Dumper($SCLK_ABUS);

ARFPiAD3552R::BitBangDACOutput("A0",$Data,0);


