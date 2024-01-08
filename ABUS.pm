package ABUS;
use ET55930_6039_Environment;
use ARFPiShiftRegister;
use ARFConvert;
use Data::Dumper;
use File::Slurp;

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
		my $Temp;
        for ( $count = 0 ; $count < 16 ; $count++ ) {
            system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
            $Temp = read_file( "/sys/class/gpio/gpio" . $MISO_ABUS . "/value" );
            $ABUSDataBits[$count] = chomp($Temp);
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

    my ($RefToCurrentRegStateHashArray, $ABUSNodeHash) = @_;
    my $LengthOfReferencedArray = scalar @{$RefToCurrentRegStateHashArray};
    for ( my $regcount = 0; $regcount < $LengthOfReferencedArray; $regcount++ ) {
		my $RegisterToBeWritten = $RefToCurrentRegStateHashArray->[$regcount]->{RegName};
        my $CurrentRegisterBits = $RefToCurrentRegStateHashArray->[$regcount]->{CurrentBits};
        my $RegStateNeedsChanging = 0;
        for (my $bitcount = 0; $bitcount < scalar @{$CurrentRegisterBits}; $bitcount++) {
        	if ($ABUSNodeHash->{ $RegisterToBeWritten }[$bitcount] ne "X") {
        		@{$CurrentRegisterBits}[$bitcount] = $ABUSNodeHash->{ $RegisterToBeWritten }[$bitcount];
        		$RegStateNeedsChanging = 1;
        		#print Dumper(@{$CurrentRegisterBits}[$bitcount]);
        	}
        }
        if ($RegStateNeedsChanging) {
        ARFPiShiftRegister::BitBangShiftRegisterWrite($RegisterToBeWritten, $CurrentRegisterBits);
        # Andy Verified the Shift Register LSB/MSB Index Zero Problem is GOOD! 5Jan2024        	
        }
        
    }

    ### Read the ABUS Node
    my $ABUSReading_RawData = BitBangABUSADCRead();
    my $ABUSReading_Scaled = $ABUSReading_RawData * $ABUSNodeHash->{RScale};

    return ($ABUSReading_RawData);
}

1;
