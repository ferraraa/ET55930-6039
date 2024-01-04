#!/usr/bin/perl -w
use strict;
#use lib '/projects/WebsiteModules';
use lib '/projects/ET55930-6039';
#use Config qw(myconfig config_sh config_vars);
use Data::Dumper;
use CGI;
use Sys::Hostname;
use ET55930_6039_Environment;

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
my $cgi = CGI->new;
my $host = hostname;
my @currentscriptfilebeingexecuted = split("/", $0);
my $formpath          = "/cgi-bin/" . $currentscriptfilebeingexecuted[$#currentscriptfilebeingexecuted];
my $htmldir           = "/var/www/html/";

my $WebJustStarted        = 0;

#######################################################################################
##################### Start the HTML WebPage
#######################################################################################
print "Content-type: text/html\n\n";
print $cgi -> start_html( "ABUS" );
print $cgi -> a( { href => ( "http://" . $host . "/" ) }, "Return Home" );
print "<H2>Read One ABUS Node</H2>\n";
## Check to see what options have been selected

my @resetoption = $cgi->param( "Reset" );
my @resetboxch  = $cgi->param( "Check This If You Want to Reset the Form, Good When Funky Stuff Happens" );

if ( @resetoption && @resetboxch ) {
	$WebJustStarted = 1;
	$cgi->delete_all();
}
#print Dumper($cgi);

## Make Reset Button
print $cgi ->start_form( -method => 'post',
						 -action => $formpath );
print $cgi ->div(
				  $cgi->submit(
								-name   => "Reset",
								-id     => "Reset",
								-values => "Submit"
				  ),
				  $cgi->checkbox(
								  -name    => "Check This If You Want to Reset the Form, Good When Funky Stuff Happens",
								  -id      => "resetbox",
								  -value   => "resetboxchecked",
								  -default => "unchecked"
				  )
);
$cgi->end_form;

print "<br><br><br><br>";

#######################################################################################
##################### Print List of ABUS Nodes
#######################################################################################
#print Dumper(@PathIDRegisterHashArray);
for (my $count = 0; $count < scalar(@ABUSRegisterHashArray); $count++) {
	print $ABUSRegisterHashArray[$count]{Name} . "<br>";
}
$cgi->end_form;

print $cgi->end_html();
