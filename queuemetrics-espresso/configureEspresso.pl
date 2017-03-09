#! /usr/bin/perl



#
# Espresso configurator
# $Id: configureEspresso.pl,v 1.2 2011/11/25 09:26:53 lenz-mobile Exp $
#
use strict;

my @BRAIN_EXAMPLE = (
{
	rpms => {
		'elastix' => "2",
		'asterisk' => "1.6",
		'queuemetrics' => '1.7'
	},
	filedir => "./elastix-2.0-queuemetrics-1.7-asterisk-1.6"
}
);



#
# Confronta le versioni
#

sub cmpVersion {
	my ($a, $b ) = @_;

	#print "< $a vs $b >\n";

  my @aa = map { $_ * 1 } split /\./, $a;
  my @bb = map { $_ * 1 } split /\./, $b;

	foreach my $va ( @aa ) {
		my $vb = shift @bb;
		#print "( $va , $vb )\n"; 
		my $vdec = ($va <=> $vb);
		if ( $vdec != 0 ) {
			return $vdec;
		}
	}	
	
	if ( ( $#bb ) > 0 ) {
		return -1;
	}
	
	return 0;

}

#
# Determina quale versione si applica
#
#

sub matchVersion {
	my ( $brain_, $rpms_ ) = @_;
	my @brain = @{$brain_};
	my %rpms  = %{$rpms_};
	
	foreach my $brainEntryPtr ( reverse @brain ) {
		
		if ( matchToBrain( $brainEntryPtr, $rpms_ ) == 1 ) {
			return $brainEntryPtr;
		} 
		
	}

	return { filedir => "" };	
}

sub matchToBrain {
	my ( $brainEntry_, $rpms_ ) = @_;
	my %{brainEntry} = %{$brainEntry_};
	my %rpms  = %{$rpms_};
	
	# controlla che tutti gli RPM richiesti dal brain ci siano
	foreach my $kr ( keys %{$brainEntry{rpms}} ) {
		if ( length( $rpms{$kr} ) == 0 ) {
			#print "Brain entry: $kr not found in local RPMs\n";
			return 0;
		}
	}
	
	# controlla che tutte le versioni siano superiori
	foreach my $kr ( keys %{$brainEntry{rpms}} ) {
		if ( cmpVersion ( $brainEntry{rpms}{$kr}, $rpms{$kr} ) > 0 ) {
			#print "Wrong version: $kr Brain requires: $brainEntry{rpms}{$kr} found $rpms{$kr} \n";
			return 0;
		}
	}
	
	#print "Brain $brainEntry{filedir} seems to be OK\n";
	return 1;
	 
}


#
# Controlla RPM
#
#

sub checkRpm {
	my ($name) = @_;

	my $val = `/bin/rpm -q --qf \"FOUND_[\%{VERSION}]\"  $name`;
	
	if ( $val =~ /^FOUND_(.+)/i ) {
		my $ver = $1;
		print "Package: $name version: $ver\n";
		return $ver;
	} else {
		print "Package: $name not found.\n";
		return "";
	}
}

sub checkRpms {
	my @packages = @_;
	my %result;

	foreach my $p ( @packages ) {
		$result{$p} = checkRpm( $p );
	}
	return \%result;
}

#
# Prepara i parametri della URL
#

sub parmsRpm {
	my ($rpmsPtr) = @_;
	#print "PTR $rpmsPtr\n";
	my $url = "";
	my %rpms = %{$rpmsPtr};

	foreach my $k ( sort keys %rpms ) {
		#print "K $k\n";
		my $ver = $rpms{$k};		
		if ( length( $ver ) > 0 ) {
			$url .= "$k:$ver;";
		}
	}
	#print "URL: $url\n";
	return $url;
}

