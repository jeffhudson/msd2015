rm(list=ls())
library(dplyr)
library(magrittr)
library(ggplot2)

setwd("C:/Users/Jeff.Bernard/Dropbox/QMSS/gitpages/msd2015/homework/homework_1/problem_3/movielens")

movies <- read.csv("ratings.csv",header=F)
colnames(movies) <- c("user","movie","rating","timestamp")

# calculate and order by popularity, but then throw out raw popularity number,
# just keep the ordered list of movies
inventory <- 
  group_by(movies,movie) %>%
  summarise(pop=n_distinct(user)) %>%
  arrange(desc(pop)) %>% 
  mutate(pop=NULL) %>%
  extract2(1)

# for each user: get list of their rated movies then match with inventory list 
# ranked by popularity so that movie IDs are replaced by their popularity rank,
# then sort the resulting list
userlist <- 
  group_by(movies,user) %>%
  summarise(n = length(unique(movie)),
            movies = list(sort(match(movie,inventory))))

# the last value in a user's movie list indicates the popularity rank of the 
# least popular movie in their list; this is also the inventory size at which
# that user becomes 100% satisfied
userlist$sat100 <- sapply(1:nrow(userlist), function(x) userlist$movies[[x]][userlist$n[x]])

# similarly, the movie at which they become 90% satisfied, is always the one at
# index n*.9 (rounded up) where n is the size of their movie list.
userlist$sat90 <- sapply(1:nrow(userlist), function(x) userlist$movies[[x]][ceiling(.9*userlist$n[x])])

# to construct the data for our plot, we need the # of users satisfied at every 
# inventory size K. thus, for each possible value K, we take the sum of users
# whose 90% or 100% satisfied movie is less than K (and therefore in the
# hypothetical inventory of that size)
sat <- 
  data.frame(invsize = 1:length(inventory),
             ninety = sapply(1:length(inventory), function(x) sum(userlist$sat90 <= x)),
             hundrd = sapply(1:length(inventory), function(x) sum(userlist$sat100 <= x)))

# finally, we plot and annotate our results with some ggplot magic
satplot <- ggplot(data=sat, aes(x=invsize)) + 
  geom_line(aes(y=ninety), color="darkred") + 
  annotate("text",label="90% satisfaction",x=6000,y=nrow(userlist)*.95, 
           color="darkred",size=4,angle=5) + 
  geom_line(aes(y=hundrd), color="darkblue") +
  annotate("text",label="100% satisfaction",x=9000,y=nrow(userlist)*.88, 
           color="darkblue",size=4,angle=20) + 
  scale_x_continuous(name="Inventory Size",breaks=seq(0,11000,2000)) +
  scale_y_continuous(name="Users Satisfied",breaks=seq(0,69878,69878/5),
                     labels=paste0(seq(0,100,20),"%")) +
  theme(panel.background = element_rect(fill="white"),
        panel.grid.major = element_line(color="gray",linetype="dotted"),
        panel.grid.minor = element_line(linetype="blank"),
        axis.ticks = element_line(linetype="blank"),
        text = element_text(color="gray35"),
        plot.title = element_text(size=20, color="gray20")) +
  ggtitle("Eccentricity of MovieLens Users") + 
  annotate("text",label="Data courtesy of MovieLens and the University of Minnesota",
           size=3,x=11000,y=nrow(userlist)*.05,hjust=1,color="gray20")
satplot