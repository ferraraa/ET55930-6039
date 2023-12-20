package ARFPiAD3552R;
# This module should help make it simpler to communicate with the AD3552R DAC
# This is meant to be a part of the ET55930-6039 System, meaning the phsyical 
# pins on the RaspberryPi SPI Bus will be hardcoded in this module.

# ET55930-6039 uses the SPI-1 Bus. 
# 40 Pin Connector Pin 40: SPI1 SCLK
# 40 Pin Connector Pin 38: SPI1 MOSI
# 40 Pin Connector Pin 35: SPI1 MISO
# 40 Pin Connector Pin 24, GPIO 18: SPI1 CE0, DAC A on ET55930-6039
# 40 Pin Connector Pin 11, GPIO 17: SPI1 CE1, DAC B on ET55930-6039
# 40 Pin Connector Pin 36, GPIO 16: SPI1 CE2, DAC C on ET55930-6039

# The AD3552R can use a physical pin to load the DAC Outputs ... LDAC
# This can also be done in a register TBD
# ET55930-6039 can make use of the physical LDAC pin
# 7: GPIO 4, LDAC for DAC A on ET55930-6039
# 22: GPIO 25, LDAC for DAC B on ET55930-6039
# 18: GPIO 24, LDAC for DAC C on ET55930-6039

use Data::Dumper;
use System::Info;
use ARFConvert;



sub BitBangDACOutput {
    ## Input 1: DAC A, B, or C in the form of "A0", "B0", or "C0"
    ## Input 2: DAC Code (this routine expects the DAC code to be in decimal or hexadecimal form)
    ## Input 3: Read back the value? 0 for no, 1 for yes
    ## Output: None, unless you asked for a readback
    ## This routine writes AND LOADS a DAC output

    my $DAC = shift;
    my $DACCode = shift;
    my $Readback = shift;
    
    my $SCLK = 21; #GPIO21, Physical Pin 40
    my $MOSI = 20; #GPIO20, Physcial Pin 38
    my $MISO = 19; #GPIO19, Physcial Pin 35
    my $ChipSelect;
    my $DACRegisterMSBs;
    my $DACRegisterLSBs;
    if ($DAC == "A0") {
        $ChipSelect = 18; #GPIO18, Physical Pin 24
        $DACRegisterMSBs = 0x2A;
        $DACRegisterLSBs = 0x29;
        $LDAC = 4; #GPIO4, Physical Pin 7
    } elsif ($DAC == "A1") {
        $ChipSelect = 18; #GPIO18, Physical Pin 24
        $DACRegisterMSBs = 0x2C;
        $DACRegisterLSBs = 0x2B;
        $LDAC = 4; #GPIO4, Physical Pin 7
    } elsif ($DAC == "B0") {
        $ChipSelect = 17; #GPIO17, Physical Pin 11
        $DACRegisterMSBs = 0x2A;
        $DACRegisterLSBs = 0x29;
        $LDAC = 25; #GPIO25, Physical Pin 22
    } elsif ($DAC == "B1") {
        $ChipSelect = 17; #GPIO17, Physical Pin 11
        $DACRegisterMSBs = 0x2C;
        $DACRegisterLSBs = 0x2B;
        $LDAC = 25; #GPIO25, Physical Pin 22
    } elsif ($DAC == "C0") {
        $ChipSelect = 16; #GPIO16, Physical Pin 36
        $DACRegisterMSBs = 0x2A;
        $DACRegisterLSBs = 0x29;
        $LDAC = 25; #GPIO24, Physical Pin 18
    } elsif ($DAC == "C1") {
        $ChipSelect = 16; #GPIO16, Physical Pin 36
        $DACRegisterMSBs = 0x2C;
        $DACRegisterLSBs = 0x2B;
        $LDAC = 25; #GPIO24, Physical Pin 18
    } else {
        $ChipSelect = 16; #GPIO16, Physical Pin 36
        $DACRegisterMSBs = 0x2C;
        $DACRegisterLSBs = 0x2B;
        $LDAC = 25; #GPIO24, Physical Pin 18
    }

    # Convert the DAC Code to Binary
    my @DACCodeBinaryArray = ARFConvert::ToBinaryLeadingZeroes( $DACCode , 16 ); #DAC Code is 16 bits
    my $DACCodeBinaryString = join("", @DACCodeBinaryArray);
    my $DACCodeMSBs = substr( $DACCodeBinaryString , 8 , 8 );
    my $DACCodeLSBs = substr( $DACCodeBinaryString , 0 , 8 );

    # Convert DAC Register to Binary
    my @DACRegisterMSBsBinaryArray = ARFConvert::ToBinaryLeadingZeroes( $DACRegisterMSBs , 8 ); #DAC Registers are 8 bits
    my $DACRegisterMSBsBinaryString = join("", @DACRegisterMSBsBinaryArray);
    my @DACRegisterLSBsBinaryArray = ARFConvert::ToBinaryLeadingZeroes( $DACRegisterLSBs , 8 ); #DAC Registers are 8 bits
    my $DACRegisterLSBsBinaryString = join("", @DACRegisterLSBsBinaryArray);

    # Concatenate the Arrays of Bits: (Register , Data)
    my $MSBsToBeWritten = $DACRegisterMSBsBinaryString . $DACCodeMSBs;
    my $LSBsToBeWritten = $DACRegisterLSBsBinaryString . $DACCodeLSBs;

    # Check if we are on a Raspberry Pi
    my $System = System::Info -> new;
    my $CPUType = $System -> cpu_type;
    print Dumper ($CPUType);
    ################# ONLY TO BE RUN ON RASPBERRY PI #################
    if ($CPUType == "tbd") {
        # Make Sure LDAC Pin is Low

        ARFPiSerial::BitBangSPIWrite( $SCLK , $MOSI , $MSBsToBeWritten , $ChipSelect );
        ARFPiSerial::BitBangSPIWrite( $SCLK , $MOSI , $LSBsToBeWritten , $ChipSelect );

        if ($Readback == 1) {
            #Not reading back right now
        }
    }


}

1;