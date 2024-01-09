package ARFPiGenericSerial;
use ET55930_6039_Environment;
use Data::Dumper;

sub BitBangSPI_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for SCLK
    ## Input 2: Yet-to-be intialized GPIO Pin for MOSI
    ## Input 3: Yet-to-be intialized GPIO Pin for MISO
    ## Output: None
    ## This routine initilizes a SPI Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;

    system( "echo " . $SCLKpin . " >/sys/class/gpio/export" );
    system( "echo " . $MOSIpin . " >/sys/class/gpio/export" );
    system( "echo " . $MISOpin . " >/sys/class/gpio/export" );
    system("sudo chmod -R 777 /sys/class/gpio/gpio*");

    system( "echo out >/sys/class/gpio/gpio" . $SCLKpin . "/direction" );
    system( "echo out >/sys/class/gpio/gpio" . $MOSIpin . "/direction" );
    system( "echo in >/sys/class/gpio/gpio" . $MISOpin . "/direction" );

    system( "echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value" );
    system( "echo 0 >/sys/class/gpio/gpio" . $MOSIpin . "/value" );

}

sub BitBangSPI_CleanUp {
    ## Input 1: Intialized GPIO Pin for SCLK
    ## Input 2: Intialized GPIO Pin for MOSI
    ## Input 3: Intialized GPIO Pin for MISO
    ## Output: None
    ## This routine cleans up a SPI Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;

    system( "echo " . $SCLKpin . " >/sys/class/gpio/unexport" );
    system( "echo " . $MOSIpin . " >/sys/class/gpio/unexport" );
    system( "echo " . $MISOpin . " >/sys/class/gpio/unexport" );
}

sub BitBangShiftReg_Setup {
    ## Input: None
    ## Output: Shift Register Bus in the Form of [CLK, Data, Latch]
    ## This routine initilizes a Shift Register Bus using Sysfs GPIO methods.

    system( "echo " . $SCLK_ShiftReg . " >/sys/class/gpio/export" );
    system( "echo " . $Data_ShiftReg . " >/sys/class/gpio/export" );
    system( "echo " . $Latch_ShiftReg . " >/sys/class/gpio/export" );
    system("sudo chmod -R 777 /sys/class/gpio/gpio*");

    system( "echo out >/sys/class/gpio/gpio" . $SCLK_ShiftReg . "/direction" );
    system( "echo out >/sys/class/gpio/gpio" . $Data_ShiftReg . "/direction" );
    system( "echo out >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/direction" );

    system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ShiftReg . "/value" );
    system( "echo 0 >/sys/class/gpio/gpio" . $Data_ShiftReg . "/value" );
    system( "echo 0 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );

    return ( [ $SCLK_ShiftReg, $Data_ShiftReg, $Latch_ShiftReg ] );
}

sub BitBangShiftReg_CleanUp {
    ## Input: None
    ## Output: None
    ## This routine cleans up a shift register bus.

    system( "echo " . $SCLK_ShiftReg . " >/sys/class/gpio/unexport" );
    system( "echo " . $Data_ShiftReg . " >/sys/class/gpio/unexport" );
    system( "echo " . $Latch_ShiftReg . " >/sys/class/gpio/unexport" );
}

sub BitBangSPIWrite {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Input 3: Data in the form of a Binary STRING
    ## Output: None
    ## This routine writes via SPI Protocol
    my @SPIBus = ( shift, shift, shift );
    my $CSpin  = shift;
    my $Data   = shift;

    my @DataBits = split( //, $Data );

    ##SPI Bus Write Order of Operations:
    # CS Pulls Low
    # First Data Bit is Sent and Held
    # Rising Clock Edge Latches the First Bit
    # Clock Edge Drops
    # Next Data Bit is Sent and Held
    # Rising Clock Edge Latches Next Bit
    # Clock Edge Falls
    # Etc Etc
    # CS Pulls High after Final Clock Edge Falls
    system( "echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value" );
    for ( my $count = 0 ; $count < scalar(@DataBits) ; $count++ ) {
        system( "echo " . $DataBits[$count] . " >/sys/class/gpio/gpio" . $SPIBus[1] . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
        system( "echo 0 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
    }
    system( "echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value" );

}

sub BitBangSPIRead {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Input 5: Register to Read From in the form of a Binary STRING
    ## Input 6: Number of Bits that need to be read
    ## Output: Binary Bit Stream of What is Read
    ## This routine reads via SPI Protocol
    my @SPIBus        = ( shift, shift, shift );
    my $CSpin         = shift;
    my $Register      = shift;
    my $NumBitsToRead = shift;

    my @RegisterBits = split( //, $Register );

    ##SPI Bus Read Order of Operations:
    # CS Pulls Low
    # First Data Bit is Sent and Held
    # Rising Clock Edge Latches the First Bit
    # Clock Edge Drops
    # Next Data Bit is Sent and Held
    # Rising Clock Edge Latches Next Bit
    # Clock Edge Falls
    # Etc Etc, Writing until the Register desired to be read is completely written
    # Read Data in the Same Fashion as Writing
    # CS Pulls High after Final Clock Edge Falls
    system( "echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value" );
    for ( my $count = 0 ; $count < scalar(@RegisterBits) ; $count++ ) {
        system( "echo " . $RegisterBits[$count] . " >/sys/class/gpio/gpio" . $SPIBus[1] . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
        system( "echo 0 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
    }
    my @ReadData;
    for ( $count = 0 ; $count < $NumBitsToRead ; $count++ ) {
        $ReadData[$count] = "cat /sys/class/gpio/gpio" . $SPIBus[2] . "/value";
        system( "echo 1 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
        system( "echo 0 >/sys/class/gpio/gpio" . $SPIBus[0] . "/value" );
    }
    system( "echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value" );

    return @ReadData;
}

sub BitBangShiftRegShiftNoLatch {
    ## Input 1: Data to be shifted, in the form of a REFERENCE to a binary ARRAY, LSB is Index 0.
    ## Output: None
    ## This routine shifts data through a shift register bus
    my $ReferenceToDataBits = shift;

    ##Shift Register Write Order of Operations:
# Latch Should Be Held Low
# First Data Bit is Sent and Held
# Rising Clock Edge Latches the First Bit into the first bit of the Shift Register
# Clock Edge Drops
# Next Data Bit is Sent and Held
# Rising Clock Edge Latches Next Bit into the first bit of the Shift Register, original bit is sent on its way to the next bit
# Clock Edge Falls
# Etc Etc
# Rising Edge of the Latch Latches ALL of the bit in the Shift Register to the Storage (Output) Register
    system( "echo 0 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );
    for ( my $count = 0 ; $count < scalar( @{$ReferenceToDataBits} ) ; $count++ ) {
        system( "echo " . $ReferenceToDataBits->[$count] . " >/sys/class/gpio/gpio" . $Data_ShiftReg . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ShiftReg . "/value" );
        system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ShiftReg . "/value" );
    }
    system( "echo 1 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );

}

1;
