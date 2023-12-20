package ARFPiSerial;


sub BitBangSPI0_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for SCLK
    ## Input 2: Yet-to-be intialized GPIO Pin for MOSI
    ## Input 3: Yet-to-be intialized GPIO Pin for MISO
    ## Input 4: Yet-to-be intialized GPIO Pin for CS0
    ## Input 5: Yet-to-be intialized GPIO Pin for CS1
    ## Output: None
    ## This routine initilizes the SPI0 Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;

    system ("echo " . $SCLKpin . " >/sys/class/gpio/export");
    system ("echo " . $MOSIpin . " >/sys/class/gpio/export");
    system ("echo " . $MISOpin . " >/sys/class/gpio/export");
    system ("echo " . $CS0pin . " >/sys/class/gpio/export");
    system ("echo " . $CS1pin . " >/sys/class/gpio/export");

    system ("echo out >/sys/class/gpio/gpio" . $SCLKpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $MOSIpin . "/direction");
    system ("echo in >/sys/class/gpio/gpio" . $MISOpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS0pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS1pin . "/direction");

    system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $MOSIpin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS0pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS1pin . "/value");

}

sub BitBangSPI1_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for SCLK
    ## Input 2: Yet-to-be intialized GPIO Pin for MOSI
    ## Input 3: Yet-to-be intialized GPIO Pin for MISO
    ## Input 4: Yet-to-be intialized GPIO Pin for CS0
    ## Input 5: Yet-to-be intialized GPIO Pin for CS1
    ## Input 6: Yet-to-be intialized GPIO Pin for CS2
    ## Output: None
    ## This routine initilizes the SPI1 Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;
    my $CS2pin = shift;

    system ("echo " . $SCLKpin . " >/sys/class/gpio/export");
    system ("echo " . $MOSIpin . " >/sys/class/gpio/export");
    system ("echo " . $MISOpin . " >/sys/class/gpio/export");
    system ("echo " . $CS0pin . " >/sys/class/gpio/export");
    system ("echo " . $CS1pin . " >/sys/class/gpio/export");
    system ("echo " . $CS2pin . " >/sys/class/gpio/export");

    system ("echo out >/sys/class/gpio/gpio" . $SCLKpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $MOSIpin . "/direction");
    system ("echo in >/sys/class/gpio/gpio" . $MISOpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS0pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS1pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS2pin . "/direction");

    system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $MOSIpin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS0pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS1pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS2pin . "/value");

}

sub BitBangShiftReg_Setup {
    ## Input 1: Yet-to-be intialized GPIO Pin for Shift CLK
    ## Input 2: Yet-to-be intialized GPIO Pin for Shift Data
    ## Input 3: Yet-to-be intialized GPIO Pin for Shift Latch
    ## Input 4: Yet-to-be intialized GPIO Pin for CS0
    ## Input 5: Yet-to-be intialized GPIO Pin for CS1
    ## Input 6: Yet-to-be intialized GPIO Pin for CS2
    ## Input 6: Yet-to-be intialized GPIO Pin for CS3
    ## Output: None
    ## This routine initilizes the Shift Register Bus using Sysfs GPIO methods.
    my $ShCLKpin = shift;
    my $ShDATApin = shift;
    my $ShLATCHpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;
    my $CS2pin = shift;
    my $CS3pin = shift;

    system ("echo " . $ShCLKpin . " >/sys/class/gpio/export");
    system ("echo " . $ShDATApin . " >/sys/class/gpio/export");
    system ("echo " . $ShLATCHpin . " >/sys/class/gpio/export");
    system ("echo " . $CS0pin . " >/sys/class/gpio/export");
    system ("echo " . $CS1pin . " >/sys/class/gpio/export");
    system ("echo " . $CS2pin . " >/sys/class/gpio/export");
    system ("echo " . $CS3pin . " >/sys/class/gpio/export");

    system ("echo out >/sys/class/gpio/gpio" . $ShCLKpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $ShDATApin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $ShLATCHpin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS0pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS1pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS2pin . "/direction");
    system ("echo out >/sys/class/gpio/gpio" . $CS3pin . "/direction");

    system ("echo 0 >/sys/class/gpio/gpio" . $ShCLKpin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $ShDATApin . "/value");
    system ("echo 0 >/sys/class/gpio/gpio" . $ShLATCHpin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS0pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS1pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS2pin . "/value");
    system ("echo 1 >/sys/class/gpio/gpio" . $CS3pin . "/value");

}

