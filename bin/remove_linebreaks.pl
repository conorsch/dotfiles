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

local $/ = ''; #This allows for reading into a string as a paragraph;
my @paragraphs = <STDIN>; #get input data to modify, as paragraph strings;

sub cleanup_paragraph {
    #####BEGIN text-processing;
    my $raw_text = shift; #grab text to process from function caller;
    $raw_text =~ s/\n+/ /gs; #remove all hard line breaks;
    $raw_text =~ s/[^\S\n]+/ /gs; #remove multiple instances of whitespace, such as double-spacing between sentences;
    $raw_text =~ s/-{2}/—/g; #replace ugly double hyphens with a real em dash;
    $raw_text =~ s/\\"/'/g; #remove escaped quotes, because sadly sometimes that happens;
    chomp $raw_text; #remove excessive newlines;
    return $raw_text; #pass back prettier text to function caller;
    #####END text-processing;
}

####Print results
sub print_titled {
    foreach my $paragraph (@paragraphs) { #
        $paragraph =~ m/(\s+)(.*)(\n)/; #search for first non-whitespace word-characters;
        my $title = $2; #name matched group above;
        chomp $title; #remove any trailing newlines, can't be too careful;
        print color 'bold'; #Make next text be printed bold;
        say $title; #say title, which will appear bold;
        print color 'reset'; #make next text be printed normally, not bold;
        my $entry = cleanup_paragraph($paragraph); #call paragraph cleaner, store result;
        $entry =~ s/^\s+$title//; #remove first occurrence of title;
        say $entry; #say entry, which is now cleanly formatted;
    }
}
print_titled;
