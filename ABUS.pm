package ABUS;
use ET55930_6039_Environment;
use Data::Dumper;

sub BitBangABUSADCRead {
    ## Input 1: Initialized SPI Bus Array in the form of [SCLK, MOSI, MISO]
    ## Input 2: Intialized Chip Select GPIO Pin
    ## Output: None
    ## This routine writes via SPI Protocol
    my $SPIBus = shift; # Be sure to pass into this a REFERENCE to an Array \@blah NOT @blah
    my $CSpin = shift;
	my $ABUSNodeScale = shift;


    my @DataBits = split(//, $Data);
	my $ABUSReadCount;
	my $count;
	my @ABUSDataBits;
	my @ABUSADCCodes;
	my $ABUSBitString;
	
	# Perform Three ABUS Reads
	for ($ABUSReadCount = 0; $ABUSReadCount < 3; $ABUSReadCount++) {
		##ABUS ADC Read Order of Operations:
		# SCLK and CS Should Start HIGH
		# CS Pulls LOW, A-to-D Conversion Starts
		# MISO Pin Is Set to LOW By ADC, can be ignored
		# Falling edge of SCLK Sets Next Bit out of ADC, there are three more LOWs. can be ignored
		# 16 Falling Edges will generate the 16 bits from the ADC. MSB is first.
		# CS Pulls High after Final Rising Clock Edge
		system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		
		system ("echo 0 >/sys/class/gpio/gpio" . $CSpin . "/value"); # Conversion Starts
		# MISO is Set Low, Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
		system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		# MISO is Low, Again ... Ignore
		
	
		for ($count = 0; $count < 16; $count++) {
			system ("echo 0 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
			$ABUSDataBits[ $count ] = system("cat /sys/class/gpio/gpio" . $SPIBus->[ 2 ] . "/value >> /dev/null");
			system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		}
		# Done Reading, Set CS and SCLK High
		system ("echo 1 >/sys/class/gpio/gpio" . $SPIBus->[ 0 ] . "/value");
		system ("echo 1 >/sys/class/gpio/gpio" . $CSpin . "/value");
		
		# Convert Read Binary Data to Decimal
		$ABUSBitString = join("", @ABUSDataBits);
		$ABUSADCCodes[ $ABUSReadCount ] = ARFConvert::BinaryToDecimal( $ABUSBitString );
	}
	
	# Throw away first ABUS Reading, Average the last two
	my $AvgABUSADCCode = ($ABUSADCCodes[ 1 ] + $ABUSADCCodes[ 2 ]) / 2;
	my $AvgABUSPhysicalValue = $ABUSNodeScale * $AvgABUSADCCode;
	
	return $AvgABUSPhysicalValue;
}

sub BitBangABUSNodeRead{
	
	my $ABUSNodeHash = shift;
	
	### Read In ALL Current Shift Register States, Mask Current States with Needed States for ABUS Node.
	my @fileHANDLEArray;
	my $CurrentRegState;
	my @CurrentRegStateArray;
	my @CurrentRegStateHashArray;
	

for (my $count = 0; $count < scalar(@ShiftRegNameArray); $count++) {
	# Read Current State of Regiser
	open (my $fileHANDLE, "<" . $CurrentRegisterStateDir . $ShiftRegNameArray[$count] . ".txt");
	$CurrentRegState = <$fileHANDLE>;
	close $fileHANDLE;
	#open ($fileHANDLE, ">" . $CurrentRegisterStateDir . $ShiftRegNameArray[$count] . ".txt");
	chomp ($CurrentRegState);
	my @CurrentRegStateArray = split("\t", $CurrentRegState);
	#print Dumper(@NewRegStateArray);
	for (my $bitcount = 0; $bitcount < scalar (@CurrentRegStateArray); $bitcount++) {
		#print Dumper ($ABUSNodeHash->{$ShiftRegNameArray[$count]}[$bitcount] eq "X");
		if ($ABUSNodeHash->{$ShiftRegNameArray[$count]}[$bitcount] eq "X") {
			$NewRegStateArray[$bitcount] = $CurrentRegStateArray[$bitcount];
		} else {
			$NewRegStateArray[$bitcount] = $ABUSNodeHash->{$ShiftRegNameArray[$count]}[$bitcount];
		}
	}
	my $NewRegStateLine = join("\t", @NewRegStateArray);
	print "<br>";
	print Dumper($ShiftRegNameArray[$count]);
	print "<br>";
	print Dumper($CurrentRegState);
	print "<br>";
	print Dumper($ABUSNodeHash->{$ShiftRegNameArray[$count]});
	print "<br>";
	print Dumper($NewRegStateLine);

}	
	### Detemine NEW Shift Register State
	
	### Change ALL Shift Register States to Mux in the Desired ABUS Node

	# Shift Out New Bits to ALL Shift Registers
	
	return 1;
}

1;
