## http://www.statmethods.net/stats/regression.html
## http://www.cookbook-r.com/Statistical_analysis/Regression_and_correlation/
## google:: trust wvs  Heston et al.
## http://tdhock.github.io/animint/geoms.html
require(ggplot2)

## Extended set (with data on stages/slope/38 variables)
d <- read.csv("MEVO_DAILY_BIKES.csv", sep = ';',  header=T, na.string="NA");
## Moving bikes
nzb <- d$bikes - d$zb
## Dist by stage as % of total
stage2p <- (d$stage2)/d$dist.total * 100
stage24p <- (d$stage2 + d$stage4)/d$dist.total * 100
## 0-4km
stage24 <- d$stage2 + d$stage4

## Add to dataframe
d["stage2p"] <- stage2p
d["stage24p"] <- stage24p
d["stage24"] <- stage24

d$Date <- as.Date(d$day,  "%Y-%m-%d") 
d$month <- as.Date(cut(d$Date, breaks = "month"))
d$week <- as.Date(cut(d$Date, breaks = "week"))

## ## ## Agregaty miesięczne/tygodniowe
## Dystans łącznie miesięcznie/tygodniowo:
dist.monthly <- ggplot(d, aes(month, dist.total)) +
     ggtitle("MEVO: dystans miesięczny łącznie (kwiecień 13-30/04)") +
     ylab(label="tys km") +
     scale_y_continuous(breaks=c(100000, 200000, 300000, 400000, 500000, 600000,700000, 800000, 900000),
     labels=c("100", "200", "300", "400", "500", "600", "700", "800", "900")) +
     stat_summary(fun.y = sum, geom = "bar", fill="steelblue")

bikes.monthly <- ggplot(d, aes(month, bikes)) +
     ggtitle("MEVO: przeciętna liczba rowerów w miesiącu (kwiecień 13--30/04)") +
     ylab(label="km") +
     scale_y_continuous(breaks=c(250, 500, 750, 1000, 1250, 1500)) +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")

dist.weekly <- ggplot(d, aes(week, dist.total)) +
     ggtitle("MEVO: dystans tygodniowy łącznie (kwiecień 13--30/04)") +
     ylab(label="tys km") +
     scale_y_continuous(breaks=c(25000, 50000, 75000, 100000, 125000, 150000, 175000, 200000, 225000, 250000),
     labels=c("25", "50", "75", "100", "125", "150", "175", "200", "225", "250")) +
     stat_summary(fun.y = sum, geom = "bar", fill="steelblue")

dist.monthly
bikes.monthly

dist.weekly

## Przeciętny odsetek stacje bez rowerów Gd/Ga
zb.gd.monthly <- ggplot(d, aes(month, gd0p)) +
     ggtitle("MEVO: % stacji bez rowerów GD  (kwiecień 13--30/04)") +
     ylab(label="%") +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")
zb.ga.monthly <- ggplot(d, aes(month, ga0p)) +
     ggtitle("MEVO: % stacji bez rowerów GA  (kwiecień 13--30/04)") +
     ylab(label="%") +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")

zb.gd.monthly
zb.ga.monthly

## ## ## Statystki dzienne/Dostęp
mstat <- 100 - d$sstat;
d["mstat"] <- mstat;

