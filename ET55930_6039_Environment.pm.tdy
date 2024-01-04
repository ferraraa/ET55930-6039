package ET55930_6039_Environment;
require Exporter;
use Data::Dumper;
our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS );
@ISA = qw(Exporter);
our (@EXPORT) = qw (
  $ProjectDir
  $RegisterDir
  $ABUSDir
  $CurrentRegisterStateDir
  $MOSI_ModDACs
  $MISO_ModDACs
  $SCLK_ModDACs
  $CS_ModDACA
  $CS_ModDACB
  $CS_ModDACC
  $LDAC_ModDACA
  $LDAC_ModDACB
  $LDAC_ModDACC
  $MOSI_ABUS
  $MISO_ABUS
  $SCLK_ABUS
  $CS_ABUS
  $SCLK_ShiftReg
  $Data_ShiftReg
  $Latch_ShiftReg
  $EncodedCS0_ShiftReg
  $EncodedCS1_ShiftReg
  $EncodedCS2_ShiftReg
  $EncodedCS3_ShiftReg
  $PulseTXp
  $PulseTXn
  $PulseDelayEn
  @ShiftRegNameArray
  @ShiftReg_ET1
  @ShiftReg_ET2
  @ShiftReg_SrcOut
  @ShiftReg_YIGDiv
  @ShiftReg_BotGrp3
  @ShiftReg_RFPathDC
  @ShiftReg_TopGrp2
  @ShiftReg_TopGrp1
  @ShiftReg_PulseModDelay
  @ShiftReg_MechStepAtten
  @ABUSRegisterHashArray
  @PathIDRegisterHashArray
);

our $ProjectDir = "/projects/ET55930-6039/";

our $ABUSDir    = $ProjectDir . "ABUS/";
our $ABUSRegMap = $ABUSDir . "RegisterMap_ABUS.txt";

our $PathIDDir = $ProjectDir . "ControlRegisters/PathID/";
our $PathIDMap = $PathIDDir . "PathIDRegisters.txt";

our $CurrentRegisterStateDir = $ProjectDir . "ControlRegisters/CurrentState/";

##############################################
## Raspberry Pi 40 Pin Connector Assignment ##
##############################################

## AD3552R DACs are on SPI Bus 1 ##
our $MOSI_ModDACs = 20;    # 40 Pin Connector Pin 38
our $MISO_ModDACs = 19;    # 40 Pin Connector Pin 35
our $SCLK_ModDACs = 21;    # 40 Pin Connector Pin 40
our $CS_ModDACA   = 18;    # 40 Pin Connector Pin 24
our $CS_ModDACB   = 17;    # 40 Pin Connector Pin 11
our $CS_ModDACC   = 16;    # 40 Pin Connector Pin 36
our $LDAC_ModDACA = 4;     # 40 Pin Connector Pin 7
our $LDAC_ModDACB = 25;    # 40 Pin Connector Pin 22
our $LDAC_ModDACC = 24;    # 40 Pin Connector Pin 18

## ABUS ADC is on SPI Bus 0 ##
our $MOSI_ABUS = 10;       # 40 Pin Connector 19
our $MISO_ABUS = 9;        # 40 Pin Connector 21
our $SCLK_ABUS = 11;       # 40 Pin Connector 23
our $CS_ABUS   = 8;        # 40 Pin Connector 24

## Shift Registers are on a Bus of their own ##
our $SCLK_ShiftReg       = 15;    # 40 Pin Connector 10
our $Data_ShiftReg       = 14;    # 40 Pin Connector 8
our $Latch_ShiftReg      = 26;    # 40 Pin Connector 37
our $EncodedCS0_ShiftReg = 6;     # 40 Pin Connector 31
our $EncodedCS1_ShiftReg = 5;     # 40 Pin Connector 29
our $EncodedCS2_ShiftReg = 22;    # 40 Pin Connector 15
our $EncodedCS3_ShiftReg = 27;    # 40 Pin Connector 13

