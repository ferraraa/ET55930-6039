package ARFPiGenericSerial;


sub BitBangSPI_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for SCLK
    ## Input 2: Yet-to-be intialized GPIO Pin for MOSI
    ## Input 3: Yet-to-be intialized GPIO Pin for MISO
    ## Output: SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## This routine initilizes a SPI Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;

    system ("echo " . $SCLKpin . " >/sys/class/gpio/export");
    system ("echo " . $MOSIpin . " >/sys/class/gpio/export");
    system ("echo " . $MISOpin . " >/sys/class/gpio/export");

    system ("echo out >/sys/class/gpio/gpio" . $SCLKpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $MOSIpin . "/direction");
    system ("echo in >/sys/class/gpio/gpio" . $MISOpin . "/direction");

    system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $MOSIpin . "/value");
	
    return [ $SCLKpin , $MOSIpin , $MISOpin ];
}

sub BitBangSPI_CleanUp {
    ## Input 1: SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Output: None
    ## This routine cleans up a SPI Bus using Sysfs GPIO methods.
    my @SPIBus = shift;
	print Dumper($SPIBus[0]);
	
	print Dumper($SPIBus[1]);
	
	print Dumper($SPIBus[2]);
    system ("echo " . $SPIBus[ 0 ] . " >/sys/class/gpio/unexport");
    system ("echo " . $SPIBus[ 1 ] . " >/sys/class/gpio/unexport");
    system ("echo " . $SPIBus[ 2 ] . " >/sys/class/gpio/unexport");
}

sub BitBangShiftReg_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for Shift CLK
    ## Input 2: Yet-to-be intialized GPIO Pin for Shift Data
    ## Input 3: Yet-to-be intialized GPIO Pin for Shift Latch
    ## Output: Shift Register Bus in the Form of [CLK, Data, Latch]
    ## This routine initilizes a Shift Register Bus using Sysfs GPIO methods.
    my $ShCLKpin = shift;
    my $ShDATApin = shift;
    my $ShLATCHpin = shift;

    system ("echo " . $ShCLKpin . " >/sys/class/gpio/export");
    system ("echo " . $ShDATApin . " >/sys/class/gpio/export");
    system ("echo " . $ShLATCHpin . " >/sys/class/gpio/export");

    system ("echo out >/sys/class/gpio/gpio" . $ShCLKpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $ShDATApin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $ShLATCHpin . "/direction");

    system ("echo 0 >/sys/class/gpio/gpio" . $ShCLKpin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $ShDATApin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $ShLATCHpin . "/value");

    return ([ $ShCLKpin , $ShDATApin , $ShLATCHpin ]);
}

sub BitBangShiftReg_CleanUp {
    ## Input 1: Shift Register Array in the form of [CLK, Data, Latch]
    ## Output: None
    ## This routine cleans up a shift register bus.
    my @ShiftRegBus = shift;

    system ("echo " . $ShiftRegBus[ 0 ] . " >/sys/class/gpio/unexport");
    system ("echo " . $ShiftRegBus[ 1 ] . " >/sys/class/gpio/unexport");
    system ("echo " . $ShiftRegBus[ 2 ] . " >/sys/class/gpio/unexport");
}

sub BitBangSPIWrite {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Input 3: Data in the form of a Binary STRING
    ## Output: None
    ## This routine writes via SPI Protocol
    my @SPIBus = shift;
    my $CSpin = shift;
    my $Data = shift;

    my @DataBits = split(//, $Data);

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
    system ("echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value");
    for (my $count = 0; $count < scalar(@DataBits); $count++) {
        system ("echo " . $DataBits[$count] . " >/sys/class/gpio/gpio" . $SPIBus[ 1 ] . "/value");
        system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
    }
    system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");

}

sub BitBangSPIRead {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Input 5: Register to Read From in the form of a Binary STRING
    ## Input 6: Number of Bits that need to be read
    ## Output: Binary Bit Stream of What is Read
    ## This routine reads via SPI Protocol
    my @SPIBus = shift;
    my $CSpin = shift;
    my $Register = shift;
    my $NumBitsToRead = shift;

    my @RegisterBits = split(//, $Register);

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
    system ("echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value");
    for (my $count = 0; $count < scalar(@RegisterBits); $count++) {
        system ("echo " . $RegisterBits[$count] . " >/sys/class/gpio/gpio" . $SPIBus[ 1 ] . "/value");
        system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
    }
    my @ReadData;
    for ($count = 0; $count < $NumBitsToRead; $count++) {
        $ReadData[ $count ] = "cat /sys/class/gpio/gpio" . $SPIBus[ 2 ] . "/value";
        system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
    }
    system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");

    return @ReadData;
}

sub BitBangShiftRegShiftNoLatch {
    ## Input 1: Initialized Shift Register Bus Array in the form of [CLK, Data, Latch]
    ## Input 2: Data to be shifted, in the form of a binary string.
    ## Output: None
    ## This routine shifts data through a shift register bus
    my @ShiftRegBus = shift;
    my $Data = shift;
    
    my @DataBits = split(//, $Data);
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
    system ("echo 0 >/sys/class/gpio/gpio" . $ShiftRegBus [ 2 ] . "/value");
    for (my $count = 0; $count < scalar(@DataBits); $count++) {
        system ("echo " . $DataBits[$count] . " >/sys/class/gpio/gpio" . $ShiftRegBus[ 1 ] . "/value");
        system ("echo 1 >/sys/class/gpio/gpio" . $ShiftRegBus[ 0 ] . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $ShiftRegBus[ 0 ] . "/value");
    }
    system ("echo 1 >/sys/class/gpio/gpio" . $ShiftRegBus [ 2 ] . "/value");

}







1;