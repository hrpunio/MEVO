#!/usr/bin/perl -w
# Tworzy podsumowanie na podstawie 'aktywności dziennej' MEVO
# zapisywanej co $freqCalls do pliku CSV 
# przez skrypt mevo_get_store.pl
#
use strict;
use Getopt::Long;
use IO::Uncompress::Gunzip;
use Geo::Distance;
my $geo = new Geo::Distance;

## allowed-area bounding box
my %BB = ('lly' => 53.8, 'llx' => 17.4, 'ury' => 55.0, 'urx' => '19.5' );
my %DistByCity=();
my $NonMovBikes; ## list of NMB as string
my $kilometer = 1000;
my $distCalls = 0;
my $freqCalls=120; ## co ile sekund pobiera dane

my $YDAY =`date -d "yesterday" '+%Y%m%d'`; chomp($YDAY);

my $mevoFile="${YDAY}_log.csv.gz"; ## domyślnie wczoraj
my $stationsFileName = 'MEVO_STATIONS_ALT.csv';
my $mevoHome='..';
my $stationsFile="$mevoHome/$stationsFileName";
my $showTracks = '';

GetOptions('s=s' => \$stationsFile, 'file=s' => \$mevoFile, 'kml' => \$showTracks, 'tracks' => \$showTracks, );

open (STATIONS, "$stationsFile") || die "Cannot open stations @ $stationsFile!\n";

my %StationsC ;
## Stacje najbliżesze Abrahama 28
my %MyStations = ( '10111' => 'Mickiewicza', '10112' => 'Armii Krajowej', );
my %MyStatAvailable;
my %MyStatNN;
my %MyStatAvailableBH;
my %MyStatNNBH;
my %StationsNN;
my %StationsEE;
my %StationsIds;
my $stationsTotal;

for my $s (<STATIONS>) { chomp($s);
  ### ###
  if ( $s =~ m/ele;city/ ) { next } ## pomiń nagłówek

  my ($id, $latlng, $ele, $city) = split /;/, $s;

  if ($id > 20000) { next } ### stacje o dziwnych numerach pomijamy

  my ($lat, $lng) = split / /, $latlng;
  my $latlng8 = sprintf "%.08f %.08f", $lat, $lng;
  $StationsC{"$latlng8"} = "$city";
  $StationsEE{"$latlng8"} = $ele;
  ##$StationsNN{"$city"}++; ## ile stacji w mieście
  ##$stationsTotal++;
  $StationsIds{$id}="$city";
}

## Do maja stacje mają dwie różne współrzędne
for my $id_ (keys %StationsIds ) {
  my $c_ = $StationsIds{$id_};
  $StationsNN{"$c_"}++; ## ile stacji w mieście
  $stationsTotal++;
 }


print STDERR "### $stationsTotal active stations found in $stationsFile\n";
close(STATIONS);

my $bikesAsRegistered;
my %BikesTracks;
my %BikesPosRecent;
my ($distGrandTotal, $nmvBikes, $bikesNo, $distBC);
my ($distGrandTotal5, $distGrandTotal3 );
my ($TotalLen2, $TotalLen4, $TotalLen6, $TotalLen8, $TotalLen10, 
    $TotalLen12, $TotalLen14, $TotalLen16, $TotalLen18, $TotalLen20, $TotalLen99);
my ($mevoZeroStations, $mevoSingleStations, $mevoSampleNN);
my %mevoZStationsByCity;
my %mevoSStationsByCity;
my $yyyymmdd; ## date

my $mcsv = IO::Uncompress::Gunzip->new("$mevoFile") || die "### ERROR: cannot open $mevoFile!\n";
##open (MEVO, "$mevoDir/$mevoFile") || die "cannot open $mevoFile!\n";

