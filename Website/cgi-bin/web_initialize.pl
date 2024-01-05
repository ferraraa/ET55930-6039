#!/usr/bin/perl -w
use strict;

use lib '/projects/WebsiteModules';
use webpage;
use lib '/projects/ET55930-6039';
use ET55930_6039_Environment;
use ARFPiShiftRegister;
use ARFPiGPIO;

#use Config qw(myconfig config_sh config_vars);
use Data::Dumper;
use CGI;
use Sys::Hostname;

#use CGI::HTML::Functions;
#use Cwd;
#use filesystem;
#use CGI::Easy::SendFile;
#use webpage;
#use rscriptgen;
#use File::Temp;
#use File::Basename;
#use CGI::HTML::Functions;

## Create CGI Component
my $cgi                            = CGI->new;
my $host                           = hostname;
my @currentscriptfilebeingexecuted = split( "/", $0 );
my $formpath                       = "/cgi-bin/"
  . $currentscriptfilebeingexecuted[$#currentscriptfilebeingexecuted];
my $htmldir = "/var/www/html/";

my $WebJustStarted = 0;

#######################################################################################
##################### Start the HTML WebPage
#######################################################################################
print "Content-type: text/html\n\n";
print $cgi->start_html("ABUS");
print $cgi->a( { href => ( "http://" . $host . "/" ) }, "Return Home" );
print "<H2>Read One ABUS Node</H2>\n";
## Check to see what options have been selected

my @resetoption = $cgi->param("Reset");
my @resetboxch  = $cgi->param(
    "Check This If You Want to Reset the Form, Good When Funky Stuff Happens");

if ( @resetoption && @resetboxch ) {
    $WebJustStarted = 1;
    $cgi->delete_all();
}

#print Dumper($cgi);

## Make Reset Button
print $cgi->start_form(
    -method => 'post',
    -action => $formpath
);
print $cgi->div(
    $cgi->submit(
        -name   => "Reset",
        -id     => "Reset",
        -values => "Submit"
    ),
    $cgi->checkbox(
        -name =>
"Check This If You Want to Reset the Form, Good When Funky Stuff Happens",
        -id      => "resetbox",
        -value   => "resetboxchecked",
        -default => "unchecked"
    )
);

print "<br><br><br><br>";
#######################################################################################
##################### Start the HTML WebPage
#######################################################################################
## Display Radio Button To Initialize the Shift Registers
print $cgi->start_form(
    -method => 'post',
    -action => $formpath
);
my @ShiftRegInitParam = $cgi->param("Shift Register Initialization");
my @ShiftRegInitButtons = ( "Initialize", "Shut Down" );
my $ShiftRegInitDefault = "unchecked";

if (   -e ( $GPIODir . "gpio" . $SCLK_ShiftReg )
    && -e ( $GPIODir . "gpio" . $Data_ShiftReg )
    && -e ( $GPIODir . "gpio" . $Latch_ShiftReg )
    && -e ( $GPIODir . "gpio" . $EncodedCS0_ShiftReg )
    && -e ( $GPIODir . "gpio" . $EncodedCS1_ShiftReg )
    && -e ( $GPIODir . "gpio" . $EncodedCS2_ShiftReg )
    && -e ( $GPIODir . "gpio" . $EncodedCS3_ShiftReg ) )
{
    $ShiftRegInitDefault = "Initialize";
}
else {
    $ShiftRegInitDefault = "Shut Down";
}

webpage::makeButtons(
    $cgi, 'radio',
    "Shift Register Initialization",
    "<br>Shift Register Initialization<br>",
    \@ShiftRegInitButtons, $ShiftRegInitDefault
);
$cgi->end_form;

if ( $ShiftRegInitParam[0] eq "Initialize" ) {
    print "Initializing the Shift Register IO ......<br>";
    ARFPiShiftRegister::BitBangShiftRegistersSetup();
    print "Done<br>";
}
elsif ( $ShiftRegInitParam[0] eq "Shut Down" ) {
    print "Shutting Down/ Cleaning Up the Shift Register IO .....<br>";
    ARFPiShiftRegister::BitBangShiftRegistersCleanUp();
    print "Done<br>";
}

## Display Radio Button To Initialize the ABUS SPI
print $cgi->start_form(
    -method => 'post',
    -action => $formpath
);
my @ABUSSPIInitParam = $cgi->param("ABUS SPI Initialization");
my @ABUSSPIInitButtons = ( "Initialize", "Shut Down" );
my $ABUSSPIInitDefault = "unchecked";

if (   -e ( $GPIODir . "gpio" . $MOSI_ABUS )
    && -e ( $GPIODir . "gpio" . $MISO_ABUS )
    && -e ( $GPIODir . "gpio" . $SCLK_ABUS )
    && -e ( $GPIODir . "gpio" . $CS_ABUS ) )
{
    $ABUSSPIInitDefault = "Initialize";
}
else {
    $ABUSSPIInitDefault = "Shut Down";
}

webpage::makeButtons(
    $cgi, 'radio',
    "ABUS SPI Initialization",
    "<br>ABUS SPI Initialization<br>",
    \@ABUSSPIInitButtons, $ABUSSPIInitDefault
);
$cgi->end_form;

if ( $ABUSSPIInitParam[0] eq "Initialize" ) {
    print "Initializing the ABUS SPI Bus ......<br>";
    ARFPiGenericSerial::BitBangSPI_Setup($SCLK_ABUS,$MOSI_ABUS,$MISO_ABUS);
    ARFPiGPIO::InitializeGPIO($CS_ABUS, "out", 1);
    print "Done<br>";
}
elsif ( $ABUSSPIInitParam[0] eq "Shut Down" ) {
    print "Shutting Down/ Cleaning Up the ABUS SPI Bus .....<br>";
    ARFPiGenericSerial::BitBangSPI_CleanUp($SCLK_ABUS,$MOSI_ABUS,$MISO_ABUS);
    ARFPiGPIO::UninitializeGPIO($CS_ABUS);
    print "Done<br>";
}

print "<br><br><br><br>";