## stacje wg liczby dostępnych rowerów 0, 1 oraz 2 i więcej
s1 <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO stacje: liczba dostępnych rowerów (zstat=0, sstat<2, mstat>1)") +
  geom_line(aes(y = zstat, colour = 'zstat'), size=.25) +
  geom_line(aes(y = sstat, colour = 'sstat'), size=.25) +
  geom_line(aes(y = mstat, colour = 'mstat'), size=.25) +
  geom_smooth(aes(x = as.Date(day), y=zstat, colour='zstat'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=sstat, colour='sstat'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=mstat, colour='mstat'), method="loess", size=.5) +
  ##geom_line(aes(y = rains, colour = 'rains'), size=1) +
  ylab(label="%") +
  ##theme(legend.title=element_blank()) +
  labs(colour = "Rowery: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## stacje bez rowerów (Ga/Gd)
s2 <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO stacje: 0 dostępnych rowerów (ga =gdynia, gd =gdańsk)") +
  geom_line(aes(y = gd0p,  colour = 'gd0p'), size=.25) +
  geom_line(aes(y = ga0p,  colour = 'ga0p'), size=.25) +
  geom_smooth(aes(x = as.Date(day), y=gd0p, colour='gd0p'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=ga0p, colour='ga0p'), method="loess", size=.5) +
  ylab(label="%") +
  ##theme(legend.title=element_blank()) +
  labs(colour = "Rowery: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## stacje bez rowerów i z jednym rowerem (Ga/Gd)
s3 <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO stacje: max 1 dostępnych rowerów (ga=gdynia, gd=gdańsk)") +
  geom_line(aes(y = gd1p,  colour = 'gd1p'), size=.25) +
  geom_line(aes(y = ga1p,  colour = 'ga1p'), size=.25) +
  geom_smooth(aes(x = as.Date(day), y=gd1p, colour='gd1p'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=ga1p, colour='ga1p'), method="loess", size=.5) +
  ylab(label="%") +
  ##theme(legend.title=element_blank()) +
  labs(colour = "Rowery: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## dostępność rowerów na stacjach (Sopot)
s4 <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO stacje (Sopot): liczba dostępnych rowerów (sop0p=0 / sop1p <2)") +
  geom_line(aes(y = sop1p,  colour = 'sop1p'), size=0.25) +
  geom_line(aes(y = sop0p,  colour = 'sop0p'), size=0.25) +
  geom_smooth(aes(x = as.Date(day), y=sop1p, colour='sop1p'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=sop0p, colour='sop0p'), method="loess", size=.5) +
  ylab(label="%") +
  ##theme(legend.title=element_blank()) +
  labs(colour = "Rowery: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

s1; 
s2; 
s3; 
s4

##
# short.date = strftime(temp$date, "%Y/%m")
# aggr.stat = aggregate(temp$amount ~ short.date, FUN = sum)
## ## ##

## ## ## Statystki dzienne/Rowery/Dystans pokonany:
## Liczba udostępnionych rowerów: używanych i nieużywanych
bikes.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: rowery jeżdżone (nzb) vs niejeżdżone (zb)") +
  geom_point(aes(y = bikes, colour = 'bikes'), size=1) +
  geom_point(aes(y = zb, colour = 'zb'), size=1) +
  geom_point(aes(y = nzb, colour = 'nzb'), size=1) +
  ##geom_line(aes(y = rains, colour = 'nzb'), size=1) +
  geom_smooth(aes(x = as.Date(day), y=bikes, colour='bikes'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=zb, colour='zb'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=nzb, colour='nzb'), method="loess", size=1) +
  ylab(label="#") +
  ##theme(legend.title=element_blank()) +
  labs(colour = "Rowery: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## Dzienny dystans Gd/Ga
dist.gagd.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans (Gdańsk/Gdynia)") +
  geom_point(aes(y = ga, colour = 'ga'), size=1) +
  geom_point(aes(y = gd, colour = 'gd'), size=1) +
  geom_smooth(aes(x = as.Date(day), y=ga, colour='ga'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=gd, colour='gd'), method="loess", size=.5) +
  ylab(label="km") +
  labs(colour = "Miasta: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## Dzienny dystans Tczew/Rumia/Sopot
dist.tcrusp.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans (Tczew/Rumia/Sopot)") +
  geom_point(aes(y = sop, colour = 'sop'), size=1) +
  geom_point(aes(y = tczew, colour = 'tczew'), size=1) +
  geom_point(aes(y = rumia, colour = 'rumia'), size=1) +
  geom_smooth(aes(x = as.Date(day), y=sop, colour='sop'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=tczew, colour='tczew'), method="loess", size=.5) +
  geom_smooth(aes(x = as.Date(day), y=rumia, colour='rumia'), method="loess", size=.5) +
  ylab(label="km") +
  labs(colour = "Miasta: ") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## Dzienny dystans (wszystkie miasta)
dist.total.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans łącznie") +
  geom_line(aes(y = dist.total, colour = 'dist.total'), size=.5) +
  geom_smooth(aes(x = as.Date(day), y=dist.total, colour='dist.total'), method="loess", size=1) +
  ylab(label="km") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bikes.daily;
dist.gagd.daily;
dist.tcrusp.daily;
dist.total.daily;

## Dzienny dystans (odcinki 0-2/0-4km jako procent całości)
stages.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans (odcinki do 2km/4km jako % całości)") +
  geom_line(aes(y = stage2p, colour = 'stage2p'), size=.5) +
  geom_line(aes(y = stage24p, colour = 'stage24p'), size=.5) +
  geom_smooth(aes(x = as.Date(day), y=stage2p, colour='stage2p'), method="loess", size=1) +
  geom_smooth(aes(x = as.Date(day), y=stage24p, colour='stage24p'), method="loess", size=1) +
  ylab(label="%") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## Dzienny dystans (odcinki 0-2/0-4km w km)
stages.dailyKm <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans (odcinki do 2km/4km w km)") +
  geom_line(aes(y = stage2, colour = 'stage2'), size=.5) +
  geom_line(aes(y = stage24, colour = 'stage24'), size=.5) +
  geom_smooth(aes(x = as.Date(day), y=stage2, colour='stage2'), method="loess", size=1) +
  geom_smooth(aes(x = as.Date(day), y=stage24, colour='stage24'), method="loess", size=1) +
  ylab(label="km") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## Dzienny dystans odcinki o nachyleniu 3%/5% w km
slope.daily <- ggplot(d, aes(x = as.Date(day))) +
  ggtitle("MEVO: dzienny dystans (odcinki o nachyleniu 3%/5% w km)") +
  geom_line(aes(y = slope3, colour = 'slope3'), size=.5) +
  geom_line(aes(y = slope5, colour = 'slope5'), size=.5) +
  geom_smooth(aes(x = as.Date(day), y=slope3, colour='slope3'), method="loess", size=1) +
  geom_smooth(aes(x = as.Date(day), y=slope5, colour='slope5'), method="loess", size=1) +
  ylab(label="km") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

stages.daily;
stages.dailyKm;

slope.daily;

## ## end