sub BitBangSPIWrite {
    ## Input 1: Intialized GPIO Pin for SCLK
    ## Input 2: Intialized GPIO Pin for MOSI
    ## Input 3: Intialized GPIO Pin for CS
    ## Input 4: Data, Expects a Binary STRING
    ## Output: None
    ## This routine writes via SPI Protocol
    my $SCLKpin = shift;
    my $MOSIpin = shift;
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
        system ("echo " . $DataBits[$count] . " >/sys/class/gpio/gpio" . $MOSIpin . "/value");
        system ("echo 1 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    }
    system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");

}

sub BitBangSPIRead {
    ## Input 1: Intialized GPIO Pin for SCLK
    ## Input 2: Intialized GPIO Pin for MOSI
    ## Input 3: Intialized GPIO Pin for MISO
    ## Input 4: Intialized GPIO Pin for CS
    ## Input 5: Register to Read From
    ## Input 6: Number of Bits that need to be read
    ## Output: Binary Bit Stream of What is Read
    ## This routine writes via SPI Protocol
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;
    my $CSpin = shift;
    my $Register = shift;
    my $NumBitsToRead = shift;

    my $BinaryRegister = sprintf ("%b", $Register);
    my @RegisterBits = split(//, $BinaryRegister);

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
        system ("echo " . $RegisterBits[$count] . " >/sys/class/gpio/gpio" . $MOSIpin . "/value");
        system ("echo 1 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    }
    my @ReadData;
    for ($count = 0; $count < $NumBitsToRead; $count++) {
        $ReadData[ $count ] = "cat /sys/class/gpio/gpio" . $MISOpin . "/value";
        system ("echo 1 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
        system ("echo 0 >/sys/class/gpio/gpio" . $SCLKpin . "/value");
    }
    system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");

    return @ReadData;

}

sub BitBangShiftRegWrite {
    ## Input 1: Intialized GPIO Pin for Shift CLK
    ## Input 2: Intialized GPIO Pin for Shift Data
    ## Input 3: Intialized GPIO Pin for Shift Latch
    ## Input 4: Intialized GPIO Pin for CS0
    ## Input 5: Intialized GPIO Pin for CS1
    ## Input 6: Intialized GPIO Pin for CS2
    ## Input 6: Intialized GPIO Pin for CS3
    ## Input 7: Data to Send
    ## Output: None
    ## This routine initilizes the SPI0 Bus using Sysfs GPIO methods.

    my $ShCLKpin = shift;
    my $ShDATApin = shift;
    my $ShLATCHpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;
    my $CS2pin = shift;
    my $CS3pin = shift;
    my $Data = shift;

    my $BinaryData = sprintf ("%b", $Data);
    my @DataBits = split(//, $BinaryData);


}

sub BitBangSPI0_CleanUp {
    ## Input 1: Initialized GPIO Pin for SCLK
    ## Input 2: Initialized GPIO Pin for MOSI
    ## Input 3: Initialized GPIO Pin for MISO
    ## Input 4: Initialized GPIO Pin for CS0
    ## Input 5: Initialized GPIO Pin for CS1
    ## Output: None
    ## This routine initilizes the SPI0 Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;

    system ("echo " . $SCLKpin . " >/sys/class/gpio/unexport");
    system ("echo " . $MOSIpin . " >/sys/class/gpio/unexport");
    system ("echo " . $MISOpin . " >/sys/class/gpio/unexport");
    system ("echo " . $CS0pin . " >/sys/class/gpio/unexport");
    system ("echo " . $CS1pin . " >/sys/class/gpio/unexport");

}

sub BitBangSPI1_CleanUp {
    ## Input 1: Initialized GPIO Pin for SCLK
    ## Input 2: Initialized GPIO Pin for MOSI
    ## Input 3: Initialized GPIO Pin for MISO
    ## Input 4: Initialized GPIO Pin for CS0
    ## Input 5: Initialized GPIO Pin for CS1
    ## Input 6: Initialized GPIO Pin for CS2
    ## Output: None
    ## This routine initilizes the SPI0 Bus using Sysfs GPIO methods.
    my $SCLKpin = shift;
    my $MOSIpin = shift;
    my $MISOpin = shift;
    my $CS0pin = shift;
    my $CS1pin = shift;
    my $CS2pin = shift;

    system ("echo " . $SCLKpin . " >/sys/class/gpio/unexport");
    system ("echo " . $MOSIpin . " >/sys/class/gpio/unexport");
    system ("echo " . $MISOpin . " >/sys/class/gpio/unexport");
    system ("echo " . $CS0pin . " >/sys/class/gpio/unexport");
    system ("echo " . $CS1pin . " >/sys/class/gpio/unexport");
    system ("echo " . $CS2pin . " >/sys/class/gpio/unexport");

}

1;