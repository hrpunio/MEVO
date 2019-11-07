#!/usr/bin/perl -w
# 
# USAGE: mevo2xx.pl -day 20190806_log.csv
# Wypisuje jeden wiersz nast. zawartości kolumn: 
# yymmdd;bikes;łączny_czas_jazdy_minuty;łączny_czas_hhmm;łączny_dystans;prędkość_średnia;mediana_czasu_odcinka;rowery25;rowery00
# przy czym 
# rowery25 -- liczba rowerów które przejechały 25km i więcej
# rowery00 -- liczba rowerów które przejechały 0,5km i mniej
#
use strict;
use Getopt::Long;
use Geo::Distance;
use IO::Uncompress::Gunzip;
my $geo = new Geo::Distance;

## allowed-area bounding box
my %BB = ('lly' => 53.8, 'llx' => 17.4, 'ury' => 55.0, 'urx' => '19.5' );

my $YDAY =`date -d "yesterday" '+%Y%m%d'`; chomp($YDAY);
my $mevoFile="${YDAY}_log.csv.gz"; ## domyślnie wczoraj
my $bikeNo = -1;
my $yyyymmdd;

GetOptions('file=s' => \$mevoFile, );

my $mcsv = IO::Uncompress::Gunzip->new("$mevoFile") || die "### ERROR: cannot open $mevoFile!\n";

my %Bikes;
my %BikePlaceList;
my %TimeDiffs;
my %TimeDiffsLen;
my %TimeDiffsTime;
my %CurrentBikePos;
my %BikeVistedPos;

## Pętla po czasie
for my $line ( <$mcsv> ) {
  chomp($line); ###

  my ($date, $stationList) = split /;/, $line;

  my $hr = substr ($date, 8, 2); ## hour
  my $min = substr ($date, 10, 2); ## minute
  $yyyymmdd = substr($date, 0, 8); ## full-date

  my @places = split /\+/, $stationList;

  ## Pętla po współrzędnych $coord
  foreach my $place ( @places ) {
    my ($typenumber, $coord, $bikesNN, $bikelist) = split /=/, $place;

    my $bike = substr($typenumber, 0, 1);
    my ($lat, $lng) = split / /, $coord;

    ### skip station located outside allowed area
    if ($lat < $BB{"lly"} || $lat > $BB{"ury"} || $lng < $BB{"llx"} || $lng > $BB{"urx"} ) { next }

    my @bikes = split /,/, $bikelist;

    my $bikeNextChar = substr($typenumber, 1, 1); ## zmiana formatu jeżeli # nowy format
    my $number;
    if ($bikeNextChar eq '#') { $number = substr($typenumber, 2); } 
    else { $number = substr($typenumber, 1); }

    ## Pętla po rowerach. Problem jest taki że rower może wrócić w miejsce gdzie już był
    ## Użycie list indeksowanych w dwuwymiarowym haszu:
    ## push (@{$BikePlaceList{rower}{miejsce} }, czas)
    ## a potem odczytanie 1 i ostatniego elementu każdej listy
    ## nie da poprawnych wyników (dałoby gdyby miejsce było unikatowe).
    ## Trzeba dodać numer miejsca jako trzeci wymiar (miejsce 1, 2, 3 itd...)
    ## push (@{$BikePlaceList{rower}{miejsce nr-powtórzenia} }, czas)
    foreach my $b_ ( @bikes ) {
      ## $BikePlace{$b_} .= "!!$hr:$min=$place;\n";
      ## push (@{ $BikePlaceList{$b_}{$coord} }, "$hr-$min");
      ## == rower może być w tym samym miejscu wiele razy (wrócić):
      if ((! exists( $CurrentBikePos{$b_})) || $CurrentBikePos{$b_} ne "$coord" ) { $BikeVistedPos{$b_}{$coord}++;  }

      my $rc = $BikeVistedPos{$b_}{$coord}; ## rep count (ile razy w tym miejscu)
      push (@{ $BikePlaceList{$b_}{"$coord $rc"} }, "$hr-$min");

      $Bikes{$b_} = 1;  ## bikes registry
      $CurrentBikePos{$b_} = $coord;
    } ## //foreach
  } ## //foreach $place
} ## //

## ## ## Compute tracks/section times/length

my %BikeTotalUsedTime;
my %BikeTotalUsedDist;
my $TotalDist;
my $TotalTime;
my $totalBikes;