## Oh Shit Switch ##
our $OSS = 7;                     # 40 Pin Connector 26

## Pulse Mod is on the PWM Lines ##
our $PulseTXp     = 12;           # 40 Pin Connector 32
our $PulseTXn     = 13;           # 40 Pin Connector 33
our $PulseDelayEn = 23;           # 40 Pin Connector 16

##############################################
## Raspberry Pi 40 Pin Connector Assignment ##
##############################################

#########################################
## Shift Register Chip Select Decoding ##
#########################################

# There 10 banks of shift registers on ET55930-6039. 4 GPIO Pins
# have been assigned to encoding the 10 (16 possible) banks.
our @ShiftRegNameArray =
  ( "BotGr3", "ET1", "ET2", "MechStepAtten", "RFPathDCPower_ABUS", "SrcOut", "TopGr1", "TopGr2", "YIGDiv" );
our @ShiftReg_ET1           = [ 0, 0, 0, 1 ];
our @ShiftReg_ET2           = [ 0, 0, 1, 0 ];
our @ShiftReg_SrcOut        = [ 0, 0, 1, 1 ];
our @ShiftReg_YIGDiv        = [ 0, 1, 0, 0 ];
our @ShiftReg_BotGrp3       = [ 0, 1, 0, 1 ];
our @ShiftReg_RFPathDC      = [ 0, 1, 1, 0 ];
our @ShiftReg_TopGrp2       = [ 0, 0, 1, 1 ];
our @ShiftReg_TopGrp1       = [ 1, 0, 0, 0 ];
our @ShiftReg_PulseModDelay = [ 1, 0, 0, 1 ];
our @ShiftReg_MechStepAtten = [ 1, 1, 1, 0 ];

#########################################
## Shift Register Chip Select Decoding ##
#########################################

###################################
## Read in ABUS Register Mapping ##
###################################
$/ = "\r\n";    #Windoze New Line is Terrible
my %ABUSRegisterHash;
our @ABUSRegisterHashArray;
my $ABUSRegLine;

# Open ABUS Register File
open my $ABUSRegFileHANDLE, $ABUSRegMap or die "Could not open $ABUSRegMap: $!";
$ABUSRegLine = <$ABUSRegFileHANDLE>;    # This line is header line
chomp($ABUSRegLine);
my @ParsedABUSHeader = split( '\t', $ABUSRegLine );
shift(@ParsedABUSHeader);
shift(@ParsedABUSHeader);
shift(@ParsedABUSHeader);

$ABUSRegLine = <$ABUSRegFileHANDLE>;
chomp($ABUSRegLine);
my @ParsedABUSRegisterNames = split( '\t', $ABUSRegLine );
shift(@ParsedABUSRegisterNames);
shift(@ParsedABUSRegisterNames);
shift(@ParsedABUSRegisterNames);

$ABUSRegLine = <$ABUSRegFileHANDLE>;
chomp($ABUSRegLine);
my @ParsedABUSRegisterBits = split( '\t', $ABUSRegLine );
shift(@ParsedABUSRegisterBits);
shift(@ParsedABUSRegisterBits);
shift(@ParsedABUSRegisterBits);

