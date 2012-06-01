#!/usr/bin/perl 
#Script to cleanup plain text by removing hard line breaks,
#ensuring single spaces between sentences, 
#and replacing double hypens with true em dashes (—).
#Recommended usage is with filehandle redirects, e.g.:
#`remove_whitespace.pl <infile >outfile` or simply with pipes

use strict;
use warnings;
use feature 'say'; 
use Term::ANSIColor; #Allows for bolding of title output;

my $title = $ARGV[0]; #get title if exists from caller, allowing separate formatting;
my @paragraphs; #initialize array to store whole paragraphs (with no line breaks);

local $/ = ''; #This allows for reading into a string as a paragraph;

my $raw_text = <STDIN>; #get input data to modify;

#####BEGIN text-processing;
$raw_text =~ s/$title//; #first match of title should be removed;
$raw_text =~ s/\n+/ /gs; #remove all hard line breaks;
$raw_text =~ s/[^\S\n]+/ /gs; #remove multiple instances of whitespace, such as double-spacing between sentences;
$raw_text =~ s/-{2}/—/g; #replace ugly double hyphens with a real em dash;
$raw_text =~ s/\\"/'/g; #remove escaped quotes, because sadly sometimes that happens;
my $processed_text = $raw_text;
chomp $processed_text; #remove excessive newlines (doesn't appear to remove final \n);
#####END text-processing;

####Print results
print color 'bold'; #Make next text be printed bold;
say $title; #say title, which will appear bold;
print color 'reset'; #make next text be printed normally, not bold;
say "$processed_text"; #say rest of text, which will appear normal, not bold;
