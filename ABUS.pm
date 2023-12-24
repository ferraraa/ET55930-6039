package ABUS;
use Bit::Vector;

sub BitBangABUSRead {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Output: None
    ## This routine writes via SPI Protocol
    my @SPIBus = (shift,shift,shift);
    my $CSpin = shift;


    my @DataBits = split(//, $Data);
	my $ABUSReadCount;
	my $count;
	my @ABUSDataBits;
	my @ABUSADCCodes;
	my $ABUSBitString;
	
	# Perform Three ABUS Reads, Throw Away the first ... Average the next two
	for ($ABUSReadCount = 0; $ABUSReadCount < 3; $ABUSReadCount++) {
		##ABUS ADC Read Order of Operations:
		# SCLK and CS Should Start HIGH
		# CS Pulls LOW, A-to-D Conversion Starts
		# MISO Pin Is Set to LOW By ADC, can be ignored
		# Falling edge of SCLK Sets Next Bit out of ADC, there are three more LOWs. can be ignored
		# 16 Falling Edges will generate the 16 bits from the ADC. MSB is first.
		# CS Pulls High after Final Rising Clock Edge
		system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		
		system ("echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value"); # Conversion Starts
		# MISO is Set Low, Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
	
		for ($count = 0; $count < 16; $count++) {
			system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
			$ABUSDataBits[ $count ] = system("cat /sys/class/gpio/gpio" . $SPIBus[ 2 ] . "/value");
			system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		}
		# Done Reading, Set CS and SCLK High
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");
		
		# Convert Read Binary Data to Decimal
		$ABUSBitString = join("", @ABUSDataBits);
		$ABUSADCCodes[ $ABUSReadCount ] = ARFConvert::BinaryToDecimal( $ABUSBitString );
	}
	
	return @ABUSADCCodes;
}

1;