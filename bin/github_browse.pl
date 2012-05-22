#!/usr/bin/perl 
#Simple script to open a web browser window to the GitHub page for a git repo
#located in the cwd
use strict;
use warnings;
use feature "switch";
use feature "say";

$ENV{DISPLAY}=":0.0"; #Necessary to export DISPLAY, as this script will be called by root;
my $url = `git remote -v | grep fetch | awk {'printf \$2'}` or die "This is not a git repo"; #Grab just the URL from git;
given ($url) { #Let's set this URL up for parsing;
    when (/^git@/) { #If repo was checked out via SSH (i.e. starts with "git@");
        $url =~ s/(^git@)(github.com)(:)(.*)(\.git)/https:\/\/$2\/$4/; #Build a link!
    }
    when (/^http/) { #If repo was checked out via HTTP (i.e. starts with "http");
        $url =~ s/^http/https/; #Replace regular HTTP link with HTTPS;
    }
    default { #Fallback, in case nothing seems to match;
        say "The URL for this git repository could not be read.";
    }
}
exec("firefox -new-tab $url"); #Start up the browser;  