while ( $ABUSRegLine = <$ABUSRegFileHANDLE> ) {
    chomp($ABUSRegLine);
    @ParsedABUSRegLine = split( '\t', $ABUSRegLine );

    # Create an ABUS Node Hash, prepopulate the registers with Don't Cares 'Xs'
    my %ABUSRegisterHash =
      (    # Need to be my %blah to recreate the Hash. Only way to make an array of hashes in a loop.... IDK.
        Name               => shift(@ParsedABUSRegLine),
        RScale             => shift(@ParsedABUSRegLine),
        ADCRange           => shift(@ParsedABUSRegLine),
        BotGr3             => [ (X) x 32 ],
        ET1                => [ (X) x 32 ],
        ET2                => [ (X) x 32 ],
        MechStepAtten      => [ (X) x 32 ],
        RFPathDCPower_ABUS => [ (X) x 32 ],
        SrcOut             => [ (X) x 32 ],
        TopGr1             => [ (X) x 32 ],
        TopGr2             => [ (X) x 32 ],
        YIGDiv             => [ (X) x 32 ]
      );

    # Correct the Registers in the ABUS Hash, Write over the Don't Cares
    for ( my $count = 0 ; $count < scalar(@ParsedABUSRegisterNames) ; $count++ ) {
        $ABUSRegisterHash{ $ParsedABUSRegisterNames[$count] }[ $ParsedABUSRegisterBits[$count] ] =
          $ParsedABUSRegLine[$count];
    }

    # Make Array of Hashes
    push( @ABUSRegisterHashArray, \%ABUSRegisterHash );

    #print Dumper($ABUSRegisterHashArray[0]{Name});
}

close $ABUSRegFileHANDLE;
$/ = "\n";    #Return to Linux New Line
###################################
## Read in ABUS Register Mapping ##
###################################

###################################
## Read in PathID Register Mapping ##
###################################

$/ = "\r\n";  #Windoze New Line is Terrible
my %PathIDRegisterHash;
our @PathIDRegisterHashArray;
my $PathIDRegLine;

# Open PathID Register File
open my $PathIDRegFileHANDLE, $PathIDMap or die "Could not open $PathIDMap: $!";
$PathIDRegLine = <$PathIDRegFileHANDLE>;    # This line is header line, contains bit field names
chomp($PathIDRegLine);
my @ParsedPathIDHeader = split( '\t', $PathIDRegLine );

$PathIDRegLine = <$PathIDRegFileHANDLE>;    # This line contains all of the Register Names
chomp($PathIDRegLine);
my @ParsedPathIDRegisterNames = split( '\t', $PathIDRegLine );
shift(@ParsedPathIDRegisterNames);          # We do not need the first seven columns in this line
shift(@ParsedPathIDRegisterNames);
shift(@ParsedPathIDRegisterNames);
shift(@ParsedPathIDRegisterNames);
shift(@ParsedPathIDRegisterNames);
shift(@ParsedPathIDRegisterNames);
shift(@ParsedPathIDRegisterNames);

$PathIDRegLine = <$PathIDRegFileHANDLE>;    # This lines contains which bit number in the register the bit field goes to
chomp($PathIDRegLine);
my @ParsedPathIDRegisterBitNumbers = split( '\t', $PathIDRegLine );
shift(@ParsedPathIDRegisterBitNumbers);     # We do not need the first seven columns in this line
shift(@ParsedPathIDRegisterBitNumbers);
shift(@ParsedPathIDRegisterBitNumbers);
shift(@ParsedPathIDRegisterBitNumbers);
shift(@ParsedPathIDRegisterBitNumbers);
shift(@ParsedPathIDRegisterBitNumbers);
shift(@ParsedPathIDRegisterBitNumbers);

my @BotGr3BitNames;
my @ET1BitNames;
my @ET2BitNames;
my @MechStepAttenBitNames;
my @RFPathDCPowerBitNames;
my @SrcOutBitNames;
my @TopGr1BitNames;
my @TopGr2BitNames;
my @YIGDivBitNames;

