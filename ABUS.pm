package ABUS;
use lib '/projects/WebsiteModules';
use webpage;
use ET55930_6039_Environment;
use ARFPiShiftRegister;
use ARFConvert;
use Data::Dumper;
use File::Slurp;

sub makeForm_ABUSDMMInstrumentQuery {
    my $cgi = shift;

    my @MultimeterMeas    = $cgi->param("multimetermeas");
    my @CustomAddress     = $cgi->param("customaddress");
    my @MultimeterButtons = ( "No", "Andy's Cube Rack, 34470A 7.5 Digit DMM", "Address is Below" );
    my $DMM             = "Does Not Exist";
    webpage::makeButtons( $cgi, 'radio', "multimetermeas",
        "<br>Would you like to simultaneously measure the ABUS Nodes with a Benchtop Multimeter<br>" . 
        "Contact Andy if you want an instrument added permanently to this list<br>",
        \@MultimeterButtons, "No", 1 );
    webpage::makeTextBoxInput( $cgi, "customaddress", "", 50, "VXI11::IP Address/Hostname::inst0" );
    if ( @MultimeterMeas && ( $MultimeterMeas[0] ne "No" ) ) {
        if ( $MultimeterMeas[0] eq "Address is Below" ) {
            $DMM = Generic_Instrument->new( connectString => $CustomAddress[0] );
        }
        elsif ( $MultimeterMeas[0] eq "Andy's Cube Rack, 34470A 7.5 Digit DMM" ) {
            $DMM = Generic_Instrument->new( connectString => "VXI11::141.121.92.198::inst0" );
        }
    }
    return ($DMM);
}

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
        # system( "echo 1 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $CS_ABUS . "/value", 1 );

        # system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );

        # system( "echo 0 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );    # Conversion Starts
        # MISO is Set Low, Ignore
        write_file( "/sys/class/gpio/gpio" . $CS_ABUS . "/value", 0 );

        # system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 0 );

        # system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );

        # MISO is Low, Again ... Ignore

        # system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 0 );

        #system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );

        # MISO is Low, Again ... Ignore

        #system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 0 );

        #system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );

        # MISO is Low, Again ... Ignore
        my $Temp;
        for ( $count = 0 ; $count < 16 ; $count++ ) {

            #system( "echo 0 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
            write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 0 );
            $Temp = read_file( "/sys/class/gpio/gpio" . $MISO_ABUS . "/value" );
            $ABUSDataBits[$count] = chomp($Temp);

            #system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
            write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );
        }

        # Done Reading, Set CS and SCLK High
        #system( "echo 1 >/sys/class/gpio/gpio" . $SCLK_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $SCLK_ABUS . "/value", 1 );

        #system( "echo 1 >/sys/class/gpio/gpio" . $CS_ABUS . "/value" );
        write_file( "/sys/class/gpio/gpio" . $CS_ABUS . "/value", 1 );

        # Convert Read Binary Data to Decimal
        $ABUSBitString = join( "", @ABUSDataBits );                                           #MSB Is Index ZERO!
        $ABUSADCDecimalCodes[$ABUSReadCount] = ARFConvert::BinaryToDecimal($ABUSBitString);
    }

    # Throw away first ABUS Reading, Average the last two
    my $AvgABUSDecimalCode = ( $ABUSADCDecimalCodes[1] + $ABUSADCDecimalCodes[2] ) / 2;

    return $AvgABUSDecimalCode;
}

sub BitBangABUSNodeRead {

    my ( $RefToCurrentRegStateHashArray, $ABUSNodeHash, $DMM ) = @_;
    my $DMMMeasurement;
    my $LengthOfReferencedArray = scalar @{$RefToCurrentRegStateHashArray};
    for ( my $regcount = 0 ; $regcount < $LengthOfReferencedArray ; $regcount++ ) {
        my $RegisterToBeWritten   = $RefToCurrentRegStateHashArray->[$regcount]->{RegName};
        my $CurrentRegisterBits   = $RefToCurrentRegStateHashArray->[$regcount]->{CurrentBits};
        my $RegStateNeedsChanging = 0;
        for ( my $bitcount = 0 ; $bitcount < scalar @{$CurrentRegisterBits} ; $bitcount++ ) {
            if ( $ABUSNodeHash->{$RegisterToBeWritten}[$bitcount] ne "X" ) {
                @{$CurrentRegisterBits}[$bitcount] = $ABUSNodeHash->{$RegisterToBeWritten}[$bitcount];
            }
        }
        if ($RegStateNeedsChanging) {
            ARFPiShiftRegister::BitBangShiftRegisterWrite( $RegisterToBeWritten, $CurrentRegisterBits );
            # Andy Verified the Shift Register LSB/MSB Index Zero Problem is GOOD! 5Jan2024
        }
    }

    ### Read the ABUS Node
    my $ABUSReading_RawData = BitBangABUSADCRead();
    my $ABUSReading_Scaled  = ((5*($ABUSReading_RawData/65535))-2.5) * $ABUSNodeHash->{RScale};
    
    ### Read the ABUS Node using a Benchtop DMM
	if ( $DMM ne "Does Not Exist" ) {
                $DMMMeasurement = $DMM->iquery("READ?");
            } else {
            	$DMMMeasurement = "NA";
            }
    return ($ABUSReading_Scaled, $DMMMeasurement);
}

1;
