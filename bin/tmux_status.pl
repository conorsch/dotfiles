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

sub me { #return a 'me' identity in the form of user@hostname;
    my $username = `whoami`; #grab username from shell;
    my $hostname = `hostname`; #grab hostname from shell;
    chomp ($username, $hostname); #remove trailing newlines;
    $me = "$username" . "@" . "$hostname"; #concatenate username and hostname with @ symbol;
    return $me; #pass concatenated 'me' back to function caller;
}
$me = me;

sub power_state {
    my $power_state; #initialize variable for construction;
    my $charging_output =       "Battery 0: Charging, 62%, 00:49:05 until charged";
    my $discharging_output =    "Battery 0: Discharging, 70%, 04:44:00 remaining";

    my $acpi_battery = `acpi -b`; #grab battery output of acpi command for processing;
    chomp $acpi_battery; #remove pesky trailing newline;

    given ($acpi_battery) { #take a look at the output from acpi command;
        when (/Discharging/) { #when AC adapter is unplugged;
            $power_state = "drng"; } #set power_state to more succinct mention that battery is draining;
        when (/Charging/) { #when AC adapter is plugged in;
            $power_state = "chrg"; } #set power_state to more succinct mention that battery is charging;
        when (/Charged/) { #when battery is fully charged;
            $power_state = "full"; }  #set power-state to more succinct mention that battery if full;
        default { say "power_state is currently unknown; please check script"; } #for unforeseen corner cases;
    }

    $acpi_battery =~ m/^(.*)(\d{2}%)(.*)$/; #look for 00% format percentage;
    my $percent_charged = $2; #name second group (00% format, above) for returning;
    $acpi_battery =~ m/^(.*)(\d{2}:\d{2}:\d{2})(.*)$/; #look for 00:00:00 format time;
    my $time_left = $2; #name second group (00:00:00 format, above) for returning;

    return ($power_state, $percent_charged, $time_left);  #pass power_state variable back to function caller;
}
($power_state, $percent_charged, $time_left) = power_state;
            

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

sub build_status {
    print "$me ";
    print "$power_state ";
    print "$percent_charged ";
    print "$time_left ";
    print color 'red';

    print $temp; 
    print color 'reset';
    print "\n";

}
build_status;