for my $file (<$mcsv>) {##
  chomp($file);
  $mevoSampleNN++; ## ilość pomiarów w dniu

  my ($date, $stationList ) = split /;/, $file;
  my $hr = substr ($date, 8, 2); ## hour
  $yyyymmdd = substr($date, 0, 8); ## full-date

  my @places = split /\+/, $stationList;

  foreach my $place ( @places ) {
    my ($typenumber, $coord, $bikesNN, $bikelist) = split /=/, $place;
    my $bike = substr($typenumber, 0, 1);

    if ($bike eq 'S' ) { ## or 'B'
      ## tylko stacje (luźne bajki są pomijane)
      my ($lat, $lng) = split / /, $coord;

      ##my $bikes = $place->{bike_numbers};
      my @bikes = split /,/, $bikelist;

      ## Stary format S<numer> B0
      ## Nowy format S#<numer> B#<miasto>
      ## w tym skrypcie B tak czy siak jest pomijane (ale nie S)
      my $bikeNextChar = substr($typenumber, 1, 1); ## zmiana formatu jeżeli # nowy format
      my $number;
      if ($bikeNextChar eq '#') { $number = substr($typenumber, 2); } 
      else { $number = substr($typenumber, 1); }

      my $mevoCityAbbr ;
      if (defined( $StationsC{"$lat $lng"} )) { $mevoCityAbbr = $StationsC{"$lat $lng"} }
      else { $mevoCityAbbr = 'NA' }

      if ($bikesNN <1) { $mevoZeroStations++ }
      if ($bikesNN <2) { $mevoSingleStations++ }
      ## by city
      if ($bikesNN <1) { $mevoZStationsByCity{"$mevoCityAbbr"}++; }
      if ($bikesNN <2) { $mevoSStationsByCity{"$mevoCityAbbr"}++; }

      if (defined ($MyStations{$number})) { 
	$MyStatAvailable{$number} += $bikesNN; ## liczba bajków na stacji
	$MyStatNN{$number}++; ## liczba obserwacji  
	if ($hr > 4 && $hr < 23 ) {### bez okna 23--5 (6h)
	  $MyStatAvailableBH{$number} += $bikesNN; ## liczba bajków na stacji (godziny biznesowe)
	  $MyStatNNBH{$number}++; ## liczba obserwacji (godziny biznesowe)
	}
      }
      ####
      foreach my $b_ ( @bikes ) {
	### zapisz bez powtórzeń (ślad):
	### print STDERR "==> $BikesPosRecent{$b_} == $coord\n";
	unless (exists $BikesPosRecent{$b_} ) { $BikesPosRecent{$b_} =''; }
	unless ( $coord eq $BikesPosRecent{$b_} ) {
	  $BikesTracks{$b_} .= "$coord;"; 
	  $BikesPosRecent{$b_} = "$coord";
	}
	##print STDERR "$file : $b_ = $BikesTracks{$b_}\n";
      }

    }
  } ## //foreach
} ## //while

##close (MEVO);

my $targetPrc = sprintf "%.1f", $mevoSampleNN / (24 * 60 * 60 / $freqCalls) * 100;
print STDERR "### $mevoSampleNN ($targetPrc%) lines from $mevoFile aggregated\n";

### ### #### ####
if ( $showTracks ) { open(TRACKS, ">>MEVO_TRACKS_${yyyymmdd}.csv"); }
###
for my $b (sort keys %BikesTracks) {
    ### bez sort wyniki są różne ??
    my ($thisBikeDist, $thisBikeDist3, $thisBikeDist5, $dLen2, $dLen4, $dLen6, $dLen8, 
        $dLen10, $dLen12, $dLen14, $dLen16, $dLen18, $dLen20, $dLen99 ) = count_dist ( $BikesTracks{$b} );
    ##my $thisBikeDist = count_dist ( $BikesTracks{$b} );
    ## ## ##
    if ($showTracks) { my $t = $BikesTracks{$b}; 
      $t =~ s/ /,/g; $t =~ s/;/ /g; print TRACKS "$b;$t\n" }

    ## outside bounds bike returns -1:
    if ( $thisBikeDist < 0) {##
      print STDERR "### OBB ### $b\n"; next; }

    $bikesNo++;

    ### jeżeli mniej niż 10m uznajemy że się nie ruszał:
    if ($thisBikeDist < 10.0) { $nmvBikes++; 
      $NonMovBikes .= "$b=$BikesTracks{$b}+"; ## nr-bike = pozycja
    }

    $distGrandTotal += $thisBikeDist; ### łącznie
    ## by 3/5 slope:
    $distGrandTotal5 += $thisBikeDist5; 
    $distGrandTotal3 += $thisBikeDist3; 

    ## by stage length:
    $TotalLen2 += $dLen2; $TotalLen4 += $dLen4; $TotalLen6 += $dLen6; 
    $TotalLen8 += $dLen8; $TotalLen10 += $dLen10; $TotalLen12 += $dLen12; 
    $TotalLen14 += $dLen14; $TotalLen16 += $dLen16; $TotalLen18 += $dLen18; 
    $TotalLen20 += $dLen20; $TotalLen99 += $dLen99; 

    ### numery/dystanse rowerów wykazanych:
    $bikesAsRegistered .= sprintf "%s=%.1f ", $b, $thisBikeDist;

}
### ### #### ####
if ( $showTracks ) { close(TRACKS); }

