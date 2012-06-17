#!/usr/bin/perl
#quick script to scan the local network work and display a list of 
#IP addresses and corresponding hostnames.
#currently assumes subnet is /24 CIDR; that should be fixed;
use strict; 
use warnings;
use diagnostics;
use feature 'say'; #why use print?
use List::Util qw/max/; #for nifty one-line hash walkthrough;

my $network = `hostname -I`; #grab local IP address;
chomp $network; #remove pesky trailing newline;
#$network =~ s@(\d+\.\d+\.\d+\.)\d+@$1@g; #grab first three numbers, drop last;
$network =~ s@(\d+\.\d+\.\d+)(\.\d+)@$1.1@g; #grab first three numbers, replace last with '1';
chomp $network; #remove pesky trailing newline;
$network =~ s/\s*//g; #remove any and all whitespace from network string;
say "Scanning network $network for active hosts..."; #provide user feedback;
my %host_list; #initialize hash to store IP addresses and hostnames;

my @nmap_output = `nmap -sP $network/24 | grep report`; #run nmap, capture output;
foreach my $entry (@nmap_output) { #look at each captured line;
    chomp $entry; #remove pesky trailing newline;
    $entry =~ s/Nmap scan report for //; #toss away cruft in output;
    next unless $entry =~ m/[\(|\)]/; #skip if report entry is malformed;
    $entry =~ s/[\(|\)]//g; #remove parentheses around IP address;
    my ($host, $ip) = split(' ', $entry);
    $host = "unknown (probably router or gateway)" if $host =~ m/unknown/;
    $host_list{$ip} = $host; #store pair in hash, with ip as key;
}
my $str_length = max( map {length} keys %host_list ); #find longest string in hash keys;
foreach my $ip (sort keys %host_list) { #sort by IP address;
    printf "%-${str_length}s\t%-${str_length}s\n", $ip, $host_list{$ip}; #display results;
}
