# This scipt is designed to errro as "bargraph.data" does not exist
#< Reading data
data = read.table("bargraph.data")

#< Plotting data as barplot
barplot(t(data))