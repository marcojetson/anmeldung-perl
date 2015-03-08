#!/usr/bin/perl -w

use strict;
use warnings;

use DateTime;
use Getopt::Long;
use LWP::UserAgent;
use XML::LibXML;

my $district = 0;
my $maxdays = 14;
my $delay = 60;
my $beeps = 7;
my $list_districts = 0;
my $help = 0;

GetOptions(
    'district=i' => \$district,
    'maxdays=i' => \$maxdays,
    'delay=i' => \$delay,
    'beeps=i' => \$beeps,
    'list-districts' => \$list_districts,
    'help' => \$help,
);

my @districts = (
    [122210, 122217, 122219, 122227, 122231, 122243, 122252, 122260, 122262, 122254, 122271, 122273, 122277, 122280, 122282, 122284, 122291, 122285, 122286, 122296, 150230, 122301, 122297, 122294, 122312, 122314, 122304, 122311, 122309, 317869, 324433, 325341, 324434, 122281, 324414, 122283, 122279, 122276, 122274, 122267, 122246, 122251, 122257, 324395, 122208, 122226],
    [122210, 122217, 122219, 122227],
    [122231, 122243],
    [122252, 122260, 122262, 122254],
    [122271, 122273, 122277],
    [122280, 122282, 122284],
    [122291, 122285, 122286, 122296],
    [150230, 122301, 122297, 122294],
    [122312, 122314, 122304, 122311, 122309, 317869, 324433, 325341, 324434],
    [122281, 324414, 122283, 122279],
    [122276, 122274, 122267],
    [122246, 122251, 122257, 324395],
    [122208, 122226],
);

sub help {
    print 'Usage: anmeldung.pl [options...]', "\n",
          'Options:', "\n",
          ' --district DISTRICT  Limit search to a specific district (default all)', "\n",
          ' --maxdays DAYS       Set the maximum days till the appointment (default 14)', "\n",
          ' --delay SECONDS      Delay between fetches (default 60)', "\n",
          ' --beeps COUNT        Number of beeps to play when available date found (default 7)', "\n",
          ' --list-districts     Displays the districts list', "\n",
          ' --help               Shows this message', "\n";

    exit 0;
}

sub districts {
    print 'Districts:', "\n",
          ' 1: Charlottenburg - Wilmersdorf', "\n",
          ' 2: Friedrichshain - Kreuzberg', "\n",
          ' 3: Lichtenberg', "\n",
          ' 4: Marzahn - Hellersdorf', "\n",
          ' 5: Mitte', "\n",
          ' 6: Neukölln', "\n",
          ' 7: Pankow', "\n",
          ' 8: Reinickendorf', "\n",
          ' 9: Spandau', "\n",
          '10: Steglitz - Zehlendorf', "\n",
          '11: Tempelhof - Schöneberg', "\n",
          '12: Treptow - Köpenick', "\n";

    exit 0;
}

sub crawl {
    my $found = 0;

    my $now = DateTime->today();

    my $url = 'https://service.berlin.de/terminvereinbarung/termin/tag.php?termin=1&dienstleisterlist=' . join(',', @{$districts[$district]}) . '&anliegen[]=120686';

    my $ua = LWP::UserAgent->new(ssl_opts => {verify_hostname => 0});
    my $response = $ua->get($url);
    if ($response->status_line ne '200 OK') {
        return;
    }

    my $parser = XML::LibXML->new(recover => 2);

    my $doc = $parser->parse_html_string($response->content);

    my @free_days = $doc->findnodes('//a[@class="tagesauswahl"]');

    for my $free_day (@free_days) {
        my $link = $free_day->getAttribute('href');
        if ($link =~ /datum=([0-9]{4})-([0-9]{2})-([0-9]{2})/) {
            my $date = DateTime->new(year => $1, month => $2, day => $3);
            if ($date->delta_days($now)->in_units('days') <= $maxdays) {
                print 'Available date on ', $date->dmy('.'), ': ', "\n",
                      'https://service.berlin.de/terminvereinbarung/termin/', $link, "\n",
                      '-', "\n";

                $found = 1;
            }
        }
    }

    if ($found) {
        print "\a" x $beeps;

        exit 0;
    }
}

if ($help) {
    help();
}

if ((not defined $districts[$district]) || $list_districts) {
    districts();
}

for (;;) {
    print 'Fetching...', "\n";
    crawl();
    print 'Nothing found, retrying in ', $delay, ' seconds', "\n";
    sleep($delay);
}
