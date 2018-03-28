#install.packages("caret")
#install.packages("ggplot2")
#install.packages("sqldf")
#install.packages("e1071")
#install.packages("rmarkdown")
library(ggplot2)
library(caret)
library(sqldf)
library(e1071)
library(rmarkdown)

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
probEisSpam <- function(dataSet, event, threshold){

  colNumber <- match(event, names(dataSet))
  
  nrowSpamandEvent <- nrow(dataSet[dataSet$type == "spam" & dataSet[colNumber] > threshold,])
  nrowSpam <- nrow(dataSet[dataSet$type == "spam",])
  
  pSpamandEvent <- nrowSpamandEvent / nrowSpam
  
  nrowNonSpamandEvent <- nrow(dataSet[dataSet$type == "nonspam" & dataSet[colNumber] > threshold,])
  nrowNonSpam <- nrow(dataSet[dataSet$type == "nonspam",])
  
  pNonSpamandEvent <- nrowNonSpamandEvent / nrowNonSpam
  
  probability <- pSpamandEvent*0.9/(pSpamandEvent*0.9 + pNonSpamandEvent*0.1)
  
  return(probability)
}

pwill <- probEisSpam(trainSet, "will",0)
pwill
pyou <- probEisSpam(trainSet, "you",0)
pyou
pfree <- probEisSpam(trainSet, "free",0)
pfree
premove <- probEisSpam(trainSet, "remove",0)
premove
pExclamation <- probEisSpam(trainSet, "charExclamation",0)
pExclamation
pDollar <- probEisSpam(trainSet, "charDollar",0)
pDollar


#Create confusion matrix for training charExclamation
trainSet$singlecharExclamation <- "filternonspam"
trainSet$singlecharExclamation[trainSet$charExclamation > 0] <- "filterspam"
table(trainSet$singlecharExclamation, trainSet$type)

#Create confusion matrix for training remove
trainSet$singleremove <- "filternonspam"
trainSet$singleremove[trainSet$remove > 1] <- "filterspam"
table(trainSet$singleremove, trainSet$type)

#Create confusion matrix for both
trainSet$both <- "filternonspam"
trainSet$both[trainSet$remove > 0 & trainSet$charExclamation > 0] <- "filterspam"
table(trainSet$both, trainSet$type)


View(trainSet)

# Results with Naive Bayes Library
trainSet <- NULL
testSet <- NULL

trainSet <- spam[trainIndex, ]
testSet <- spam[-trainIndex,]

Naive_Bayes_Model <- naiveBayes(type ~., data=trainSet)
Naive_Bayes_Model

#Prediction on the dataset
NB_Predictions <- predict(Naive_Bayes_Model,testSet)
table(NB_Predictions,testSet$type)


