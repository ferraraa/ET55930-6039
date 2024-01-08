#!/usr/bin/perl -w
use strict;

#use lib '/projects/WebsiteModules';
use lib '/projects/ET55930-6039';
use ET55930_6039_Environment;
use ABUS;

#use Config qw(myconfig config_sh config_vars);
use Data::Dumper;
use CGI;
use CGI::Pretty;
use Sys::Hostname;
use Time::HiRes;
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
print "<H2>Read DC Current</H2>\n";
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
##################### Print List of ABUS Nodes
#######################################################################################
print "At the current state of this 'firmware', this measurement will take approximately 10 seconds<br>";
print "There are about 10 ABUS Nodes to be measured<br>";
print "Also, each measurement is actually three ABUS measurements. The first is thrown away, the resulting 'Measurement Value' is the average of the final two<br>";
my $ReadButtonText = "Read DC Current";
my @readoption = $cgi->param($ReadButtonText);
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
my $ABUSTable = [$cgi->th(["Node","Expected Value","Measured Value"])];
my $CurrentABUSNodeName;
my @CurrentABUSNodeNameSplit;
my $ABUSPhysicalReading = 1;
for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
    $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
    @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
    if ( $CurrentABUSNodeNameSplit[0] eq "PowerABUSi" ) {
        $ABUSPhysicalReading = ABUS::BitBangABUSNodeRead(\@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count] );
        push @$ABUSTable, $cgi->td([$ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue} , $ABUSPhysicalReading]);
    }

}
for ( my $count = 0 ; $count < scalar(@ABUSRegisterHashArray) ; $count++ ) {
    $CurrentABUSNodeName      = $ABUSRegisterHashArray[$count]{Name};
    @CurrentABUSNodeNameSplit = split( "_", $CurrentABUSNodeName );
    if ( $CurrentABUSNodeNameSplit[0] eq "ACOM" || $CurrentABUSNodeNameSplit[0] eq "VLNRef" ) {
        $ABUSPhysicalReading = ABUS::BitBangABUSNodeRead(\@CurrentRegStateHashArray, $ABUSRegisterHashArray[$count] );
        push @$ABUSTable, $cgi->td([$ABUSRegisterHashArray[$count]{Name}, $ABUSRegisterHashArray[$count]{ExpectedValue} , $ABUSPhysicalReading]);
    }

}

print $cgi->table( { border => 1, -width => '50%'},
                   $cgi->Tr( $ABUSTable),
                 );
my $EndTime = time();
print "<br><br><br>Elapsed Measurement Time: " . ($EndTime-$StartTime) . " Seconds<br><br><br>";
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
