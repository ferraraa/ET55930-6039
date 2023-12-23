#/usr/bin/perl

use lib "./";
use strict;
use Config qw(myconfig config_sh config_vars);
use Data::Dumper;

use GPIO;
use ARFPiGenericSerial;
use ABUS;


my @PiSPI0 = ARFPiGenericSerialSerial::BitBangSPI_Setup ( $SCLK_ABUS, $MOSI_ABUS, $MISO_ABUS );
ARFPiGPIO::InitializeGPIO( $CS_ABUS, "Out", 1);


ARFPiGenericSerialSerial::BitBangSPI_CleanUp ( @PiSPI0 );
ARFPiGPIO::UninitializeGPIO( $CS_ABUS );