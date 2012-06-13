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

sub print_colored { #outputs given string encased in tmux-compatible color codes;
    my ($string, $color) = @_; #unpack variables from function caller;

    my %colors = ( #build hash for easy access to common tmux-compatible colors;
            black => '#[fg=black]', 
            red => '#[fg=red]',
            green => '#[fg=green]',
            brown => '#[fg=brown}',
            blue => '#[fg=blue]',
            magenta => '#[fg=magenta]',
            cyan => '#[fg=cyan]',
            white => '#[fg=white]',
            yellow => '#[fg=yellow]',
            orange => '#[fg=orange]',
            reset => '#[default]',
            );

    my $code = $colors{$color}; #retrieve necessary color code from hash;
    my $reset_code= "$colors{reset}"; #retrieve reset code from hash;
    my $new_string = "$code" . "$string"; #build new string, concatenating with color code;
    print "$new_string"; #print out string formatted with specified color;
    print "$reset_code"; #set terminal color back to normal;
}

#####LAPTOP#####
my ($me, $power_state, $percent_charged, $time_left, $temp, $date_and_time); #initialize variables to be constructed;

sub me { #return a 'me' identity in the form of user@hostname;
    my $username = `whoami`; #grab username from shell;
    my $hostname = `hostname`; #grab hostname from shell;
    chomp ($username, $hostname); #remove trailing newlines;
    $me = "$username" . "@" . "$hostname"; #concatenate username and hostname with @ symbol;
    print "$me "; #pass concatenated 'me' back to function caller;
}

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

    $acpi_battery =~ m/^(.*)(\d{2,3})(%)(.*)$/; #look for 00% or 000% format percentage;
    my $percent_charged = $2; #name second group (00% format, above) for returning;
    $acpi_battery =~ m/^(.*)(\d{2}:\d{2}:\d{2})(.*)$/; #look for 00:00:00 format time;
    my $time_left = $2; #name second group (00:00:00 format, above) for returning;

    given ($power_state) { #format display of charging icon;
        when (/chrgng/)         { print_colored ('⌁', 'green') }
        when (/drng/)           { print_colored ('⌁', 'red') }
        when (/full/)           { print_colored ('full', 'green') }
        default                 { print "UNKNOWN_BATTERY"}
    };

    given ($percent_charged) { #format display of battery charge percentage;
        when ($_ > 90)                  { print_colored ("$percent_charged%", 'green') }
        when ($_ > 50 && $_ <= 90)      { print "$percent_charged%" }
        when ($_ > 20 && $_ <= 50)      { print_colored ("$percent_charged%", 'yellow') }
        when ($_ <= 20)                 { print_colored ("$percent_charged%", 'red') } 
        default                         { print "UNKNOWN_BATTERY"; }
    };

    print '/'; #pretty separator for percent_charged and time_left;
    print "$time_left "; #print hour many hours, minutes, and seconds of battery time remain;

}

sub temp { #return temperature from acpi shell call in format 00C;
    my $acpi_temp = `acpi -t`; #grab temperature output from acpi command (in Celsius);
    chomp $acpi_temp; #remove pesky trailining newline;
    $acpi_temp =~ s/^Thermal \d: \w+, //; #Strip out everything before temperature;
    $acpi_temp =~ s/(\d+)(\.)(.*$)/$1/; #Strip off everything but integer value of temp;
    #$acpi_temp = $acpi_temp . "C"; #concatenate temperature digits with units (here, C);
    given ($acpi_temp) {
        when ( $_ < 45 )                { print_colored($acpi_temp, 'cyan') }
        when ( $_ >= 45 && $_ < 60 )    { print $acpi_temp }
        when ( $_ >= 60 )               { print_colored($acpi_temp, 'red') }
        default                         { say "UNKNOWN_TEMP" }
    };
    print "C "; #unit suffix for temperature;
}

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

    print $date_and_time; #print out concatenated date and time;
}

sub network_status { #check whether connected to network and report it;
    `nm-online -t 1`; #run check (returns 0 for success, 1 for failure);
    $? == 0 #check whether connection check reported success;
        ? do { 
            print_colored ('inet', 'green'); #if success, green means good;
            my $ssid = `iwgetid --raw`;
            chomp $ssid; 
            print ":$ssid";
        }
        : print_colored ('no_net ', 'red'); #if failed, red means bad;
        print " "; #add space after output for nicer formatting;
} 

sub print_status { #output status information to STDOUT;
    network_status; #report network connection status;
    me; #report 'user@hostname' string;
    battery_info; #print statistics on battery charge status and time remaining;
    temp; #report CPU temperature in Celsius;
    date_and_time; #give date and time information;
}
print_status; #create and output line according to above subroutine;
