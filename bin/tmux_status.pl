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

sub print_colored {

    my ($string, $color) = @_; #unpack variables from function caller;
    print color $color; #set terminal output to desired color;
    print $string; #print provided string in desired color;
    print color 'reset'; #remove color designations;
}

#sub print_colored {
#    my ($string, $color) = @_; #unpack variables from function caller;
#    print color $color; #set terminal output to desired color;
#    print $string; #print provided string in desired color;
#    print color 'reset'; #remove color designations;
#}
#

#####LAPTOP#####
my ($me, $power_state, $percent_charged, $time_left, $temp, $date_and_time); #initialize variables to be constructed;

sub me { #return a 'me' identity in the form of user@hostname;
    my $username = `whoami`; #grab username from shell;
    my $hostname = `hostname`; #grab hostname from shell;
    chomp ($username, $hostname); #remove trailing newlines;
    $me = "$username" . "@" . "$hostname"; #concatenate username and hostname with @ symbol;
    return $me; #pass concatenated 'me' back to function caller;
}
$me = me;

sub battery_info {
    my $power_state; #initialize variable for construction;

    #example outputs of different states from acpi (v1.6):
    my $charging_output =       "Battery 0: Charging, 62%, 00:49:05 until charged";
    my $discharging_output =    "Battery 0: Discharging, 70%, 04:44:00 remaining";
    my $full_output =           "Battery 0: Full, 100%";

    my $acpi_battery = `acpi -b`; #grab battery output of acpi command for processing;
    chomp $acpi_battery; #remove pesky trailing newline;

    given ($acpi_battery) { #take a look at the output from acpi command;
        when (/Discharging/) { #when AC adapter is unplugged;
            $power_state = "drng"; } #set power_state to more succinct mention that battery is draining;
        when (/Charging/) { #when AC adapter is plugged in;
            $power_state = "chrgng"; } #set power_state to more succinct mention that battery is charging;
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
($power_state, $percent_charged, $time_left) = battery_info;
            

sub temp { #return temperature from acpi shell call in format 00C;
    my $acpi_temp = `acpi -t`; #grab temperature output from acpi command (in Celsius);
    chomp $acpi_temp; #remove pesky trailining newline;
    $acpi_temp =~ s/^Thermal \d: \w+, //; #Strip out everything before temperature;
    $acpi_temp =~ s/(\d+)(\.)(.*$)/$1/; #Strip off everything but integer value of temp;
    #$acpi_temp = $acpi_temp . "C"; #concatenate temperature digits with units (here, C);
    return $acpi_temp; #pass back concatenated value to function caller;
}
$temp = temp;

sub date_and_time { #return date and time information, using Perl's localtime built-in function;
    my @time_dump = localtime(time); #grab time output from Perl as array;
    foreach my $unit (@time_dump) { #ensure all values are two digits!;
        next if $unit =~ m/\d\d/; #skip if already two or more digits;
        $unit = "0" . "$unit"; #pad with leading zero
    }
    my ($minutes, $hours, $month, $day) = @time_dump[1,2,4,3]; #grab necessary 
    $month++; #necessary to increase by one because month is zero-counting;
    my $time = join(':', $hours,$minutes); #join hours and minutes, separate with ':';
    my $date = join('/', $month,$day); #smash 'em together, so they're readable as a date;
    $date_and_time = join(' ', $date,$time); #concatenate both date and time;

    return $date_and_time; #pass back concatenated date and time to function caller;
}
$date_and_time = date_and_time;

sub print_status { #output status information to STDOUT;
    print "$me ";
    given ($power_state) {
        when (/chrgng/)         { print_colored ('⌁', 'green') }
        when (/drng/)           { print_colored ('⌁', 'red') }
        when (/full/)           { print_colored ('full', 'green') }
        default { print "UNKNOWN_BATTERY"}
    };
    print "$percent_charged";
    print "/"; #pretty separator for percent_charged and time_left;
    print "$time_left ";

    given ($temp) {
        when ( $_ < 40 )            { print_colored($temp, 'cyan') }
        when ( $_ >= 40 && $_ < 60 )    { print $temp }
        when ( $_ >= 60 )            { print_colored($temp, 'red') }
        default                 { say "UNKNOWN_TEMP" }
    };
#    $temp > 35 
#        ? print_colored($temp,'red') 
#        : print $temp;
    print "C "; #unit suffix for temperature;
    print "$date_and_time ";


}
print_status;
