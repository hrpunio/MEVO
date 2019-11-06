# MEVO

## Struktura pliku YYYYMMDD_log.csv

Na podstawie pliku JavaScript o nast. zawartości (fragment):

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

miejsce-postojowe+miejsce-postojowe+miejsce-postojowe+...

miejsce-postojowe to:

```
{S#number|B#city}=latitude longitude=bikes=bike_list;
````

jeżli S to stacja jeżeli B to rower-poza-stacją

jeżeli S to wstawiamy numer-stacji po znaku #

jeżeli B to wstawiamy skrót nazwy miasta (po znaku #)

bike_list to lista numerów rowerów w tym miejscu postojowym (odzielona przecinkami

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

