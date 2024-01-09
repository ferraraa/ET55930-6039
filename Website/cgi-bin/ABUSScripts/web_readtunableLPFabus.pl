#!/usr/bin/perl -w
use strict;
use warnings;
use lib '/projects/ET55930-6039';
use ET55930_6039_Environment;
use lib '/projects/WebsiteModules';
use webpage;
use lib $ENV{PERL_GPIB} || "/projects/gpib";
use VXI11::Client;
use Generic_Instrument;
use ABUS;
use Config qw(myconfig config_sh config_vars);
use Data::Dumper;
use CGI;
use Sys::Hostname;
use Time::HiRes;

#######################################################################################
##################### Environment Stuff
#######################################################################################
## Create CGI Component
my $cgi                            = CGI->new;
my $host                           = hostname;
my @currentscriptfilebeingexecuted = split( "/", $0 );
my $formpath = "/cgi-bin/ABUSScripts/" . $currentscriptfilebeingexecuted[$#currentscriptfilebeingexecuted];
my $htmldir  = "/var/www/html/";

my $WebJustStarted = 0;

my ( $CurrentRegStateFileHANDLE, @CurrentRegStateHashArray ) = ET55930_6039_Environment::getCurrentRegisterState();

#######################################################################################
##################### Start the HTML WebPage, Makes the Reset Button and Header
#######################################################################################
webpage::makeForm_WebpageHeaderAndyStyle( $cgi, $formpath, "ABUS", "Read Tunable LPF ABUS Nodes" );
print "<br>";

#######################################################################################
##################### Display Prompt to Measure ABUS Node with LAN Multimeter
#######################################################################################
my $DMM = ABUS::makeForm_ABUSDMMInstrumentQuery($cgi);
print "<br><br><br>";

#######################################################################################
##################### Print List of ABUS Nodes
#######################################################################################
print "At the current state of this 'firmware', this measurement will take approximately 10 seconds<br>";
print "There are about 12 ABUS Nodes to be measured<br>";
print "Also, each measurement is actually three ABUS measurements.<br>";
print "The first is thrown away, the resulting 'Measurement Value' is the average of the final two<br><br>";
my $ReadButtonText = "Read Tunable LPF Bias Points";
my @readoption     = $cgi->param($ReadButtonText);
print $cgi->start_form(
    -method => 'post',
    -action => $formpath
);
print $cgi->div(
    $cgi->submit(
        -name   => $ReadButtonText,
        -id     => $ReadButtonText,
        -values => "Submit"
    )
);
$cgi->end_form;

if (@readoption) {
    my $StartTime = time();

    # Make ABUS Measurement Table
    my $ABUSTable = [ $cgi->th( [ "Node", "Expected Value", "ADC Measured Value", "DMM Measured Value" ] ) ];
    my $CurrentABUSNodeName;
    my @CurrentABUSNodeNameSplit;
    my $ABUSPhysicalReading = 1;
    my $DMMMeasurement;
    for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
        $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
        @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
        if ( $CurrentABUSNodeNameSplit[1] eq "TunableLPF" ) {
            ($ABUSPhysicalReading, $DMMMeasurement) =
              ABUS::BitBangABUSNodeRead( \@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count], $DMM );
            push @$ABUSTable,
              $cgi->td(
                [
                    $ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue},
                    $ABUSPhysicalReading,                 $DMMMeasurement
                ]
              );
        }

    }
    for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
        $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
        @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
        if ( $CurrentABUSNodeNameSplit[0] eq "ACOM" || $CurrentABUSNodeNameSplit[0] eq "VLNRef" ) {
            ($ABUSPhysicalReading, $DMMMeasurement) =
              ABUS::BitBangABUSNodeRead( \@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count], $DMM );
            push @$ABUSTable,
              $cgi->td(
                [
                    $ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue},
                    $ABUSPhysicalReading,                 $DMMMeasurement
                ]
              );
        }

    }

    print $cgi->table( { border => 1, -width => '50%' }, $cgi->Tr($ABUSTable), );
    my $EndTime = time();
    print "<br><br><br>Elapsed Measurement Time: " . ( $EndTime - $StartTime ) . " Seconds<br><br><br>";
}
#######################################################################################
##################### Always Do This At the End of the Script!
#######################################################################################
seek $CurrentRegStateFileHANDLE, 0, 0;
for ( my $regcount = 0 ; $regcount < scalar(@CurrentRegStateHashArray) ; $regcount++ ) {

    # Next 32 Values are each of the Register Bits, LSB is Index ZERO! Closest to Register Name
    my $RefToCurrentBitArray = $CurrentRegStateHashArray[$regcount]{CurrentBits};
    my $CurrentBitsText      = join( "\t", @$RefToCurrentBitArray );
    my $CurrentRegLine       = $CurrentRegStateHashArray[$regcount]{RegName} . "\t" . $CurrentBitsText . "\n";
    print $CurrentRegStateFileHANDLE $CurrentRegLine;

}
close $CurrentRegStateFileHANDLE;

print $cgi->end_html();
