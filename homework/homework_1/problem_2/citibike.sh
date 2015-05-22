#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f4 | sort | uniq | wc -l
# count the number of unique bikes
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f12 | sort | uniq | wc -l
# extract all of the trip start times
cut -d -f2 201402-citibike-tripdata.csv > starttimes.txt
# count the number of trips per day
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d\  -f1 | tr '"' ' ' | sort | uniq -c
# find the day with the most rides
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d\  -f1 | tr '"' ' ' | sort | uniq -c | sort | tail -n1
# find the day with the fewest rides
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d\  -f1 | tr '"' ' ' | sort | uniq -c | sort | head -n1
# find the id of the bike with the most rides
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f12 | sort | uniq -c | sort | tail -n1
# count the number of riders by gender and birth year
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f14,15 | sort | uniq -c
# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f5 | awk '/[0-9].*&.*[0-9]/' | wc -l
# compute the average trip duraction
tail -n+2 201402-citibike-tripdata.csv | cut -d, -f1 | tr '"' ' ' | awk '{tot += $1} END {print "average = " tot/NR}'
