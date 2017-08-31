#! /usr/bin/perl 

# --------------------------------------------------------------- #
# Aufgabe 3/Lohrum    
#                                                                 
# Programm, dass eine Recherche (ISBN, Titel, Autor) via SRU im   
# GBV durchführt und Notationen/Schlagworte der ersten            
# 3 Treffer ausgibt.                                              
# --------------------------------------------------------------- #

use strict;
use utf8;
use Getopt::Std;
use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use Encode;
binmode STDOUT, ":utf8";

my $baseurl = 'http://sru.gbv.de/gvk?version=1.1&operation=searchRetrieve&recordSchema=marcxml&sortKeys=relevance';

my $HELPTEXT ="
    
Usage: program [-h] [-a author] [-t title] [-s isbn] [-n|-p|-x|-l]
    
Options:

  -h help
  -a author search (Ex. 'Miller, Henry')
  -t title search (Ex. 'Star Trek')
  -s isbn search (Ex. 9783442383214)

  -n Formatierte Ausgabe (Notation & Schlagwort)
  -p print returned XML-String
  -x Dump tree
  -l Print XML and break lines at each closing tag
  
";

my $author = '';
my $title = '';
my $isbn = '';
my $maxrecords = 3;
my $url    = '';

# Command line options
my %opts = {};
getopts ('a:t:s:nhxpbl', \%opts);
if (defined $opts{'a'} ) { $author = $opts{'a'};  }
if (defined $opts{'t'} ) { $title = $opts{'t'};  }
if (defined $opts{'s'} ) { $isbn = $opts{'s'};  }
if (defined $opts{'h'} ) { print $HELPTEXT; exit 1; }



# Get XML from the service
my $browser = LWP::UserAgent->new();
if  (defined $opts{'a'}) {
   $url = $baseurl . '&maximumRecords=' . $maxrecords . '&query=pica.aut%3D' . $author; #URL for author search
   print $url."\n\n";   
} elsif (defined $opts{'t'}) {
   $url = $baseurl . '&maximumRecords=' . $maxrecords . '&query=pica.tit%3D' . $title; #URL for title search
   print $url. "\n\n"; 
} elsif (defined $opts{'s'}) {
   $url = $baseurl . '&maximumRecords=' . $maxrecords . '&query=pica.isb%3D' . $isbn; #URL for isbn search
   print $url."\n\n";
} else {die "ungueltige Eingabe: $!";
}

my $result  = $browser->post($url);
my $xmlstr  = $result->decoded_content;

if (utf8::is_utf8($xmlstr)) {
    #print "Is UFT-8: true \n";
    $xmlstr = encode('UTF-8', $xmlstr);
} 


# Print returned XML
if (defined $opts{'p'}) {
    print $xmlstr, "\n\n\n";
}


# Print XML and break lines at each closing tag 
if (defined $opts{'l'}) {
   my @xmlarr  = split(">",  $xmlstr);
   for my $line (@xmlarr) { print $line, ">\n"; }
}


# Prepare XML Simple and parse XML
my $xml = new XML::Simple;
my $data = $xml->XMLin($xmlstr, KeyAttr => { datafield => 'tag', subfield => 'code'}, ForceArray => ['zs:record', '650', '084']); 


# Dump tree
if (defined $opts{'x'}) {
  print Dumper( $data );
  for (keys %$data)  { print $_, "\n" ;} 
}

# Print result set size
my $total =  $data->{'zs:numberOfRecords'};
print "Result set size: ". $total. "\n";
print "First ".$maxrecords." results: \n";


# print result
if (defined $opts{'n'}) {

    for (my $i=0; $i<$maxrecords; $i++) {
 
	my $Haupttitel = &getVal($i, '245', 'a');
	my $Verfasser  = &getVal($i, '100', 'a');
	my $Isbnnr   = &getVal($i, '020', 'a');
	my $Schlagwort = &getVal($i, '650', 'a'); #GND-Schlagworte
	my $Notation = &getVal($i, '084', 'a'); #Notation

	print "\nDocument Nr.: ". ($i+1)."\n";
	if (defined ($Haupttitel)) {
		print "Titel: ". $Haupttitel."\n";
	}
	if (defined ($Verfasser)) {
		print "Verfasser: ". $Verfasser."\n";
	}
	if (defined ($Isbnnr)) {   
		print "ISBN: ".$Isbnnr."\n";
	}
	if (defined ($Schlagwort)) {
		print "Schlagworte: ".$Schlagwort."\n";
	}
	if (defined ($Notation)) {
		print "Notation: ".$Notation."\n\n";
	}

    }
}

sub getVal {
  my $n    = shift;
  my $tag  = shift;
  my $code = shift;
  return $data->{'zs:records'}->{'zs:record'}[$n]->{'zs:recordData'}->{'record'}->{'datafield'}->{$tag}->{'subfield'}->{$code}->{'content'};

}

## eigene sub für Schlagworte / Notation
## return $data->{'zs:records'}->{'zs:record'}[$n]->{'zs:recordData'}->{'record'}->{'datafield'}->{$tag}->{'subfield'}->{$code}->{'content'};
## foreach...
## alle vorh. tag-einträge holen, dann foreach durchitereieren durch array
