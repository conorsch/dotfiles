#!/usr/bin/perl 
#Script for quick English language etymology lookups;
#Future versions should parse multiple entries as titles and paragraphs for 
#dynamic support of line widths;
use strict;
use warnings;
use feature 'say';

my $word = $ARGV[0]; #get search term for use in URL request;

#Call lynx, forget URLs, dump page text for search term;
#Then get 20 lines of context after each occurrence of the search term;
#Chop off the first 23 lines;
#Chop off everything but the first 15 lines; 
#Feed text into remove_linebreaks for pretty formatting;
my $page_dump = `lynx -nolist -dump "http://www.etymonline.com/index.php?search=$word" | \
                grep -A 20 $word | \
                tail -n +23 | \
                head -n 15 | \
                remove_linebreaks.pl`;
my $results = $page_dump; #Create new variable for final reporting actoins;
$results =~ s/Look up \w+ at Dictionary\.com//g; #Remove alt-text for "Look up at Dictionary.com" links;
chomp $results; #Remove any trailing whitespace at the end;
say $results; #Print results, with friendly single newline on the end;