### ### #### ####
my ($yday_y, $yday_m, $yday_d);
$yday_y = substr($yyyymmdd, 0, 4);
$yday_m = substr($yyyymmdd, 4, 2);
$yday_d = substr($yyyymmdd, 6, 2);

my $my_stations_stats = ''; ## jako jedno pole w formacie stacja=średnia
for my $s_ (sort keys %MyStations ) { 

    if ($MyStatNN{$s_} == 0 ) { $MyStatNN{$s_} = 0.0001;} ## lekkie oszustwo na wypadek zera
    if ($MyStatNNBH{$s_} == 0 ) { $MyStatNNBH{$s_} = 0.0001;  } ## ditto

    $my_stations_stats .= sprintf "%.2f;%.2f;", $MyStatAvailable{$s_}/$MyStatNN{$s_}, 
        $MyStatAvailableBH{$s_}/$MyStatNNBH{$s_}, 
}

##chop($my_stations_stats); ## remove last ';'
$my_stations_stats .= sprintf "%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f;%.2f", 
  $mevoZeroStations/$mevoSampleNN/$stationsTotal *100,
  $mevoSingleStations/$mevoSampleNN/$stationsTotal *100,
  $mevoZStationsByCity{'GD'}/$mevoSampleNN/$StationsNN{"GD"} * 100,
  $mevoZStationsByCity{'GA'}/$mevoSampleNN/$StationsNN{"GA"} * 100,
  $mevoZStationsByCity{'SP'}/$mevoSampleNN/$StationsNN{"SP"} * 100,
  $mevoZStationsByCity{'TC'}/$mevoSampleNN/$StationsNN{"TC"} * 100,
  $mevoZStationsByCity{'RU'}/$mevoSampleNN/$StationsNN{"RU"} * 100,
  $mevoSStationsByCity{'GD'}/$mevoSampleNN/$StationsNN{"GD"} * 100,
  $mevoSStationsByCity{'GA'}/$mevoSampleNN/$StationsNN{"GA"} * 100,
  $mevoSStationsByCity{'SP'}/$mevoSampleNN/$StationsNN{"SP"} * 100,
  $mevoSStationsByCity{'TC'}/$mevoSampleNN/$StationsNN{"TC"} * 100,
  $mevoSStationsByCity{'RU'}/$mevoSampleNN/$StationsNN{"RU"} * 100;

## dopisany dystans 5%/3% ;; dopisany dystans wg długości
printf "%s-%s-%s;%i;%i;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%s;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f;%.1f\n", 
   $yday_y, $yday_m, $yday_d, $bikesNo, $nmvBikes, $distGrandTotal /$kilometer,
   $DistByCity{'GA'}/$kilometer, $DistByCity{'GD'}/$kilometer, $DistByCity{'SP'}/$kilometer, 
   $DistByCity{'TC'}/$kilometer, $DistByCity{'RU'}/$kilometer, $my_stations_stats,
   $distGrandTotal3 /$kilometer, $distGrandTotal5 /$kilometer,  ### dodane 1.9.2019
   $TotalLen2/$kilometer, $TotalLen4/$kilometer, 
   $TotalLen6/$kilometer, $TotalLen8/$kilometer, $TotalLen10/$kilometer, 
   $TotalLen12/$kilometer, $TotalLen14/$kilometer, 
   $TotalLen16/$kilometer, $TotalLen18/$kilometer, $TotalLen20/$kilometer, 
   $TotalLen99/$kilometer;  ## dodane 3.9.2019


for my $c_ (keys %DistByCity) { $distBC += $DistByCity{$c_}; }
print STDERR "### DistByCity: $distBC [$distCalls]\n";

### ### #### ####
##open (BIKES, ">>MEVO_REGISTERED_BIKES.csv");
##printf BIKES "%s-%s-%s;%i;%s\n", $yday_y, $yday_m, $yday_d, $bikesNo, $bikesAsRegistered;
##close(BIKES);
##
### Numery i pozycje rowerów które się nie ruszały (dopisane 4.8.2018)
##open (NMBIKES, ">>MEVO_NONMOVING_BIKES.csv");
##printf NMBIKES "%s-%s-%s:%s\n", $yday_y, $yday_m, $yday_d, $NonMovBikes;
##close(NMBIKES);

