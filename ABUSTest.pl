#/usr/bin/perl
use lib "../../perl5/";
use lib "./";
use strict;
use warnings;
use ET55930_6039_Environment;
use Bit::Vector;
use Data::Dumper;
use ARFPiGPIO;
use ARFPiGenericSerial;
use ABUS;
use ARFConvert;



my @PiSPI0 = ARFPiGenericSerial::BitBangSPI_Setup ( $SCLK_ABUS, $MOSI_ABUS, $MISO_ABUS );
ARFPiGPIO::InitializeGPIO( $CS_ABUS, "out", 1);
my @ABUSData = ABUS::BitBangABUSRead ( @PiSPI0, $CS_ABUS );
ARFPiGenericSerial::BitBangSPI_CleanUp ( @PiSPI0 );
ARFPiGPIO::UninitializeGPIO( $CS_ABUS );

print Dumper(@ABUSData);