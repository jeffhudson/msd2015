library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(ggplot2)
library(dplyr)

# read business and world articles into one data frame
rm(list=ls())
setwd("C:/Users/Jeff.Bernard/Dropbox/QMSS/gitpages/msd2015/homework/homework_2/problem_2/")
bizns <- read.table("business.tsv", fileEncoding="UTF-8")
world <- read.table("world.tsv", fileEncoding="UTF-8")

# create a Corpus from the article snippets
VS <- VectorSource(c(as.character(bizns$snippet),as.character(world$snippet)))

# remove punctuation and numbers
Corp <- VCorpus(VS) %>% tm_map(removeNumbers) %>% tm_map(removePunctuation)

# create a DocumentTermMatrix from the snippet Corpus
dtm <- DocumentTermMatrix(Corp)

# convert the DocumentTermMatrix to a sparseMatrix, required by cv.glmnet
# helper function
dtm_to_sparse <- function(dtm) {
 sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)
}

sp <- dtm_to_sparse(dtm)

# create a train / test split

set.seed(101)
ttsplit <- 0.2
test <- sample.int(nrow(sp),nrow(sp)*ttsplit)
testlabels <- test < 1001
trainlabels <- (1:nrow(sp))[-test] < 1001
testset <- sp[test,]
trainset <- sp[-test,]

# cross-validate logistic regression with cv.glmnet, measuring auc
crossval <- cv.glmnet(trainset, trainlabels, family="binomial", type.measure="auc", nfolds=10)

# evaluate performance for the best-fit model
plot(crossval)

# plot ROC curve and output accuracy and AUC
preds <- predict(crossval,newx=testset)
pred.obj <- prediction(preds,testlabels)
ROC <- performance(pred.obj,measure="tpr",x.measure="fpr")
plot(ROC)
acc <- performance(pred.obj,measure="acc")
plot(acc)
max(acc@y.values[[1]])
AUC <- performance(pred.obj,measure="auc")@y.values[[1]]


# extract coefficients for words with non-zero weight
# helper function
get_informative_words <- function(crossval) {
  coefs <- coef(crossval, s="lambda.min")
  coefs <- as.data.frame(as.matrix(coefs))
  names(coefs) <- "weight"
  coefs$word <- row.names(coefs)
  row.names(coefs) <- NULL
  subset(coefs, weight != 0)
}

infowds <- get_informative_words(crossval)
sorted <- arrange(infowds,weight)

# show weights on words with top 10 weights for business
arrange(tail(sorted,10),desc(weight))

# show weights on words with top 10 weights for world
head(sorted,10)
