#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;
use Getopt::Long;
use LWP::UserAgent;
use Term::ANSIColor;
use Time::localtime;
use XML::LibXML;

my $maxdays = 14,
my $delay = 60;

GetOptions(
    "maxdays=i" => \$maxdays,
    "delay=i" => \$delay,
);

my $url = "https://service.berlin.de/terminvereinbarung/termin/tag.php?termin=1&dienstleisterlist=122210,122217,122219,122227,122231,122243,122252,122260,122262,122254,122271,122273,122277,122280,122282,122284,122291,122285,122286,122296,150230,122301,122297,122294,122312,122314,122304,122311,122309,317869,324433,325341,324434,122281,324414,122283,122279,122276,122274,122267,122246,122251,122257,324395,122208,122226&anliegen[]=120686";

my $today = DateTime->today();

sub writeln {
    my $message = shift;
    print colored("[" . $today->dmy(".") . "]", "GREY15"), " ", $message, "\n";
}

sub crawl {
    my $result = 0;

    my $ua = LWP::UserAgent->new(ssl_opts => {verify_hostname => 0});
    my $response = $ua->get($url);
    if ($response->status_line ne "200 OK") {
        return $result;
    }

    my $parser = XML::LibXML->new(recover => 2);

    my $doc = $parser->parse_html_string($response->content);

    my @free_days = $doc->findnodes('//a[@class="tagesauswahl"]');

    for my $free_day (@free_days) {
        my $link = $free_day->getAttribute("href");
        if ($link =~ /datum=([0-9]{4})-([0-9]{2})-([0-9]{2})/) {
            my $date = DateTime->new(year => $1, month => $2, day => $3);
            if ($date->delta_days($today)->in_units("days") <= $maxdays) {
                print colored("Available date on " . $date->dmy("."), "bold green"), "\n";
                print colored("https://service.berlin.de/terminvereinbarung/termin/" . $link, "GREY5"), "\n";

                $result = 1;
            }
        }
    }

    return $result;
}

for (;;) {
    writeln(colored("Fetching...", "GREY15"));

    if (crawl()) {
        print "\a\a\a\a\a";
        last;
    }

    writeln(colored("Noting found, retrying in " . $delay . " seconds", "GREY15"));
    sleep($delay);
}

exit 0;