####################################################################################
## ## ## #######
sub count_dist {
  ###################
  ### Liczy dystans przejechany przez 1 rower
  ###################
   my $trace = shift;

   my $distTotal = 0;
   my $distTotal5 = 0;
   my $distTotal3 = 0;
   my $altDiff;
   my $aveSlope;

   my $distTotalLen2 = 0;
   my $distTotalLen4 = 0;
   my $distTotalLen6 = 0;
   my $distTotalLen8 = 0; 
   my $distTotalLen10 = 0;
   my $distTotalLen12 = 0;
   my $distTotalLen14 = 0;
   my $distTotalLen16 = 0;
   my $distTotalLen18 = 0;
   my $distTotalLen20 = 0;
   my $distTotalLen99 = 0;

   my $dist = 0;
   my $plat = -999;
   my $plng = -999;

   chop($trace); ## remove ; at the end

   my @tr = split /;/, $trace;
   my $trNo=0;

   foreach my $t ( @tr ) {
       $trNo++;

       ##if ($trNo < 2) { next} ## skip start look for end
       ##
       ##my ($lat, $lng) = split " ", $t;
       ## Błąd powodujący pomijanie 1 odcinka! 4.8.2018 
       my ($lat, $lng) = split " ", $t;
       if ($trNo < 2) {### ### ### 
         $plat = $lat; $plng = $lng; ## !!!
         next;} ## skip strat look for end

       if ($lat < $BB{"lly"} || $lat > $BB{"ury"} || $lng < $BB{"llx"} || $lng > $BB{"urx"} ) { return -1 }

       ##if ($plat > 54.0 ) {## za pierwszym razem nie jest //
       if ($plat > 54.0 ) {## po zmianie 4.8.2019 w zasadzie zbędne 
           $dist = $geo->distance( "meter", $plng, $plat => $lng, $lat );
           $distCalls++;
           ##print STDERR "$distCalls;$plng;$plat;$lng;$lat;$dist\n";
           $distTotal += $dist;

           my $ltg1 = "$plat $plng";
           my $ltg2 = "$lat $lng";

           ### poniższe wymaga dokończenia:
           ### dodać $distTotal5 $distTotal3 do return
           if ($dist > 0) {
              $altDiff = $StationsEE{"$ltg2"} - $StationsEE{"$ltg1"};
              $aveSlope = $altDiff / $dist * 100;

              if ($aveSlope > 3 ) { 
                 $distTotal3 += $dist ; 
                 ## jeszcze stromiej:
                 if ($aveSlope > 5 ) { $distTotal5 += $dist ; }
              }
              ## 
              if    ($dist <= 2000)  { $distTotalLen2  += $dist; }
	      elsif ($dist <= 4000)  { $distTotalLen4  += $dist; }
	      elsif ($dist <= 6000)  { $distTotalLen6  += $dist; }
	      elsif ($dist <= 8000)  { $distTotalLen8  += $dist; }
	      elsif ($dist <= 10000) { $distTotalLen10 += $dist; }
	      elsif ($dist <= 12000) { $distTotalLen12 += $dist; }
	      elsif ($dist <= 14000) { $distTotalLen14 += $dist; }
	      elsif ($dist <= 16000) { $distTotalLen16 += $dist; }
	      elsif ($dist <= 18000) { $distTotalLen18 += $dist; }
	      elsif ($dist <= 20000) { $distTotalLen20 += $dist; }
	      else  { $distTotalLen99 += $dist; }
           }

           my $city1 = $StationsC{$ltg1} ;
           my $city2 = $StationsC{$ltg2} ;

           if ($city1 eq $city2) { $DistByCity{$city1} += $dist ; }
           else { 
              $DistByCity{$city1} += $dist/2 ;
              $DistByCity{$city2} += $dist/2 ;
           }
       }
       $plat = $lat; $plng = $lng;
   }
   return ($distTotal, $distTotal3, $distTotal5, $distTotalLen2, $distTotalLen4,
 	$distTotalLen6, $distTotalLen8, $distTotalLen10, $distTotalLen12, 
	$distTotalLen14, $distTotalLen16, $distTotalLen18, $distTotalLen20, $distTotalLen99);
   ##return ($distTotal);
 } ## // sub count_dist

#### #### ### // eof
