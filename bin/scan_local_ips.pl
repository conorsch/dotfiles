#!/usr/bin/perl
#quick script to scan the local network work and display a list of 
#IP addresses and corresponding hostnames.
#currently assumes subnet is /24 CIDR; that should be fixed;
use strict; 
use warnings;
use diagnostics;
use feature 'say'; #why use print?
use List::Util qw/max/; #for nifty one-line hash walkthrough;

#### variable declaration ####
my ($internal_ip, $network, %host_list); #declare variables for assignment;
$internal_ip = `hostname -I`; #grab local IP address;
chomp $internal_ip; #remove pesky trailing newline;
$internal_ip =~ s/\s*//g; #remove any and all whitespace from network string;
$network = $internal_ip; #set aside original variable value, for use later;
$network =~ s@(\d+\.\d+\.\d+)(\.\d+)@$1.0@g; #grab first three numbers, replace last with '0';
$network =~ s/\s*//g; #remove any and all whitespace from network string;

die "No network connection detected." unless defined($network); #make sure network exists;
#### variable declaration ####

say "Scanning network $network for active hosts..."; #provide user feedback;
my @nmap_output = `nmap -sP $network/24 | grep report`; #run nmap, capture output;

foreach my $entry (@nmap_output) { #look at each line of nmap output;
    chomp $entry; #remove pesky trailing newline;
    next unless $entry =~ m/[\(|\)]/; #skip if report entry is malformed;

    $entry =~ s/Nmap scan report for //; #toss away cruft in output;
    $entry =~ s/[\(|\)]//g; #remove parentheses around IP address;
    my ($host, $ip) = split(' ', $entry); #break up line into hostname and IP address;

    $host = "unknown (probably router or gateway)" if $host =~ m/unknown/; #usually correct;
    $host .= " (This is you.)" if $ip =~ m/$internal_ip/; #identify current machine in list;

    $host_list{$ip} = $host; #store pair in hash, with ip as key;
}

print_columns(\%host_list); #print hostnames and IP address in columns;

#### subroutines ####
sub print_columns { #accept hash, print pretty columns from it;
    my $hashref = shift;
    my $str_length = max( map {length} keys %{$hashref}); #find longest string in hash keys;
    foreach my $key (sort keys %{$hashref}) { #sort by key; 
        printf "%-${str_length}s\t%-${str_length}s\n", $key, ${$hashref}{$key}; #display results;
    }
}
#### subroutines ####
