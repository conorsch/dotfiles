#!/usr/bin/perl 
#This script opens a SOCKSv2 dynamic proxy to the specified host,
#allowing for encrypted browsing sessions. The user must manually adjust
#web browser settings to use the SOCKS proxy.
use strict;
use warnings;

my $host = "t"; #host computer to connect to via SSH (this will reference SSH conf file, so it's OK to use aliases);
my $port = 2002; #local port through which the proxy connection will be accessible;
my $timeout_duration = 30; #after this many seconds, ssh will give up and return user to shell;

#my $ssh_pid = `ps ax | grep "ssh -D 2002" | head -n 1 | awk '{print $1}'`;#Get PID of previously running tunnel, if it exists;
my $ssh_pid = `ps ax | grep "ssh -D 2002" | head -n 1`; #Grab last first line of ps output, so other tunnels can be killed;
chomp $ssh_pid; #Remove that pesky trailing newline;
undef $ssh_pid if ($ssh_pid =~ m/grep/); #We don't want the grep process, which will show up on the ps output;
if ($ssh_pid) { #Check whether a PID for a pre-existing SSH tunnel was found
    $ssh_pid =~ s/^ (\d+)(.*)$/$1/; #Grab just the PID from the output (skip first space, get numbers, forget rest;
    print "Pre-existing SSH tunnel found as process $ssh_pid, killing it.\n";
    system ("kill $ssh_pid"); #If so, kill it;
#    `kill $ssh_pid`; #If so, kill it;
}
print "Attempting to open ssh tunnel now...\n"; #Give the user a little feedback;
`ssh -D 2002 -f -q -N -o ConnectTimeout=$timeout_duration -C $host` #Perform the actual connection;
    or die "    After $timeout_duration seconds, no connection could be established.
    Please check connection to internet."; #Report failure if unable to connect;
#system ("ssh -D $port -f -q -N -C $host"); #Perform the actual connection;
print "SSH tunnel initiated. Enjoy!\n"; #This 
