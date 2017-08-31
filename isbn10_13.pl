#*/usr/bin/perl
use strict;
use warnings;
use Business::ISBN; 

## Aufgaben Schnittstellen / Stefan Lohrum
## 1) Schreiben Sie ein Programm zur Konvertierung von ISBN-10 nach ISBN-13
## Kathrin Heim / Bibinfo 16
## Dokumentation: http://search.cpan.org/~bdfoy/Business-ISBN-3.004/lib/Business/ISBN.pm
## Ein paar ISBN zum Testen: 
## Mastering regular expressions: 1565922573 oder 1-56592-257-3 (beides funktioniert)
## hitchhikers guide to the galaxy: 0345391802
## fahrenheit 451: 1451690312
## brave new world: 0099477467
## perl for dummies: 0764537504
## einführung in perl: 3897211475



print "Geben Sie eine 10-stellige ISBN ein: \n";

my $eingabe = <STDIN>;

my $isbn10 = Business::ISBN->new($eingabe);

print "Sie haben folgende ISBN eingegeben: \n";
print $isbn10->as_string;

print "\nIhre Eingabe als 13-stellige ISBN: \n";
my $isbn13 = $isbn10->as_isbn13;

print $isbn13->as_string;
print "\n";






	
	



