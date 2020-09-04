
library(ggplot2)

# Added list of other instances that should be marked as 'NA' 
# since some instances were just empty strings or a single space

ny = read.csv('new_york_city.csv', na = c("", "N/A", "NA", " ")) 
wash = read.csv('washington.csv', na = c("", "N/A", "NA", " "))
chi = read.csv('chicago.csv', na = c("", "N/A", "NA", " "))

head(ny)

head(wash)

head(chi)

# looking at Trip Duration by User Type 
by(chi$Trip.Duration/60, chi$User.Type, mean)

by(ny$Trip.Duration/60, ny$User.Type, mean)

by(wash$Trip.Duration/60, wash$User.Type, mean)

ny_chi=rbind(ny,chi) # Combine data from two cities

# Explore the data 

print("User Age Info")
summary(2020-ny$Birth.Year) # New York
summary(2020-chi$Birth.Year) # Chicago
summary(2020-ny_chi$Birth.Year) # Combined


# Info on user's main trip duration
# A noticable outlier can be seen in "Max"
print("Trip Duration")
summary(ny_chi$Trip.Duration)

# Duration in seconds split by 60 to get minutes
# 2020 - Age to get current age (could be aother year, but I chose to go with 2020)

ggplot(aes(x=2020-Birth.Year, y=Trip.Duration/60), data = ny_chi) + 
geom_jitter(alpha=1/10, color = 'orange') + 
scale_y_continuous(limit=c(0,50), breaks=seq(0,50, by=5)) + 
scale_x_continuous(limit=c(20, 80), breaks=seq(20,80,by=20)) +
labs(x = 'Age') +
geom_line(stat = 'summary', fun.y=mean, color='black') +
ggtitle("Trip Durations for Users of Different Ages")

# Dropping the last two columns from the New York and Chicago Datasets
ny = subset(ny, select=-c(Gender,Birth.Year)) 
chi = subset(chi, select=-c(Gender,Birth.Year))
comb = rbind(ny,chi,wash) # combine all three datasets

# Creating a new column that combines start station with end startion to create a unique "trip"
comb$Trip.Taken <- factor(paste(comb$Start.Station, comb$End.Station, sep=" > "))

# Creating a new dataframe that counts the frequency of each unique trip
trip_freq <- aggregate(data.frame(count = comb$Trip.Taken), list(value=comb$Trip.Taken), length)
trip_freq <- trip_freq[with(trip_freq, order(-trip_freq$count)),]

# A function that generates a new dataframe for data for the top n
# This number can only be up to 26 (alphabet)
# That's okay because we want to keep it small here

top_n_trip_freq <-function(n) 
{ 
    if (n>26|n<1) { print("Number must be between 1 and 26") 
                   
    } else {top_n_trips <- head(trip_freq, n)
        top_n_trips <- cbind(top_n_trips, Trip_ID = c(paste("Trip ", LETTERS[1:n], sep="")))}
}

# Since we want the top 10, we run the function with n=10
top_n_trips <- top_n_trip_freq(10)

ggplot(top_n_trips, aes(x=Trip_ID, y=count)) + geom_bar(stat='identity') +
coord_flip() +
theme_light(base_size = 16) +
labs(x='Trips') +
labs(y='Number of Times Trip was Taken')
ggtitle("Top 10 Most Popular Trips ")

# Reference for trips
print("Reference Point for Trips (Start and End Stations)")
top_n_trips


# Extract Month name regardless of day or year
comb$Month <- month.name[as.numeric(substring(comb$Start.Time, 6,7))]

# Remove NA entries from User Type
comb = subset(comb, !is.na(User.Type))
# Checking data for User Types
summary(comb$User.Type)

# Taking a look at total trip durations during different months
# We notice missing data for many months. 
by(comb$Trip.Duration/60, comb$Month, sum)

# to order the x-axis cronologically by month
comb$Month <- factor(comb$Month, levels=month.name)

ggplot(aes(x=Month), data=comb) +
geom_histogram(stat='count', color='dark blue', fill='light blue') +
facet_wrap(~ User.Type) +
labs(x = 'Month', y = 'Number of Trips') +
ggtitle("Total Trips taken by Customers and Subscribers for Each Month")

ggplot(data=comb, aes(x = comb$Month, y=comb$Trip.Duration/60)) +
geom_jitter(alpha=1/10, color = 'orange') +
scale_y_continuous(limit=c(0,250), breaks=seq(0,250, by=25)) +
facet_wrap(~ User.Type) +
labs(x = 'Month', y = 'Trip Durations') +
ggtitle("Durations of Trips Taken by Customers and Subscribers for Each Month")

system('python -m nbconvert Explore_bikeshare_data.ipynb')
