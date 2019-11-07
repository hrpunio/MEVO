## http://www.statmethods.net/stats/regression.html
## http://www.cookbook-r.com/Statistical_analysis/Regression_and_correlation/
## google:: trust wvs  Heston et al.
## http://tdhock.github.io/animint/geoms.html
require(ggplot2)

## Extended set (with data on stages/slope/38 variables)
d <- read.csv("MEVO_DAILY_TIMES.csv", sep = ';',  header=T, na.string="NA");

d$Date <- as.Date(d$date,  "%Y-%m-%d") 
d$month <- as.Date(cut(d$Date, breaks = "month"))
d$week <- as.Date(cut(d$Date, breaks = "week"))

## ## ## Agregaty miesięczne/tygodniowe
## Dystans łącznie miesięcznie/tygodniowo:
dist.monthly <- ggplot(d, aes(month, dist)) +
     ggtitle("MEVO: dystans miesięczny łącznie") +
     ylab(label="tys km") +
     scale_y_continuous(breaks=c(100000, 200000, 300000, 400000, 500000, 600000,700000, 800000, 900000),
     labels=c("100", "200", "300", "400", "500", "600", "700", "800", "900")) +
     stat_summary(fun.y = sum, geom = "bar", fill="steelblue")

bikes.monthly <- ggplot(d, aes(month, bikes)) +
     ggtitle("MEVO: przeciętna liczba rowerów w miesiącu") +
     ylab(label="#") +
     scale_y_continuous(breaks=c(250, 500, 750, 1000, 1250, 1500)) +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")

dist.weekly <- ggplot(d, aes(week, dist)) +
     ggtitle("MEVO: dystans tygodniowy łącznie") +
     ylab(label="tys km") +
     scale_y_continuous(breaks=c(25000, 50000, 75000, 100000, 125000, 150000, 175000, 200000, 225000, 250000),
     labels=c("25", "50", "75", "100", "125", "150", "175", "200", "225", "250")) +
     stat_summary(fun.y = sum, geom = "bar", fill="steelblue")

time.monthly <- ggplot(d, aes(month, time)) +
     ggtitle("MEVO: dystans miesięczny łącznie") +
     ylab(label="mln min") +
     scale_y_continuous(breaks=c(1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 7000000, 8000000, 9000000),
     labels=c("1", "2", "3", "4", "5", "6", "7", "8", "9")) +
     stat_summary(fun.y = sum, geom = "bar", fill="steelblue")

dist.monthly
dist.weekly
bikes.monthly

medianstagetime.monthly <- ggplot(d, aes(month, mediantime)) +
     ggtitle("MEVO: czas odcinka (średnia miesięczna dziennej mediany)") +
     ylab(label="min") +
     scale_y_continuous(breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90),
     labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90")) +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")

medianstagetime.weekly <- ggplot(d, aes(week, mediantime)) +
     ggtitle("MEVO: czas odcinka (średnia tygodniowa dziennej mediany)") +
     ylab(label="min") +
     scale_y_continuous(breaks=c(10, 20, 30, 40, 50, 60, 70, 80, 90),
     labels=c("10", "20", "30", "40", "50", "60", "70", "80", "90")) +
     stat_summary(fun.y = mean, geom = "bar", fill="steelblue")

medianstagetime.monthly
medianstagetime.weekly

### Dane dzienne ###
## Dzienny dystans (wszystkie miasta)
dist.total <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: dzienny dystans łącznie") +
  geom_line(aes(y = dist, colour = 'dist'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=dist, colour='dist'), method="loess", size=1) +
  ylab(label="km") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

time.total <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: dzienny czas wykorzystania łącznie") +
  scale_y_continuous(breaks=c(100000, 200000, 300000, 400000, 500000, 600000),
     labels=c("100", "200", "300", "400", "500", "600")) +
  geom_line(aes(y = time, colour = 'time'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=time, colour='time'), method="loess", size=1) +
  ylab(label="tys min") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

## 100% usage = bikes x 24 x 60
d$timep <- d$time / (d$bikes * 24 * 60) * 100

time.ptotal <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: dzienny czas wykorzystania (%)") +
  geom_line(aes(y = timep, colour = 'timep'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=timep, colour='timep'), method="loess", size=1) +
  ylab(label="%%") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

stage.time <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: czas odcinka (mediana)") +
  geom_line(aes(y = mediantime, colour = 'mediantime'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=mediantime, colour='mediantime'), method="loess", size=1) +
  ylab(label="minuty") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

dist.total
time.total
time.ptotal
stage.time

distcomp.total <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: dzienny dystans stacje vs ogółem") +
  geom_line(aes(y = dist, colour = 'dist'), size=.5) +
  geom_line(aes(y = distTotal, colour = 'distTotal'), size=.5) +
  ylab(label="km") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

d$diffdist <- d$distTotal/d$dist * 100

diffdist.total <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: dzienny dystans stacje jako % ogółem") +
  geom_line(aes(y = diffdist, colour = 'diffdist'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=diffdist, colour='diffdist'), method="loess", size=1) +
  ylab(label="%%") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

distcomp.total 
diffdist.total

### Dziennie rowery
bikes25.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: liczba rowerów z przebiegiem 25km i więcej") +
  geom_line(aes(y = bike25, colour = 'bike25'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=bike25, colour='bike25'), method="loess", size=1) +
  ylab(label="##") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bikes00.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: liczba rowerów z przebiegiem 0km ") +
  geom_line(aes(y = bike00, colour = 'bike00'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=bike00, colour='bike00'), method="loess", size=1) +
  ylab(label="##") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bikes25.daily
bikes00.daily

d$b25p <- d$bike25/d$bikes * 100

bikes25p.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: liczba rowerów z przebiegiem 25km i więcej (% wszystkich)") +
  geom_line(aes(y = b25p, colour = 'b25p'), size=.5) +
  geom_smooth(aes(x = as.Date(date), y=b25p, colour='b25p'), method="loess", size=1) +
  ylab(label="%%") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bikes25p.daily

zbcomp.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: rowery z przebiegiem zero (stacje/ogółem)") +
  geom_line(aes(y = zb, colour = 'zb'), size=.5) +
  geom_line(aes(y = bike00, colour = 'bike00'), size=.5) +
  ylab(label="##") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

zbcomp.daily

bikes.bikes.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: rowery ogółem (stacje/ogółem)") +
  geom_line(aes(y = bikes, colour = 'bikes'), size=.5) +
  geom_line(aes(y = bikesTotal, colour = 'bikesTotal'), size=.5) +
  ylab(label="##") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bikes.bikes.daily

d$bb <- d$bikesTotal/d$bikes * 100

bb.daily <- ggplot(d, aes(x = as.Date(date))) +
  ggtitle("MEVO: rowery ogółem (stacje/ogółem %%)") +
  geom_line(aes(y = bb, colour = 'bb'), size=.5) +
  ylab(label="%%") +
  labs(colour = "") +
  theme(legend.position="top") +
  theme(legend.text=element_text(size=10));

bb.daily
