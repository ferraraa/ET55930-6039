#/usr/bin/perl

use lib "./";
use strict;
use warnings;
use Data::Dumper;

#use ARFPiGPIO;
#use ARFPiGenericSerial;
use ET55930_6039_Environment;

print Dumper($SCLK_ABUS);
#my @PiSPI0 = ARFPiGenericSerial::BitBangSPI_Setup ( $SCLK_ABUS, $MOSI_ABUS, $MISO_ABUS );
#ARFPiGPIO::InitializeGPIO( $CS_ABUS, "Out", 1);


#ARFPiGenericSerial::BitBangSPI_CleanUp ( @PiSPI0 );
#ARFPiGPIO::UninitializeGPIO( $CS_ABUS );