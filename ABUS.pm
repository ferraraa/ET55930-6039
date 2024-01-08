package ABUS;
use ET55930_6039_Environment;
use ARFPiShiftRegister;
use ARFConvert;
use Data::Dumper;

sub BitBangABUSADCRead {
    ## Input: None
    ## Output: Raw ADC Data
    ## This routine writes via SPI Protocol

    my $ABUSReadCount;
    my $count;
    my @ABUSDataBits;
    my @ABUSADCCodes;
    my $ABUSBitString;

    # Perform Three ABUS Reads
    for ( $ABUSReadCount = 0 ; $ABUSReadCount < 3 ; $ABUSReadCount++ ) {
        ##ABUS ADC Read Order of Operations:
        # SCLK and CS Should Start HIGH
        # CS Pulls LOW, A-to-D Conversion Starts
        # MISO Pin Is Set to LOW By ADC, can be ignored
        # Falling edge of SCLK Sets Next Bit out of ADC, there are three more LOWs. can be ignored
        # 16 Falling Edges will generate the 16 bits from the ADC. MSB is first.
        # CS Pulls High after Final Rising Clock Edge
        system( "echo 1 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );

        system( "echo 0 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );    # Conversion Starts
                                                                         # MISO is Set Low, Ignore

        system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );

        # MISO is Low, Again ... Ignore

        system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );

        # MISO is Low, Again ... Ignore

        system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );

        # MISO is Low, Again ... Ignore

        for ( $count = 0 ; $count < 16 ; $count++ ) {
            system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
            $ABUSDataBits[$count] = system( "cat /sys/class/gpio/gpio" . $MISO_ABUS . "/value >> /dev/null" );
            system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        }

        # Done Reading, Set CS and SCLK High
        system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        system( "echo 1 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );

        # Convert Read Binary Data to Decimal
        $ABUSBitString = join( "", @ABUSDataBits ); #MSB Is Index ZERO!
        $ABUSADCDecimalCodes[$ABUSReadCount] = ARFConvert::BinaryToDecimal($ABUSBitString);
    }

    # Throw away first ABUS Reading, Average the last two
    my $AvgABUSDecimalCode       = ( $ABUSADCDecimalCodes[1] + $ABUSADCDecimalCodes[2] ) / 2;

    return $AvgABUSDecimalCode;
}

sub BitBangABUSNodeRead {

    my $ABUSNodeHash = shift;

    ### Read In ALL Current Shift Register States, Mask Current States with Needed States for ABUS Node.
    my @fileHANDLEArray;
    my $CurrentRegState;
    my @CurrentRegStateArray;
    my @CurrentRegStateHashArray;
    
    while ( $CurrentRegState = <$CurrentRegStateFileHANDLE> ) {

        # Read Current State of Register Line by Line
        # First Value is the Register Name
        # Next 32 Values are each of the Register Bits, LSB is Index ZERO! Closest to Register Name
		chomp($CurrentRegState);
        my @CurrentRegStateArray = split( "\t", $CurrentRegState );        
		my $CurrentReg = shift(@CurrentRegStateArray);
		my @NewRegStateArray;
        # Mask the Current Register State with what is Needed
        for ( my $bitcount = 0 ; $bitcount < scalar(@CurrentRegStateArray) ; $bitcount++ ) {
            if ( $ABUSNodeHash->{ $CurrentReg }[$bitcount] eq "X" ) {
                $NewRegStateArray[$bitcount] = $CurrentRegStateArray[$bitcount];
            }
            else {
                $NewRegStateArray[$bitcount] = $ABUSNodeHash->{ $CurrentReg }[$bitcount];
            }
        }
        
        # Write over the Current Register State File with what is about to be set as the State
        my $NewRegStateBits = join( "\t", @NewRegStateArray );
        unshift @NewRegStateArray, $CurrentReg;
        my $NewRegStateLine = join( "\t", @NewRegStateArray );
        print $NextRegStateFileHANDLE ($NewRegStateLine . "\n");
        # Shift the bits out onto the current register, LSB is Index ZERO!
        ARFPiShiftRegister::BitBangShiftRegisterWrite($CurrentReg, \@NewRegStateBits);
        # Andy Verified the Shift Register LSB/MSB Index Zero Problem is GOOD! 5Jan2024
        
    }

    seek $CurrentRegStateFileHANDLE, 0, 0;
	seek $NextRegStateFileHANDLE, 0, 0;
    ### Read the ABUS Node
    my $ABUSReading_RawData = BitBangABUSADCRead();
    my $ABUSReading_Scaled = $ABUSReading_RawData * $ABUSNodeHash->{RScale};

    return $ABUSReading_RawData;
}

1;
