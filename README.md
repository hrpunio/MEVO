# MEVO

Mevo to nieudany projekt roweru miejskiego działający w Trójmieście i okolicach
od końca marca do końca października 2019r (siedem miesięcy). 
(więcej https://pl.wikipedia.org/wiki/Mevo)

Częścią MEVO oprócz rowerów, stojaków itp był system,
który pozwalał ewentualnym użytkownikom zorientować się ile 
i czy w ogóle (na interesującej ich stacji) jest
rowerów. Informacja ta w postaci stosownego pliku JavaScript
była pobierana co 120s (co 2 minuty). 
Ponieważ łączna objętość oryginalnych plików
przekracza 5Gb zostały one skonwertowane (w opisany poniżej sposób).

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
miejsca-postojowe oddzielone znakiem + (plus):

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

bike_list to lista numerów rowerów w tym miejscu postojowym (oddzielona przecinkami)

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

MEVO_DAILY_BIKES.csv jest wynikiem przetworzenia wszystkich plików YYYYMMDD_log.csv
skryptem mevo2zzz.pl. Skrypt ten pomija rowery-poza-stacją (liczy tylko dla zaparkowanych na stacjach)

Uwaga: liczenie dystansu jest mocno przybliżone: zliczane są odcinki
proste a nie rzeczywiste odległości, jeżeli ktoś przejechał dużo, ale
zaparkował obok miejsca, z którego wyjechał, to różnica też będzie
duża (w skrajnym przypadku jeżeli rower wrócił w to samo miejsce, to
dystans pokonany liczont tą metodą będzie wynosił zero).

Ponadto czasami rower był wożony (przez serwis) i to też jest nie do
odróżnienia (well, można próbować, ale po co -- i tak nie dostaniemy
suma-summarum dokładnego wyniku). Ten drugi przypadek obrazuje sesja
zdjęciowa z 6 sierpnia p. Dulkiewicz (ta w której radziła marszałkowi
Kuchcińskiemu żeby jeździł do Rzeszowa rowerem Mevo; pliki
dulkiewicz_sesja_zdjeciowa_instagram.png,
dulkiewicz_sesja_zdjeciowa_20190806.png,
MEVO_TRACKS_20190806_98735.kml, MEVO_TRACKS_20190805_98735.kml). Rower
był zaparkowany w 7 miejscach, nigdy obok Urzędu Miejskiego, 
gdzie odbyła się sesja zdjęciowa. Wcześnie
rano pojawił się w siedzibie Operatora na terenach MTG (Żaglowa),
następny wpis około 17:00 (na Podwalu Staromiejskim). Zapewne do 17.00 był
szykowany/wożony przez serwis na potrzeby filmowe (że tak powiem).
Ile tak naprawdę przejechał tego dnia -- trudno ustalić. Nb. poprzedniego
przejechał zero (cały dzień tkwił `na warsztacie')

## Plik MEVO_DAILY_TIMES.csv

Zawiera dzienne agregaty obliczone na podstawie plików YYYYMMDD_log.csv (w trochę inny sposób niż
w pliku MEVO_DAILY_BIKES.csv:

```
date;bikes;time;hhmm;dist;speed;mediantime;bike25;bike00;bikesTotal;zb;distTotal
```

Przy czym:

bikes -- łączna liczba rowerów dostępnych/wykazanych w ciągu dnia w
plikach locations.js;

time -- łączny czas wykorzystania rowerów (liczony jako różnica pomiędzy 
pierwszy-czasem-na-nowej-stacji a ostatnim-czasem-na-poprzedniej-stacji; w minutach)

hhmm -- to samo co time ale przeliczone na godziny:minuty

dist -- łączny dystans (liczony po prostej)

speed -- średnia prędkość (czyli dist/time)

mediantime -- mediana czasu odcinka 

bike25 -- liczba rowerów które przejechały 25km i więcej

bike00 -- liczba rowerów które przejechały 0,5km i mniej

bikesTotal;zb;distTotal -- wartości skopiowane z MEVO_DAILY_BIKES.csv, odpowiednio bikes, zb oraz dist.total

MEVO_DAILY_TIMES.csv jest wynikiem przetworzenia wszystkich plików YYYYMMDD_log.csv
skryptem mevo2zzz.pl (powstaje MEVO_DAILY_TIMES.log) 
a następnie dodania bikes, zb oraz dist.total (skrypt mevo_disttime_join.pl)

Skrypt ten nie pomija rowerów-poza-stacją (stąd różnice w wielkości łącznego dystansu)

## Plik MEVO_DAILY_BIKES.csv

Pozycje i wysokości n.p.m stacji MEVO:

```
id;coords;ele;city;remarks
```

Przy czym:

id -- id stacji;

coords -- współrzędne

ele -- wysokość w m.n.p.m

city -- miasto

remarks -- uwagi

Wysokość została dodana z wykorzystaniem programu gpsprune (cf https://wiki.openstreetmap.org/wiki/GpsPrune)


