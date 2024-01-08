#!/usr/bin/perl -w
use strict;

#use lib '/projects/WebsiteModules';
use lib '/projects/ET55930-6039';
use ET55930_6039_Environment;
use lib '/projects/WebsiteModules';
use lib $ENV{PERL_GPIB} || "/projects/gpib";
use VXI11::Client;
use Generic_Instrument;
use webpage;
use ABUS;

#use Config qw(myconfig config_sh config_vars);
use Data::Dumper;
use CGI;
use Sys::Hostname;
use Time::HiRes;
my $ERROR;
Log::Log4perl->easy_init($ERROR);

#use CGI::HTML::Functions;
#use Cwd;
#use filesystem;
#use CGI::Easy::SendFile;
#use webpage;
#use rscriptgen;
#use File::Temp;
#use File::Basename;
#use CGI::HTML::Functions;

#######################################################################################
##################### Environment Stuff
#######################################################################################
## Create CGI Component
my $cgi                            = CGI->new;
my $host                           = hostname;
my @currentscriptfilebeingexecuted = split( "/", $0 );
my $formpath                       = "/cgi-bin/ABUSScripts/" . $currentscriptfilebeingexecuted[$#currentscriptfilebeingexecuted];
my $htmldir                        = "/var/www/html/";

my $WebJustStarted = 0;

my ($CurrentRegStateFileHANDLE , @CurrentRegStateHashArray) = ET55930_6039_Environment::getCurrentRegisterState();

#######################################################################################
##################### Start the HTML WebPage
#######################################################################################
print "Content-type: text/html\n\n";
print $cgi->start_html("ABUS");
print $cgi->a( { href => ( "http://" . $host . "/" ) }, "Return Home" );
print "<H2>Read One Specific ABUS Node</H2>\n";
## Check to see what options have been selected

my @resetoption = $cgi->param("Reset the Webpage");
my @resetboxch  = $cgi->param("Check This If You Want to Reset the Form, Good When Funky Stuff Happens");

if ( @resetoption ) {
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
        -name   => "Reset the Webpage",
        -id     => "Reset the Webpage",
        -values => "Submit"
    )
);
$cgi->end_form;

print "<br><br><br><br>";
#######################################################################################
##################### Display Prompt to Measure ABUS Node with LAN Multimeter
#######################################################################################
my @MultimeterMeas = $cgi->param("multimetermeas");
my @CustomAddress = $cgi->param("customaddress");
my @MultimeterButtons = ("No","VXI11::141.121.92.198::inst0","Address is Below");
my $Meter;
webpage::makeButtons(
    $cgi, 'radio',
    "multimetermeas",
    "<br>Would you like to simultaneously measure the ABUS Nodes with a Benchtop Multimeter<br>",
    \@MultimeterButtons, "No", 1
);
webpage::makeTextBoxInput($cgi, "customaddress" , "" , 50 , "");
if (@MultimeterMeas && ($MultimeterMeas[0] ne "No")) {
	if ($MultimeterMeas[0] eq "Address is Below") {
		$Meter = Generic_Instrument -> new( connectString => $CustomAddress[0] );
	} else {
		$Meter = Generic_Instrument -> new( connectString => $MultimeterMeas[0] );
	}
	
}


print "<br><br><br><br>";

#######################################################################################
##################### Print List of ABUS Nodes
#######################################################################################
print "At the current state of this 'firmware', this measurement will take approximately 10 seconds<br>";
print "There are about 118 ABUS Nodes to be choose from, listed below<br>";
print "Also, each measurement is actually three ABUS measurements. The first is thrown away, the resulting 'Measurement Value' is the average of the final two<br>";
my $ReadButtonText = "Read";
my @readoption = $cgi->param($ReadButtonText);
print $cgi->start_form(
    -method => 'post',
    -action => $formpath
);
print $cgi->div(
    $cgi->submit(
        -name   => $ReadButtonText,
        -id     => $ReadButtonText,
        -values => "Submit",
        -linebreak => "false"
    )
);
my @SpecificABUSNode = $cgi->param("specificabusnode");
webpage::makeTextBoxInput($cgi, "specificabusnode" , "" , 50 , "");
print "<br>";

$cgi->end_form;
if (@readoption) {
my $StartTime = time();
# Make ABUS Measurement Table
my $ABUSTable = [$cgi->th(["Node","Expected","Measured Value","Benchtop Meter Value"])];
my $CurrentABUSNodeName;
my @CurrentABUSNodeNameSplit;
my $ABUSPhysicalReading = 1;
my $MeterMeasurement = "NA";
for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
    $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
    @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
    if ( $CurrentABUSNodeName eq $SpecificABUSNode[0] ) {
        $ABUSPhysicalReading = ABUS::BitBangABUSNodeRead(\@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count] );
        if ($MultimeterMeas[0] ne "No") {
        $MeterMeasurement = $Meter -> iquery("READ?");
       
        }
        push @$ABUSTable, $cgi->td([$ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue} , $ABUSPhysicalReading, $MeterMeasurement]);
    }

}
#for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
#    $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
#    @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
#    if ( $CurrentABUSNodeNameSplit[0] eq "ACOM" || $CurrentABUSNodeNameSplit[0] eq "VLNRef" ) {
#        $ABUSPhysicalReading = ABUS::BitBangABUSNodeRead(\@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count] );
#        if ($MultimeterMeas[0] ne "No") {
#        $MeterMeasurement = $Meter -> iquery("READ?");
#       
#        }
#        push @$ABUSTable, $cgi->td([$ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue} , $ABUSPhysicalReading,  $MeterMeasurement]);
#    }

#}

print $cgi->table( { border => 1, -width => '50%'},
                   $cgi->Tr( $ABUSTable),
                 );
my $EndTime = time();
print "<br><br><br>Elapsed Measurement Time: " . ($EndTime-$StartTime) . " Seconds<br><br><br>";
}



for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
    print $ABUSRegisterHashArray[$count]{Name} . "<br>";
}
#######################################################################################
##################### Always Do This At the End of the Script!
#######################################################################################
seek $CurrentRegStateFileHANDLE, 0, 0;
for ( my $regcount = 0; $regcount < scalar(@CurrentRegStateHashArray); $regcount++ ) {
        # Next 32 Values are each of the Register Bits, LSB is Index ZERO! Closest to Register Name
        my $RefToCurrentBitArray = $CurrentRegStateHashArray[$regcount]{CurrentBits};
        my $CurrentBitsText = join("\t", @$RefToCurrentBitArray);
        my $CurrentRegLine = $CurrentRegStateHashArray[$regcount]{RegName} . "\t" . $CurrentBitsText . "\n";
		print $CurrentRegStateFileHANDLE $CurrentRegLine ;
		
       }
close $CurrentRegStateFileHANDLE;


print $cgi->end_html();
