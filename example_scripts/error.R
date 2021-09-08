monitauR::monitor()
# This script is designed to error as "bargraph.data" does not exist
#< Reading data
data = read.table("bargraph.data")

#< Plotting data as barplot
barplot(t(data))
