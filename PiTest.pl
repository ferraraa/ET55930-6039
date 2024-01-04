#/usr/bin/perl

use lib "./";
use strict;
use Config qw(myconfig config_sh config_vars);

#use Data::Dumper;

use GPIO;
use ARFPiSerial;

# GPIO::InitializeGPIO ( 4, "out", 1 ); #LDAC DAC A
# GPIO::InitializeGPIO ( 25, "out", 1 ); #LDAC DAC B
# GPIO::InitializeGPIO ( 24, "out", 1 ); #LDAC DAC C
# GPIO::InitializeGPIO ( 6, "out", 1 ); #CS0 Encoded Shift Registers
# GPIO::InitializeGPIO ( 5, "out", 1 ); #CS1Encoded Shift Registers
# GPIO::InitializeGPIO ( 22, "out", 1 ); #CS2 Encoded Shift Registers
# GPIO::InitializeGPIO ( 27, "out", 1 ); #CS3 Encoded Shift Registers

# GPIO::UninitializeGPIO ( 4 ); #LDAC DAC A
# GPIO::UninitializeGPIO ( 25 ); #LDAC DAC B
# GPIO::UninitializeGPIO ( 24 ); #LDAC DAC C
# GPIO::UninitializeGPIO ( 6 ); #CS0 Encoded Shift Registers
# GPIO::UninitializeGPIO ( 5 ); #CS1Encoded Shift Registers
# GPIO::UninitializeGPIO ( 22 ); #CS2 Encoded Shift Registers
# GPIO::UninitializeGPIO ( 27 ); #CS3 Encoded Shift Registers

#ARFPiSerial::BitBangSPI0_Setup ( 11 , 10 , 9 , 8 , 7 );
ARFPiSerial::BitBangSPI1_Setup( 21, 20, 19, 18, 17, 16 );
my $clockcount = 0;
my $temp       = <>;
while ( $clockcount < 1000 ) {
    ARFPiSerial::BitBangSPIWrite( 21, 20, 18, 314 );
    $clockcount++;

}
ARFPiSerial::BitBangSPI1_CleanUp( 21, 20, 19, 18, 17, 16 );
