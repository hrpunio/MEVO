# MEVO

Mevo to nieudany projekt roweru miejskiego działający w Trójmieście i okolicach
od końca marca do końca października 2019r (siedem miesięcy). 
(więcej https://pl.wikipedia.org/wiki/Mevo)

## Struktura pliku YYYYMMDD_log.csv

Na podstawie pliku JavaScript o następującej zawartości (fragment, po ### komentarze):

```
var NEXTBIKE_PLACES_DB = '
[{"places":[{
  "uid":10735791,
  "lat":54.381206488333,    ### latitude/szerokość
  "lng":18.605451056667,    ### longitude/długość
  "bike":false,             ### stacja (jeżeli = 0/false) lub luźny rower (poza stacją, jeżeli = 1/true)
  "name":"11001",           ### nazwa miejsca (numer stacji)
  "address":null,
  "spot":true,
  "number":11001,           ### numer-miejsca
  "bikes":0,                ### liczba-rowerów-zaparkowanych
  "booked_bikes":0,
  "bike_racks":9,
  "free_racks":9,
  "special_racks":0,
  "free_special_racks":0,"maintenance":false,
  "terminal_type":"sign",   ### lista-numerów-rowerów (lub pusta)
  "bike_list":[],
  "bike_numbers":[],"bike_types":[],"place_type":"0","rack_locks":false,
  "city":"Gda\u0144sk"      ### miasto
 },
 {"uid":10736242,....
```

tworzony jest plik CSV o następującej zawartości:

```
YYYYMMDDHHMMSS;lista-miejsc-postojowych
```

gdzie YYYYMMDDHHMMSS to stempel czasu a lista-miejsc-postojowych to
miejsca-postojowe odzielone znakiem + (plus):

```
miejsce-postojowe+miejsce-postojowe+miejsce-postojowe+...
```

miejsce-postojowe ma następującą strukturę:

```
{S#number|B#city}=latitude longitude=bikes=bike_list;
````

jeżli S to stacja jeżeli B to rower-poza-stacją

jeżeli S to po znaku # jest numer-stacji

jeżeli B to po znaku # jest skrót nazwy miasta

bike_list to lista numerów rowerów w tym miejscu postojowym (odzielona przecinkami)

Przykłady:

```
S#11001=54.38120649 18.60545106=0=   ### stacja 11001 0 rowerów
S#11007=54.42081020 18.57016036=1=98659    ## stacja 11007 1 rower
S#11018=54.40108751 18.67152089=5=98503,98178,99148,600268,600214 ## stacja 11018 5 rowerów
B#GD=54.33133333 18.53560222=1=99152  ## rower zaparkowany w GD (Gdańsk)
```

Skróty nazw miast:

'Gdańsk' = 'GD', 'Pruszcz Gdański' = 'PG', 'Gdynia' = 'GA',
'Tczew' = 'TC', 'Sopot' = 'SP', 'Rumia' = 'RU',
'Reda' = 'RE', 'Puck' = 'PU', 'Żukowo' = 'ZU',
'Kartuzy' = 'KT', 'Somonino' = 'SO', 'Sierakowice' = 'SI', 'Władysławowo' = 'WW',
'Stężyca' = 'ST', 'Gdańsk-Wawa' = 'GDWA'

## Plik MEVO_DAILY_BIKES.csv

Zawiera dzienne agregaty obliczone na podstawie plików YYYYMMDD_log.csv:

```
day;bikes;zb;dist.total;ga;gd;sop;tczew;rumia;s10111;s10111d;s10112;\
s10112d;zstat;sstat;gd0p;ga0p;sop0p;tczew0p;rumia0p;gd1p;ga1p;sop1p;\
tczew1p;rumia1p;slope3;slope5;stage2;stage4;stage6;stage8;stage10;stage12;\
stage14;stage16;stage18;stage20;stage99
```

Przy czym:

bikes -- łączna liczba rowerów dostępnych/wykazanych w ciągu dnia w
plikach locations.js;

zb -- łączna liczba rowerów wykazanych, które nie były używane
(zero-bikes);

dist.total -- dystans łącznie (liczony po prostej);

ga/gd/sop/tczew/rumia -- dystans łącznie (liczony po prostej dla
miast; jeżeli rower przejechał z miasta do miasta to każde miasto
dostaje połowę);

s10111/s10112 --przeciętna liczba rowerów na stacjach s10111/s10112 liczona
jako (r1 + ... + rN)/N (ri -- liczba rowerów na stacji i;
N -- liczba pobrań pliku locations.js, jeżeli pobrano wszystkie to N=720/dobę (24 * 30));

s10111d/s10112d -- przeciętna liczba rowerów na stacjach s10111/s10112
w godzinach 5--23;

zstat -- przeciętny odsetek stacji bez rowerów (zero-stations),
liczony jako (s1+... + sN)/(S × N) * 100 (si -- liczba stacji bez rowerów;
N -- liczba pobrań pliku locations.js; S -- liczba stacji w systemie);

sstat -- przeciętny odsetek stacji z maksimum jednym rowerem
(single-stations), liczony jako
(s1+... + sN)/(S × N) * 100 (si -- liczba stacji bez rowerów lub z jednym rowerem; reszta
jak wyżej);

gd0p/ga0p/sop0p/tczew0p/rumia0p -- przeciętny odsetek stacji bez
rowerów (zero-stations) dla miast (gd/ga/sop/tczew/rumia). Liczony podobnie jak
zstat tylko si/S -- dotyczy stacji w danym mieście oczywiście a nie ogółem;

gd1p/ga1p/sop1p/tczew1p/rumia1p -- przeciętny odsetek stacji z
maksimum jednym rowerem (single-stations) dla miast
(gd/ga/sop/tczew/rumia). Liczony jak sstat tylko si/S dotyczy stacji w
danym mieście oczywiście a nie ogółem;

slope3/slope5 -- łączny dystans przejechanych odcinków o nachyleniu
przeciętnym 3%/5% (liczonym po prostej);

stage2/stage4 itd -- łączny dystans przejechanych odcinków o długości
0--2km, 2--4km itd (liczonym po prostej)
