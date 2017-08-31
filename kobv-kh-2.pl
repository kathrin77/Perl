#! /usr/bin/perl
# Programm, dass eine Recherche (ISBN, Titel, Autor) via 
# KVK-Schnittstelle im KOBV durchführt und die Titel der ersten 5 Treffer ausgibt
# Suchparameter werden über Kommandozeile eingegeben:
# -t <title> # Bsp. -t "Herr der Ringe"
# -a <author> # Bsp. -a "Lindgren, Astrid"
# -i <isbn> # Bsp. -i "123456789"

use strict;
use warnings;


use LWP::UserAgent;
use XML::Simple;
use Data::Dumper;  
use Encode;
use utf8;
## utf8-anzeige für STDOUT
binmode(STDOUT, ":utf8");


my $ua = LWP::UserAgent->new;
my $server_endpoint = "http://portal.kobv.de/kvk.do?";
my $argument = '';

if ($ARGV[0] eq "-t") {
	# Eingabe: Titel
	$argument = "title=".$ARGV[1];

} elsif ($ARGV[0] eq "-a") {
	# Eingabe: Autor
	$argument = "author=".$ARGV[1];

} elsif ($ARGV[0] eq "-i") {
	# Eingabe: ISBN
	$argument = "isbn=".$ARGV[1];

} else {
	die "ungültige Eingabe: $!";
}

# set custom HTTP request 
my $abfrage = $server_endpoint.$argument;
# zu Debugging-Zwecken: Abfrage ausgeben
print $abfrage;
print "\n\n";

my $req = HTTP::Request->new(GET => $abfrage);
my $resp = $ua->request($req);


# http request prüfen
if ($resp->is_success) {
	my $message = $resp->decoded_content;
    	# Ausgabe als xml: auskommentiert
    	#print "Received reply: $message\n\n";

    	# Prüfung auf utf8
    	if (utf8::is_utf8($message)) {
	#debugging utf-8:
        #print "Is UFT-8: true \n";
        $message = encode('UTF-8', $message);
    	}

    	# Create XML data object and load XML message into it
    	my $xml = new XML::Simple;
		
	my $data = $xml->XMLin($message, forcearray => ['document', 'isbn']);

    	# Debugging: Print the data structure $data
	#print Dumper( $data ); 
	#print "\n";

	# Debugging: Print keys
	#for (keys %$data)  { print $_, ": ", $data->{$_}, "\n" ;}
	#print "\n";

	#  Limit: only print the first 5 records:
	my $limit = 5;

    	# print no. of records:	
	my $offset = $data->{offset};
    	my $total  = $data->{total};
    	print "Anzahl Treffer:   ", $total, "\n";
    	print "Anzeige der ersten 5 Treffer:\n\n";

    	# print author / title / isbn from the documents 
    	# arrays start with index 0
	
	for (my $i=1; $i<=$limit; $i++) {
        	print "Document #", $offset+$i, "\n";
        	my $author = $data->{document}[$i]->{author};
		if (defined ($author)) {
			print "Autor: ".$author."\n";
		} else {
		$author = '';
		}
		my $title = $data->{document}[$i]->{title};
		if (defined ($title)) {
	        	print "Titel:  ".$title."\n";
		} else {
		$title = '';
		}
		my $isbn1 = $data->{document}[$i]->{isbn}[0];
		if (defined ($isbn1)) {
			print "ISBN-1:   ". $isbn1. "\n";
		} else {
		$isbn1 = '';
		}
		my $isbn2 = $data->{document}[$i]->{isbn}[1];
		if (defined ($isbn2)) {
			print "ISBN-2:   ". $isbn2. "\n";
		} else {
		$isbn2 = '';
		}
		print "\n";
    	} 
    	print "END\n";   
}
else {
    	print "HTTP GET error code: ", $resp->code, "\n";
    	print "HTTP GET error message: ", $resp->message, "\n";
} 
