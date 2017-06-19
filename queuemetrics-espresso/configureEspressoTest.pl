#! /usr/bin/perl

use strict;
my $true = 0;
my $false = 1;

require( "configureEspresso.pl" );


banner( "cmpVersion" );

assertEq( "1 < 2", -1, cmpVersion( "1", "2" ) );
assertEq( "1 = 1",  0, cmpVersion( "1", "1" ) );
assertEq( "3 > 2",  1, cmpVersion( "3", "2" ) );

assertEq( "1.1 < 2.0", -1, cmpVersion( "1.1", "2.0" ) );
assertEq( "1.3 < 1.4", -1, cmpVersion( "1.3", "1.4" ) );
assertEq( "1.30 > 1.4", 1, cmpVersion( "1.30", "1.4" ) );

assertEq( "1.30 > 1.4.1", 1, cmpVersion( "1.30", "1.4.1" ) );
assertEq( "1.4 < 1.4.1.2", -1, cmpVersion( "1.4", "1.4.1.2" ) );
assertEq( "1.4.1.2 > 1.4", 1, cmpVersion(  "1.4.1.2", "1.4" ) );

assertEq ("1.27FOUND_1.28 >= 1.27", 1, cmpVersion("1.27FOUND_1.28", "1.27") );

banner( "matchVersion" );

my @braintest = ( 
  { rpms => { "A" => "1.3", "B" => "2", "C" => "7.1.4" }, 
  	filedir => "X1",
	  files => ( "q", "w" )
  },
  { rpms => { "A" => "1.4", "B" => "2", "C" => "7.1.4" }, 
  	filedir => "X2",
	  files => ( "q", "w" )
  },
	{ rpms => { "A" => "1.4.1", "B" => "2", "C" => "7" }, 
  	filedir => "X3",
	  files => ( "q", "w" )
  }
);
  
assertEqS( "p1", "X1", matchVersionAsString( \@braintest, { "A" => "1.3", "B" => "2", "C" => "7.1.4" }) );  


banner( "RPMs" );
print "asterisk version " . checkRpm( "asterisk" ) . "\n";
print "asterisk14 version " . checkRpm( "asterisk14" ) . "\n";
print "elastix version " . checkRpm( "elastix" ) . "\n";
print "freePBX version " . checkRpm( "freePBX" ) . "\n";
print "freepbx version " . checkRpm( "freepbx" ) . "\n";
print "ombutel version " . checkRpm( "ombutel" ) . "\n";
print "queuemetrics version " . checkRpm( "queuemetrics" ) . "\n";

assertEqS( "xyzwq version", "", checkRpm( "xyzwq" ) );


banner( "URL" );

assertEqS( "Sample URL", "a:b;d:e;", parmsRpm( {"a" => "b", "c" => "", "d" => "e"} ) );
assertEqS( "Sort", "a:b;d:e;", parmsRpm( {"d" => "e", "c" => "", "a" => "b"} ) );

exit;



#
# Asserts
#

sub assertEqS {
	my ($lbl, $a, $b ) = @_;

	if ( ! ($a eq $b)  ) {
		print "Failed test: $lbl\n Exp: $a\n Got: $b\n\n";
		exit(-1);
	} else {
		print "TestOK: $lbl\n";
	}

}
 
sub assertEq {
	my ($lbl, $a, $b ) = @_;

	if ( ! ($a == $b)  ) {
		print "Failed test: $lbl\n Exp: $a\n Got: $b\n\n";
		exit(-1);
	} else {
		print "TestOK: $lbl\n";
	}
}

sub assertTrue {
	my ( $lbl, $val ) = @_;
	if ( ! ($val)  ) {
		print "Failed test: $lbl\n";
		exit(-1);
	} else {
		print "TestOK: $lbl\n";
	}
}
	
 
sub banner {
	my ($section ) = @_;
	
	print "-------------------------------------------\n";
	print "Testing: $section \n"; 
	print "-------------------------------------------\n";
	
}

sub matchVersionAsString {
	my ($p1, $p2) = @_;
	my $brainPtr = matchVersion( $p1, $p2 );
	return ${$brainPtr}{filedir};
}
