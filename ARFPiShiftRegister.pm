package ARFPiShiftRegister;

use ET55930_6039_Environment;
use ARFPiGenericSerial;
use ARFPiGPIO;
use Data::Dumper;

sub BitBangShiftRegistersSetup {
    ## Input: None
    ## Output: None
    ## This routine sets up the SPI1 Bus for the DACs
    our @ShiftRegBus = ARFPiGenericSerial::BitBangShiftReg_Setup();
    ARFPiGPIO::InitializeGPIO( $EncodedCS0_ShiftReg, "out", 0 );
    ARFPiGPIO::InitializeGPIO( $EncodedCS1_ShiftReg, "out", 0 );
    ARFPiGPIO::InitializeGPIO( $EncodedCS2_ShiftReg, "out", 0 );
    ARFPiGPIO::InitializeGPIO( $EncodedCS3_ShiftReg, "out", 0 );

    # Make sure Decoder is Disabled, sets all outputs to logic HIGH
    ARFPiGPIO::WriteGPIO( $Latch_ShiftReg, 0 );
}

sub BitBangShiftRegistersCleanUp {
    ## Input: None
    ## Output: None
    ## This routine sets up the SPI1 Bus for the DACs
    ARFPiGenericSerial::BitBangShiftReg_CleanUp();
    ARFPiGPIO::UninitializeGPIO($EncodedCS0_ShiftReg);
    ARFPiGPIO::UninitializeGPIO($EncodedCS1_ShiftReg);
    ARFPiGPIO::UninitializeGPIO($EncodedCS2_ShiftReg);
    ARFPiGPIO::UninitializeGPIO($EncodedCS3_ShiftReg);

}

sub BitBangShiftRegisterWrite {
    ## Input 1: Shift Register ... Register. In the form of "ET1"
    # The Prefix to the Schematic/Physical Net Names for driving the Shift Register
    # This net name will be decoded into the proper GPIO Levels
    ## Input 2: Data to be sent in the form of a REFERENCE to a binary ARRAY, LSB is Index 0
    # Be careful. Refer to the truth tables
    ## Output: None

    my $ShiftRegRegister = shift;
    my $ReferenceToData             = shift;
	
    my @GPIORegister;
    if ( $ShiftRegRegister eq "ET1" ) {
        @GPIORegister = @ShiftReg_ET1;
    }
    elsif ( $ShiftRegRegister eq "ET2" ) {
        @GPIORegister = @ShiftReg_ET2;
    }
    elsif ( $ShiftRegRegister eq "SrcOut" ) {
        @GPIORegister = @ShiftReg_SrcOut;
    }
    elsif ( $ShiftRegRegister eq "YIGDiv" ) {
        @GPIORegister = @ShiftReg_YIGDiv;
    }
    elsif ( $ShiftRegRegister eq "BotGr3" ) {
        @GPIORegister = @ShiftReg_BotGrp3;
    }
    elsif ( $ShiftRegRegister eq "RFPathDCPower_ABUS" ) {
        @GPIORegister = @ShiftReg_RFPathDC;
    }
    elsif ( $ShiftRegRegister eq "TopGr2" ) {
        @GPIORegister = @ShiftReg_TopGrp2;
    }
    elsif ( $ShiftRegRegister eq "TopGr1" ) {
        @GPIORegister = @ShiftReg_TopGrp1;
    }
    elsif ( $ShiftRegRegister eq "SrcOut_PulseMod_Delay" ) {
        @GPIORegister = @ShiftReg_PulseModDelay;
    }
    elsif ( $ShiftRegRegister eq "MechStepAtten" ) {
        @GPIORegister = @ShiftReg_MechStepAtten;
    }
    else {
        @GPIORegister = @ShiftReg_MechStepAtten;
    }

    # ALL Shift Registers are 'Listening' ... as in their shift registers will all be loaded
    # with the data that is sent along the bus. ONLY the desired Register of Shift Registers
    # will have the data that is loaded into its shift register will be Latched to the Storage
    # (Output) Register. Yikes. Look at the timing diagram for the SN74HC595B Shift Register.
    # Not only that. The 74HC154BQ is used to decode the RCLKs for the Shift Registers. It's
    # outputs are 'Active Low'. All outputs are generally HIGH; the activated, decoded output
    # is a logic LOW. Not only that, when the chip is disabled ALL outputs are logic HIGH.
    # Given that the rising edge of the RCLK is what Latches the data from the Shift to
    # Storage (Output) Register, before we send the bits out to ALL of the Shift Register
    # Registers, we first decode out the desired Register's RCLK to LOW. All other RCLKs remain
    # HIGH. Then we shift the data out. Upon completion of the shifting, we disable the Decoder.
    # Disabling the Decoder sends all of the outputs to logic HIGH, thus creating a rising edge
    # on the desired RCLK.

    # Make sure the Latch Pin is High, Rising Edge Latches Bits from the Shift Reg to Storage (Output) Register
    system( "echo 0 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );    #Disabling Decoder sends all outputs high

    # Decode Shift Register RCLK
    system( "echo " . $GPIORegister[0] . " >/sys/class/gpio/gpio" . $EncodedCS0_ShiftReg . "/value" );
    system( "echo " . $GPIORegister[1] . " >/sys/class/gpio/gpio" . $EncodedCS1_ShiftReg . "/value" );
    system( "echo " . $GPIORegister[2] . " >/sys/class/gpio/gpio" . $EncodedCS2_ShiftReg . "/value" );
    system( "echo " . $GPIORegister[3] . " >/sys/class/gpio/gpio" . $EncodedCS3_ShiftReg . "/value" );

    # Enabling the Decoder will send the above decoded RCLK pin Low, in prep for the rising, Latching RCLK edge
    system( "echo 1 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );

    # Shift the bits out, LSB is Index ZERO! in the String
    ARFPiGenericSerial::BitBangShiftRegShiftNoLatch( $ReferenceToData );

    # Rising Edge of the RCLK Latches the bits to the output. Done by disabling the Decoder
    system( "echo 0 >/sys/class/gpio/gpio" . $Latch_ShiftReg . "/value" );

    # Done
}

sub BitBangShiftRegisterAllZeros {
	my @AllZeroArray = [(0) x 32];
	for (my $count = 0; $count < scalar(@ShiftRegNameArray); $count++) {
		BitBangShiftRegisterWrite($ShiftRegNameArray[$count], \@AllZeroArray);
	}
	
}

1;