for ( my $count = 0 ; $count < scalar(@ParsedPathIDRegisterBitNumbers) ; $count++ ) {
    if ( $ParsedPathIDRegisterNames[$count] eq "BotGr3" ) {
        $BotGr3BitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "ET1" ) {
        $ET1BitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "ET2" ) {
        $ET2BitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "MechStepAtten" ) {
        $MechStepAttenBitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "RFPathDCPower_ABUS" ) {
        $RFPathDCPower_ABUSBitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "SrcOut" ) {
        $SrcOutBitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "TopGr1" ) {
        $TopGr1BitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "TopGr2" ) {
        $TopGr2BitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    elsif ( $ParsedPathIDRegisterNames[$count] eq "YIGDiv" ) {
        $YIGDivBitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 7 ];
    }
    else {
        # Error out
        $YIGDivBitNames[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDHeader[ $count + 6 ];
    }
}

#$PathIDRegLine = <$PathIDRegFileHANDLE>;
while ( $PathIDRegLine = <$PathIDRegFileHANDLE> ) {
    chomp($PathIDRegLine);
    @ParsedPathIDRegLine = split( '\t', $PathIDRegLine );

    # Create an PathID Hash, prepopulate the registers with Don't Cares 'Xs'
    my %PathIDRegisterHash =
      (    # Need to be my %blah to recreate the Hash. Only way to make an array of hashes in a loop.... IDK.
        PathID               => shift(@ParsedPathIDRegLine),
        OutputFreqStart      => shift(@ParsedPathIDRegLine),
        OutputFreqStop       => shift(@ParsedPathIDRegLine),
        SynthFreqStart       => shift(@ParsedPathIDRegLine),
        SynthFreqStop        => shift(@ParsedPathIDRegLine),
        DivideRatio_2totheN  => shift(@ParsedPathIDRegLine),
        Mode                 => shift(@ParsedPathIDRegLine),
        BotGr3BitName        => \@BotGr3BitNames,
        BotGr3               => [ (X) x 32 ],
        ET1BitName           => \@ET1BitNames,
        ET1                  => [ (X) x 32 ],
        ET2BitName           => \@ET2BitNames,
        ET2                  => [ (X) x 32 ],
        MechStepAttenBitName => \@MechStepAttenBitNames,
        MechStepAtten        => [ (X) x 32 ],
        RFPathDCPowerBitName => \@RFPathDCPowerBitNames,
        RFPathDCPower_ABUS   => [ (X) x 32 ],
        SrcOutBitName        => \@SrcOutBitNames,
        SrcOut               => [ (X) x 32 ],
        TopGr1BitName        => \@TopGr1BitNames,
        TopGr1               => [ (X) x 32 ],
        TopGr1BitName        => \@TopGr1BitNames,
        TopGr2               => [ (X) x 32 ],
        YIGDivBitName        => \@YIGDivBitNames,
        YIGDiv               => [ (X) x 32 ]
      );

    # Correct the Registers in the PathID Hash, Write over the Don't Cares
    for ( my $count = 0 ; $count < scalar(@ParsedPathIDRegLine) ; $count++ ) {

        # Because we shifted the PathID, Freqs, Modes, Etc OUT ... This array is JUST bits
        if ( $ParsedPathIDRegisterNames[$count] eq "BotGr3" ) {
            $PathIDRegisterHash{BotGr3}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "ET1" ) {
            $PathIDRegisterHash{ET1}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "ET2" ) {
            $PathIDRegisterHash{ET2}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "MechStepAtten" ) {
            $PathIDRegisterHash{MechStepAtten}[ $ParsedPathIDRegisterBitNumbers[$count] ] =
              $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "RFPathDCPower_ABUS" ) {
            $PathIDRegisterHash{RFPathDCPower_ABUS}[ $ParsedPathIDRegisterBitNumbers[$count] ] =
              $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "SrcOut" ) {

            $PathIDRegisterHash{SrcOut}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "TopGr1" ) {
            $PathIDRegisterHash{TopGr1}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "TopGr2" ) {
            $PathIDRegisterHash{TopGr2}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        elsif ( $ParsedPathIDRegisterNames[$count] eq "YIGDiv" ) {
            $PathIDRegisterHash{YIGDiv}[ $ParsedPathIDRegisterBitNumbers[$count] ] = $ParsedPathIDRegLine[$count];
        }
        else {
            # Error out

        }
    }

    # Make Array of Hashes
    push( @PathIDRegisterHashArray, \%PathIDRegisterHash );
}

close $PathIDRegFileHANDLE;
$/ = "\n";    #Return to Linux New Line
###################################
## Read in PathID Register Mapping ##
###################################
1;

