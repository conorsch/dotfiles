#!/usr/bin/perl 
#Script to process text and remove linebreaks
use strict;
use warnings;
use feature qw/say switch/;

my $input_text = $ARGV[0]; #unpack arguments
open TEXTIN, '<', $input_text; #create filehandle for manipulating this text

while (<TEXTIN>) { #look at file
    s/\n/ /; #remove all hard line breaks
    s/\s+/ /g; #remove multiple instances of whitespace, such as double-spacing between sentences;
    s/-{2}/—/g; #replace ugly double hyphens with a real em dash;
    printf "$_"; #print line on screen as it's processed;
}
close TEXTIN; #put away the file after processing;
say ""; #add final line break, so prompt appears cleanly;
