#!/usr/bin/perl 
#This script functions as a replacement to "git push all" for GitHub setups
#It keeps multiple repositories in sync by logging in and pulling for updates
#after a commit has been pushed. The user sets up a "cluster" of machines 
#and the logins and pulls will be performed on all machines in the cluster, 
#except, of course, for the local machine (hostname exception)

use strict;
use warnings;
use feature qw/switch say/;
use File::Basename 'basename';

my $repo = "/home/conor/gits/dotfiles"; #This path is used on ALL remote machines;
my $reponame = basename($repo);
my %cluster = ( #keys are aliases in ~/.ssh/config, values are actual hostnames;
        t => "Tepes",
        s => "Stirling",
        p => "Petrichor",
        w => "Wolke",
        );

my $base_command = "cd $repo; git pull"; #This is the command we want to run on remote machines;
my $suppress_stderr = "&> /dev/null"; #build string to silence any error output from command;
my $command = "$base_command $suppress_stderr"; #concatenate command with error suppression;

`git push`; #Perform the push from the local machine, first of all;

say "Synchronizing $reponame repository with remote machines...";
for my $key (keys %cluster) { #Look at all the aliases in our cluster;
    my $host = $cluster{$key}; #Easier to refer to local machine this way;
    my $hostname = `hostname`; #Will need to compare hostname from hash with actual hostname; 
    chomp $hostname; #Remove that trailing newline;
    next if $cluster{$key} eq $hostname; #We don't want to connect to the local machine;

    `ssh -q $key "$command"`; #perform the command on remote machine;
    my $exit_code = $?; #grab exit status of ssh, which returns exit status of remote command;
    given ($exit_code) { #take a look at this exit status;
        when (/0/) { say "Successfully performed designated actions on $host." }; #zero means success!;
        default    { say "Unable to contact host $host, please synchronize manually" }; #if not zero, report it;
    }
}
