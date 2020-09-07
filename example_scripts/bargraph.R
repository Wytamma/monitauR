#postscript("log.ps")
#pdf("bargraph.pdf")

data = read.table("bargraph.data")

# Note: need to take transpose of data [ t(data) ] because of source
# table format

barplot(t(data),
    beside=T, 
    legend.text=c("Method A", "Method B"), 
    ylab="Elapsed time (millisec)", 
    xlab="Data set")

#dev.off()  # This is only needed if you use pdf/postscript in interactive mode
