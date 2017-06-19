#! /usr/bin/perl

use strict;
require( "./configureEspresso.pl" );

my @BRAIN = (

	{
      rpms => {
              'elastix' => "1.6",
              'asterisk' => "1.4",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./elastix-1.6-qm-1.7-ast-1.4"
	},

	{
      rpms => {
              'elastix' => "2",
              'asterisk' => "1.6",
	      	  'queuemetrics' => "1.7.0.0"
      },
      filedir => "./elastix-2.0-qm-1.7-ast-1.6"
	},
   
  {
      rpms => {
              'elastix' => "2.2",
              'asterisk' => "1.8",
	      			'queuemetrics' => "1.7.1.0"
      },
      filedir => "./elastix-2.2-qm-1.7-ast-1.8"
	},
	
	{
      rpms => {
              'elastix' => "2.2",
              'asterisk' => "1.8",
	      			'queuemetrics' => "13.12"
      },
      filedir => "./elastix-2.2-qm-13.12-ast-1.8"
	},
    
	{
      rpms => {
              'asterisknow-version' => "1.7",
              'asterisk16' => "1.6",
              'freepbx' => "2.7",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./asterisknow-1.7-qm-1.7-ast-1.6"
	},
    
  
  {
      rpms => {
              'asterisknow-version' => "1.7.1",
              'asterisk16' => "1.6", 
              'freepbx' => "2.7",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./asterisknow-1.7.1-qm-1.7-ast-1.6"
	},
  
    
	{
      rpms => {
              'asterisknow-version' => "1.7",
              'asterisk14' => "1.4",
              'freepbx' => "2.7",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./asterisknow-1.7-qm-1.7-ast-1.4"
	},
    
	{
      rpms => {
              'asterisknow-version' => "1.7.1",
              'asterisk14' => "1.4",
              'freepbx' => "2.7",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./asterisknow-1.7.1-qm-1.7-ast-1.4"
	},
    
	{
      rpms => {
              'asterisknow-version' => "2.0.0",
              'asterisk-core' => "1.8.11",
              'freepbx' => "2.10",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./asterisknow-2.0.0-qm-1.7-ast-1.8"
	},    

	{
      rpms => {
              'asterisknow-version' => "3.0.0",
              'asterisk-core' => "11.5.0",
              'queuemetrics' => "13.04"
      },
      filedir => "./asterisknow-3.0.0"
	},  
	
	 {
      rpms => {
              'asterisknow-version' => "3.0.0",
              'asterisk-core' => "11.5.0",
              'queuemetrics' => "13.12"
      },
      filedir => "./asterisknow-3.0.0-qm-13.12"
	},  
    
	{
      rpms => {
              'trixbox' => "2.6",
              'asterisk' => "1.4",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./trixbox-2.6-qm-1.7-ast-1.4"
	},
    
	{
      rpms => {
              'trixbox' => "2.8",
              'asterisk16' => "1.6",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./trixbox-2.8-qm-1.7-ast-1.6"
	},
    
	{
      rpms => {
              'piafxtras' => "0.1",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./pbxinaflash-0.1-qm-1.7-ast-1.4-1.6"
	},
	
	{
      rpms => {
              'thirdlane-ast18-scripts' => "1.2",
              'pbxm-st' => "6.1.1",
              'asterisk18' => "1.8",
              'thirdlane-load-core' => "2.0",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./thirdlane-2.2-qm-1.7-ast-1.8"
  },
  
	{
      rpms => {
              'thirdlane-ast18-scripts' => "1.2",
              'pbxm-mt' => "6.1.1",
              'asterisk18' => "1.8",
              'thirdlane-load-core' => "2.0",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./thirdlane-mte-2.2-qm-1.7-ast-1.8"
  },
 

	{
      rpms => {
              'thirdlane-ast16-scripts' => "1.2",
              'pbxm-st' => "6.1.1",
              'asterisk16' => "1.6",
              'thirdlane-load-core' => "2.0",              
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./thirdlane-2.2-qm-1.7-ast-1.6"
  },
  
	{
      rpms => {
              'thirdlane-ast16-scripts' => "1.2",
              'pbxm-mt' => "6.1.1",
              'asterisk16' => "1.6",
              'thirdlane-load-core' => "2.0",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./thirdlane-mte-2.2-qm-1.7-ast-1.6"
  },
  

	{
      rpms => {
              'freepbx' => "2.10",
              'freepbxdistro-header' => "2.10",
              'asterisk18' => "1.8",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./freepbx-2.10-qm-1.7-ast-1.8"
  },

	{
      rpms => {
              'freepbx' => "2.10",
              'freepbxdistro-header' => "2.10",
              'asterisk10' => "10.1",
              'queuemetrics' => "1.7.0.0"
      },
      filedir => "./freepbx-2.10-qm-1.7-ast-1.8"
  },

	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk11' => "11",
              'queuemetrics' => "13.04"
      },
      filedir => "./freepbx-2.11"
  },

	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk10' => "10.12",
              'queuemetrics' => "13.04"
      },
      filedir => "./freepbx-2.11"
  },

	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk18' => "1.8",
              'queuemetrics' => "13.04"
      },
      filedir => "./freepbx-2.11"
  },
  
  # Aggiungo ACTIVE POLLING
	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk11' => "11",
              'queuemetrics' => "13.12"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },

	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk10' => "10.12",
              'queuemetrics' => "13.12"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },

	{
      rpms => {
              'freepbx' => "2.11",
              'asterisk18' => "1.8",
              'queuemetrics' => "13.12"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },

	{
      rpms => {
              'freepbx' => "12.0",
              'asterisk12' => "12.3",
              'queuemetrics' => "14.06"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },
  
  	{
      rpms => {
              'freepbx' => "12.0",
              'asterisk11' => "11.14",
              'queuemetrics' => "14.10"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },
  
  {
      rpms => {
              'freepbx' => "12.0",
              'asterisk13' => "13.0",
              'queuemetrics' => "14.10"
      },
      filedir => "./freepbx-2.11-qm-13.12"
  },
  
  {
      rpms => {
              'freePBX' => "2.8.1",
              'asterisk' => "1.8.20",
              'queuemetrics' => "14.06"
      },
      filedir => "./elastix-2.2-qm-13.12-ast-1.8"
  },

  {
      rpms => {
              'ombutel' => "1.0.11",
              'asterisk' => "13.13.1",
              'queuemetrics' => "16.10"
      },
      filedir => "./ombutel-1.0-qm-16.10-ast-13.13"
  },
  
  {
      rpms => {
              'freepbx' => "14.0",
              'asterisk14' => "14.0",
              'queuemetrics' => "16.10"
      },
      filedir => "./freepbx-14.0-qm-16.10-ast-14.0"
  },
  

);


my @PACKAGES = ( "asterisk", "asterisk14", "asterisk16", "asterisk18", "asterisk-core", "asterisk10", "asterisk11", "asterisk12", "asterisk13",
		"asterisknow-version", 
		"elastix", "trixbox", "goautodial-ce",
		"freePBX", "freepbx", "freepbxdistro-header", "piafxtras",
    "thirdlane-ast18-scripts", ,"thirdlane-ast16-scripts", "thirdlane-load-ast16", "thirdlane-load-ast18",
    "thirdlane-load-core", "thirdlane-web", "pbxm-st", "pbxm-mt", 
    "ombutel", 
		"queuemetrics", "qloaderd", "queuemetrics-espresso" 
);

my $localRpmPtr = checkRpms( @PACKAGES );
my $brainPtr = matchVersion( \@BRAIN, $localRpmPtr );
my $dirSelected = ${$brainPtr}{'filedir'};
my $settings = parmsRpm( $localRpmPtr );

`/usr/bin/wget -O- "http://queuemetrics.loway.ch/quickInstallversion.jsp?settings=$settings&choice=$dirSelected" 2> /dev/null`;



if ( length( $dirSelected ) > 0 ) {
	#my $runFile = "${dirSelected}/install.sh";
	#print "Running $runFile ...\n";
	print "DI $dirSelected ...\n";
	system( "cd $dirSelected; ./install.sh" );
} else {
	#print "Not found.";
	$settings =~ s/;/\\;/g;
        system( "./notFound.sh $settings" );
}
