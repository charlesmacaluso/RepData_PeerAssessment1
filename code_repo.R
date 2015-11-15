setwd("~/R/reproducible_research/RepData_PeerAssessment1")
library(plyr)
library(ggplot2)
this_dataset <- read.csv("./activity/activity.csv")
slim_dataset <- this_dataset; slim_dataset$interval <- NULL
sum_dataset <- ddply(slim_dataset, .(date), summarize,
                     sum_steps = sum(steps, na.rm = TRUE))
qplot(sum_steps, data = sum_dataset, geom = "histogram", 
      xlab = "Daily Number of Steps", ylab = "Instances", 
      main = "Histogram of Daily Steps Taken", binwidth = 1000)
mean(sum_dataset$sum_steps)
median(sum_dataset$sum_steps)

#-------------------------------------------------------------------------

slim_dataset_2 <- this_dataset; slim_dataset_2$date <- NULL
interval_dataset <- ddply(slim_dataset_2, .(interval), summarize,
                     avg_steps = mean(steps, na.rm = TRUE))
qplot(interval, avg_steps, data = interval_dataset, geom = "line", 
      xlab = "Time of Day", ylab = "Average Steps Taken", 
      main = "Average Steps Taken During the Day")
interval_dataset[interval_dataset$avg_steps == 
                     max(interval_dataset$avg_steps),]

#-------------------------------------------------------------------------

summary(this_dataset$steps)
clean_dataset <- this_dataset
for(i in 1:nrow(clean_dataset)) {
    if(is.na(clean_dataset[i,"steps"])) {
        clean_dataset[i, "steps"] <-
            interval_dataset[interval_dataset$interval == 
                                 clean_dataset[i, "interval"],"mean_steps"]
    }
}
slim_dataset_3 <- clean_dataset; slim_dataset_3$interval <- NULL
sum_dataset_3 <- ddply(slim_dataset_3, .(date), summarize,
                     sum_steps = sum(steps, na.rm = TRUE))
qplot(sum_steps, data = sum_dataset_3, geom = "histogram", 
      xlab = "Daily Number of Steps", ylab = "Instances", 
      main = "Histogram of Daily Steps Taken", binwidth = 1000)
summary(sum_dataset$sum_steps); summary(sum_dataset_3$sum_steps)

#-------------------------------------------------------------------------

clean_dataset$day_type <- 0
clean_dataset$date <- as.POSIXct(clean_dataset$date)
for(i in 1:nrow(clean_dataset)) {
    if(weekdays(clean_dataset[i, "date"]) == "Saturday" |
       weekdays(clean_dataset[i, "date"]) == "Sunday") {
        clean_dataset[i, "day_type"] <- "Weekend"
    } else {
        clean_dataset[i, "day_type"] <- "Weekday"
    }
}
interval_dataset_3 <- ddply(clean_dataset, .(interval, day_type), summarize,
                       mean_steps = mean(steps, na.rm = TRUE))
qplot(interval, mean_steps, data = interval_dataset_3, geom = "line", 
      xlab = "Time of Day", ylab = "Average Steps Taken", 
      main = "Average Steps Taken During Weedkays Versus Weekends",
      facets = day_type ~ .)