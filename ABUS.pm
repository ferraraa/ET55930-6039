package ABUS;
use ET55930_6039_Environment;
use ARFPiShiftRegister;
use Data::Dumper;

sub BitBangABUSADCRead {
    ## Input: None
    ## Output: Physical Data
    ## This routine writes via SPI Protocol
    my $ABUSNodeScale = shift;

    my @DataBits = split( //, $Data );
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
        $ABUSBitString = join( "", @ABUSDataBits );
        $ABUSADCCodes[$ABUSReadCount] = ARFConvert::BinaryToDecimal($ABUSBitString);
    }

    # Throw away first ABUS Reading, Average the last two
    my $AvgABUSADCCode       = ( $ABUSADCCodes[1] + $ABUSADCCodes[2] ) / 2;
    my $AvgABUSPhysicalValue = $ABUSNodeScale * $AvgABUSADCCode;

    return $AvgABUSPhysicalValue;
}

sub BitBangABUSNodeRead {

    my $ABUSNodeHash = shift;

    ### Read In ALL Current Shift Register States, Mask Current States with Needed States for ABUS Node.
    my @fileHANDLEArray;
    my $CurrentRegState;
    my @CurrentRegStateArray;
    my @CurrentRegStateHashArray;
	my $fileHANDLE;
    for ( my $count = 0 ; $count < scalar(@ShiftRegNameArray) ; $count++ ) {

        # Read Current State of Register
        open( $fileHANDLE, "<" . $CurrentRegisterStateDir . $ShiftRegNameArray[$count] . ".txt" );
        $CurrentRegState = <$fileHANDLE>;
        close $fileHANDLE;
		chomp($CurrentRegState);
        my @CurrentRegStateArray = split( "\t", $CurrentRegState );        

        # Mask the Current Register State with what is Needed
        for ( my $bitcount = 0 ; $bitcount < scalar(@CurrentRegStateArray) ; $bitcount++ ) {
            if ( $ABUSNodeHash->{ $ShiftRegNameArray[$count] }[$bitcount] eq "X" ) {
                $NewRegStateArray[$bitcount] = $CurrentRegStateArray[$bitcount];
            }
            else {
                $NewRegStateArray[$bitcount] = $ABUSNodeHash->{ $ShiftRegNameArray[$count] }[$bitcount];
            }
        }
        
        # Write over the Current Register State File with what is about to be set as the State
        open( $fileHANDLE, ">" . $CurrentRegisterStateDir . $ShiftRegNameArray[$count] . ".txt" );
        my $NewRegStateLine = join( "\t", @NewRegStateArray );
        seek( $fileHANDLE, 0, 0 );
        print $fileHANDLE $NewRegStateLine;
        truncate( $fileHANDLE, tell($fileHANDLE) );
        close $fileHANDLE;
        
        # Shift the bits out onto the current register
        ARFPiShiftRegister::BitBangShiftRegisterWrite($ShiftRegNameArray[$count], \@NewRegStateArray);
        
    }
    
    ### Read the ABUS Node
    

    return 1;
}

1;
