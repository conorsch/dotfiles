#!/usr/bin/perl 
#Script to cleanup plain text by removing hard line breaks,
#ensuring single spaces between sentences, 
#and replacing double hypens with true em dashes (—).
#Recommended usage is with filehandle redirects, e.g.:

use strict;
use warnings;
use feature qw/say switch/;

while (<STDIN>) { #read from standard input (pipe-friendly tool)
    s/\n/ /; #remove all hard line breaks;
    s/\s+/ /g; #remove multiple instances of whitespace, such as double-spacing between sentences;
    s/-{2}/—/g; #replace ugly double hyphens with a real em dash;
    s/\\"/'/g; #remove escaped quotes, because sadly sometimes that happens;
    printf "$_"; #print line on screen as it's processed;
}
say ""; #add final line break, so prompt appears cleanly;
