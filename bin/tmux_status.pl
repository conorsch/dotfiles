#!/usr/bin/perl 
#Script to generate output for status bar for tmux. 
#Output will be formatted different for desktops and laptops, 
#such as displaying wifi connection or battery charging status.
#On a laptop, it should look like:
#SSID-CONNECTED user@hostname 77%/time_left in battery tempC date time
#On a desktop, it should look like: 
#inet[green/red] user@hostname temp C date time
use strict;
use warnings;
use diagnostics;
use feature qw/switch say/;
use Term::ANSIColor;





#####LAPTOP#####
my ($me, $power_state, $percent_charged, $time_left, $temp, $date, $time); #initialize variables to be constructed;

sub me {
    my $username = `whoami`;
    my $hostname = `hostname`;
    chomp ($username, $hostname);
    $me = "$username" . "@" . "$hostname"; #concatenate username and hostname with @ symbol;
    return $me;
}
$me = me;

sub power_state {
    ... 
}

sub temp {
    my $acpi_temp = `acpi -t`; #grab temperature output from acpi command (in Celsius);
    chomp $acpi_temp; #remove pesky trailining newline;
    $acpi_temp =~ s/^Thermal \d: \w+, //; #Strip out everything before temperature;
    $acpi_temp =~ s/(\d+)(\.)(.*$)/$1/; #Strip off everything but integer value of temp;
    $acpi_temp = $acpi_temp . "C"; #concatenate temperature digits with units (here, C);
    return $acpi_temp; #pass back concatenated value to function caller;
}
$temp = temp;


my $acpi_output = `acpi`; #grab acpi output to process;
chomp $acpi_output;
given ($acpi_output) {
    when (/Discharging/) { #if laptop is currently running from battery;
        $acpi_output =~ s/^Battery \d: //; #remove any mention of which battery we're on;
        $acpi_output =~ s/Discharging,/drng/; #more succinct mention that battery is draining;
        $acpi_output =~ s/remaining$/left/; #more succinct mention of time till empty;
        $acpi_output =~ s/,//g; #remove any and all commas;
    }
    default { say "Must be charging... not set up yet!" }
}


print $me;
print " ";
say "TEMP IS: $temp";
print color 'red';
print $acpi_output;
print color 'reset';


print "\n";








