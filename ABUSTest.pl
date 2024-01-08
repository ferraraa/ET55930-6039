#/usr/bin/perl
use lib "./";
use strict;
use warnings;
use ET55930_6039_Environment;
use Data::Dumper;
use ARFPiGPIO;
use ARFPiGenericSerial;
use ABUS;
use ARFConvert;

#my @PiSPI0 = ARFPiGenericSerial::BitBangSPI_Setup ( $SCLK_ABUS, $MOSI_ABUS, $MISO_ABUS );
#ARFPiGPIO::InitializeGPIO( $CS_ABUS, "out", 1);
#my @ABUSData = ABUS::BitBangABUSADCRead ( \@PiSPI0, $CS_ABUS );
#ARFPiGenericSerial::BitBangSPI_CleanUp ( @PiSPI0 );
#ARFPiGPIO::UninitializeGPIO( $CS_ABUS );
my $test = "ET1";

#print Dumper( $ABUSRegisterHashArray[40]{$test});
#print Dumper( $ABUSRegisterHashArray[40]{$test}[0]);

#print Dumper( $ABUSRegisterHashArray[40]{SrcOut});
#print Dumper( @EnableHashArray);
#print Dumper( $PathIDRegisterHashArray[0]{$test}[0]);
