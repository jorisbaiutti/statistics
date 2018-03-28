#install.packages("caret")
#install.packages("ggplot2")
#install.packages("sqldf")
library(ggplot2)
library(caret)
library(sqldf)

# set the working directory to the proper folder
# you can either give in the path or click on Session and then Set Working Directory
#setwd("~/Desktop/Spamfilter")

# We set the seed to remove randomness in choosing the training set. 
# I will explain this in class. 
set.seed(10)

# read the data
# type ?read.csv in the console if you need information about a function
spam <- read.csv2(file="SpamFilterData.csv", sep =",", dec = ".") 

# good practice would be to specify the classes for the columns
# colClasses = c(rep("numeric", 6), "factor"))
# information about the object can be extracted by using str
str(spam)

# several options to view the data 
View(spam)
head(spam)
tail(spam, 10)

# get summary
summary(spam)


#*****************

# create an array of indices to partition the data
# p = 0.8 means I will use 80% of the rows for the training set
trainIndex <- createDataPartition(spam$type, p = 0.8, list = FALSE, times = 1)

trainSet <- spam[trainIndex, ]
testSet <- spam[-trainIndex,]



#by Joris

createHistogram <- function(dataSet, event){
  colNumber <- match(event, names(dataSet))
  ggplot(data=dataSet,(aes_string(x = event, fill = "type"))) + geom_histogram(bins = 20) + facet_grid(~type) 
  ggplot(data=trainSet[(dataSet[colNumber] != 0.0),], (aes_string(x = event, fill = "type"))) + geom_histogram(bins = 20) + facet_grid(~type) 
}

colnames(trainSet)

createHistogram(trainSet, "will")
createHistogram(trainSet, "remove")
createHistogram(trainSet, "you")
createHistogram(trainSet, "free")
createHistogram(trainSet, "charExclamation")
createHistogram(trainSet, "charDollar")

#Wahrscheinleichkeit, das Wort in einem Spam Mail vorkommt
probEisSpam <- function(dataSet, event){

  colNumber <- match(event, names(dataSet))
  
  nrowSpamandEvent <- nrow(dataSet[dataSet$type == "spam" & dataSet[colNumber] > 0,])
  nrowSpam <- nrow(dataSet[dataSet$type == "spam",])
  
  pSpamandEvent <- nrowSpamandEvent / nrowSpam
  
  nrowNonSpamandEvent <- nrow(dataSet[dataSet$type == "nonspam" & dataSet[colNumber] > 0,])
  nrowNonSpam <- nrow(dataSet[dataSet$type == "nonspam",])
  
  pNonSpamandEvent <- nrowNonSpamandEvent / nrowNonSpam
  
  probability <- pSpamandEvent*0.9/(pSpamandEvent*0.9 + pNonSpamandEvent*0.1)
  
  return(probability)
}

pExclamation <- probEisSpam(trainSet, "charExclamation")






View(trainSet)