for my $b (sort keys %Bikes) {
  
  my %BikesUTrack; ## unique track (with idle time removed
  ## dla $bikeNo = -1  wypisze wszystkie rowery
  if ($b eq $bikeNo || $bikeNo < 0 ) {
    my %trk = %{$BikePlaceList{$b} }; ### 
    for my $p (sort keys %trk) { 
      my @times_registered = @{$trk{$p}};

      my $f = $times_registered[0];
      my $l = $times_registered[$#times_registered];
      $BikesUTrack{"$f:$l"} = $p;
    }
    
    my $dist;
    my @BikesUTimes = sort (keys (%BikesUTrack));

    for (my $i=1; $i<=$#BikesUTimes; $i++) {

      my ($t00, $t0) = split /:/, $BikesUTimes[$i - 1]; ## t0 = leave time
      my ($t1, $t11) = split /:/, $BikesUTimes[$i]; ## t1 = arrival time
      my ($h0, $m0) = split /\-/, $t0;
      my ($h1, $m1) = split /\-/, $t1;

      my $c0 = $BikesUTrack{$BikesUTimes[$i - 1]};
      my $c1 = $BikesUTrack{$BikesUTimes[$i] };

      ## Przypomnienie: klucze hasza %BikesUTrack mają postać "$lat_ $lng_ $rc_"
      my ($lt1, $lg1, $rc1) = split / /, $c0;
      my ($lt2, $lg2, $rc2) = split / /, $c1;

      $dist = $geo->distance( "meter", $lg1, $lt1 => $lg2, $lt2 );

      my $timediff = ($h1 * 60 + $m1) - ($h0 * 60 + $m0);

      ## compute section speed km/h (z dokładnością do .2)
      my $secSpeed = sprintf "%.2f", 0.06 * ($dist / ($timediff + 0.001));

      my $diffinterval = (int($timediff / 10) +1) * 10;  ## 10 min przedziały

      $TimeDiffs{$diffinterval}++; ## czas łączny jazdy
      $TimeDiffsLen{$diffinterval} += $dist /1000;  ## dystans łącznie [w kilometrach]
      $TimeDiffsTime{$diffinterval} += $timediff ;

      $BikeTotalUsedDist{$b} += $dist;
      $BikeTotalUsedTime{$b} += $timediff;

      $TotalDist += $dist;
      $TotalTime += $timediff;
    }
  } ##//if b
  $totalBikes++;
} ## //for b


### Best bikes (50km and more); good bikes (25km and more);
my ($gNN, $zNN, $btt);

for my $b (sort { $BikeTotalUsedDist{$b} <=> $BikeTotalUsedDist{$a} } keys %BikeTotalUsedDist ) {##
  $btt = sprintf "%.1f", $BikeTotalUsedDist{$b}/1000;
  ## $zNN rowery co przejechały mniej niż 500m
  if ($btt < 0.50)  { $zNN++; }
  elsif ($btt > 25.0) { $gNN++; }
}

my $log_file_name = "MEVO_TIMES_DIST_${yyyymmdd}.log";

open(LOG, ">$log_file_name") || die "Cannot open $log_file_name\n";

## Liczymy medianę odcinka z szeregu rozdzielczego
my ($prc, $prct, $cumprct, $cumprc);

my $totalKms = $TotalDist / 1000; ## w kilometrach
my $totalTme = $TotalTime;

## Short output to LOG (default 1line):
printf LOG "%s;bikes=%i;timemm=%i;timehhmm=%i:%i;dist=%.1f;speed=%.2f;secmediantime=%.1f;b25=%i;b00=%i\n",
 ${yyyymmdd}, $totalBikes, $TotalTime, int($TotalTime/60), $TotalTime % 60, 
 $TotalDist/1000, (0.06 * ($TotalDist / ($TotalTime + 0.001))),
 median(%TimeDiffsTime), $gNN, $zNN;

close(LOG);

## // END OF SCRIPT

sub median {
  ## Mediana czasu (szereg rozdzielczy)
  my %hash = @_;
  my $Total;
  for my $d (keys %hash ) { $Total += $hash{$d} }

  my $prc;
  my $cumprc;
  my $prc_prev;
  my $cumprc_prev;
  my $x_prev;
  for my $d (sort { $a <=> $b } keys %hash ) {
    $prc = $hash{$d}/$Total*100;
    $cumprc += $prc;
    if ($cumprc >= 50) { last }
    $x_prev=$d;
    $prc_prev= $prc;
    $cumprc_prev = $cumprc;
  }
  ## 10 to rozpiętość przedziału
  my $me = $x_prev + (50 - $cumprc_prev)/$prc * 10;
  return($me);
}
