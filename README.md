# anmeldung-perl
I tried to get an appointment for the Anmeldung for almost a month till I got frustrated and created this little script.

## Usage
    ./anmeldung.pl [options...]

### Options
    --district DISTRICT  Limit search to a specific district (default all)
    --maxdays DAYS       Set the maximum days till the appointment (default 14)
    --delay SECONDS      Delay between fetches (default 60)
    --beeps COUNT        Number of beeps to play when available date found (default 7)
    --list-districts     Displays the districts list

### Districts
     1: Charlottenburg - Wilmersdorf
     2: Friedrichshain - Kreuzberg
     3: Lichtenberg
     4: Marzahn - Hellersdorf
     5: Mitte
     6: Neukölln
     7: Pankow
     8: Reinickendorf
     9: Spandau
    10: Steglitz - Zehlendorf
    11: Tempelhof - Schöneberg
    12: Treptow - Köpenick