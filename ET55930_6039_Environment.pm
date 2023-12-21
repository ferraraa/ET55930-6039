package ET55930_6039_Environment;

##############################################
## Raspberry Pi 40 Pin Connector Assignment ##
##############################################

## AD3552R DACs are on SPI Bus 1 ##
our $MOSI_ModDACs = 20; # 40 Pin Connector Pin 38
our $MISO_ModDACs = 19; # 40 Pin Connector Pin 35
our $SCLK_ModDACs = 21; # 40 Pin Connector Pin 40
our $CS_ModDACA = 18; # 40 Pin Connector Pin 24
our $CS_ModDACB = 17; # 40 Pin Connector Pin 11
our $CS_ModDACC = 16; # 40 Pin Connector Pin 36
our $LDAC_ModDACA = 4; # 40 Pin Connector Pin 7
our $LDAC_ModDACB = 25; # 40 Pin Connector Pin 22
our $LDAC_ModDACC = 24; # 40 Pin Connector Pin 18

## ABUS ADC is on SPI Bus 0 ##
our $MOSI_ABUS = 10; # 40 Pin Connector 19
our $MISO_ABUS = 9; # 40 Pin Connector 21
our $SCLK_ABUS = 11; # 40 Pin Connector 23
our $CS_ABUS = 8; # 40 Pin Connector 24

## Shift Registers are on a Bus of their own ##
our $SCLK_ShiftReg = 15; # 40 Pin Connector 10
our $Data_ShiftReg = 14; # 40 Pin Connector 8
our $Latch_ShiftReg = 26; # 40 Pin Connector 37
our $EncodedCS0_ShiftReg = 6; # 40 Pin Connector 31
our $EncodedCS1_ShiftReg = 5; # 40 Pin Connector 29
our $EncodedCS2_ShiftReg = 22; # 40 Pin Connector 15
our $EncodedCS3_ShiftReg = 27; # 40 Pin Connector 13

## Oh Shit Switch ##
our $OSS = 7; # 40 Pin Connector 26

## Pulse Mod is on the PWM Lines ##
our $PulseTXp = 12; # 40 Pin Connector 32
our $PulseTXn = 13; # 40 Pin Connector 33
our $PulseDelayEn = 23; # 40 Pin Connector 16 

##############################################
## Raspberry Pi 40 Pin Connector Assignment ##
##############################################




#############################
## Shift Register Decoding ##
#############################

# There 10 banks of shift registers on ET55930-6039. 4 GPIO Pins
# have been assigned to encoding the 10 (16 possible) banks.
our @ShiftReg_ET1 =             [ 0 , 0 , 0 , 1 ];
our @ShiftReg_ET2 =             [ 0 , 0 , 1 , 0 ];
our @ShiftReg_SrcOut =          [ 0 , 0 , 1 , 1 ];
our @ShiftReg_YIGDiv =          [ 0 , 1 , 0 , 0 ];
our @ShiftReg_BotGrp3 =         [ 0 , 1 , 0 , 1 ];
our @ShiftReg_RFPathDC =        [ 0 , 1 , 1 , 0 ];
our @ShiftReg_TopGrp2 =         [ 0 , 0 , 1 , 1 ];
our @ShiftReg_TopGrp1 =         [ 1 , 0 , 0 , 0 ];
our @ShiftReg_PulseModDelay =   [ 1 , 0 , 0 , 1 ];
our @ShiftReg_MechStepAtten =   [ 1 , 1 , 1 , 0 ];

#############################
## Shift Register Decoding ##
#############################



1;