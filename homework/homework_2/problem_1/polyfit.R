rm(list=ls())
library(ggplot2)
library(dplyr)
theme_set(theme_bw())

setwd("C:/Users/Jeff.Bernard/Dropbox/QMSS/gitpages/msd2015/homework/homework_2/problem_1/")
# read data
data <- read.table('polyfit.tsv', header=T)

# split into train / test data
setseed(101)
ttsplit <- 0.5 # given in problem description
test <- sample.int(nrow(data),nrow(data)*ttsplit)
testset <- data[test,]
trainset <- data[-test,]

# fit a model and compute train / test error for each degree
fit_poly <- function(trainset,testset,num_poly=50){
  fit <- list()
  RMSE <- matrix(0,nrow=num_poly,ncol=3)
  for(i in 1:num_poly){
    trainpoly <- as.data.frame(cbind(y=trainset$y,poly(trainset$x,i,raw=T)))
    testpoly <- as.data.frame(cbind(y=testset$y,poly(testset$x,i,raw=T)))
    fit[[i]] <- lm(y ~ ., data=trainpoly)
    trnRMSE <- sqrt(mean(fit[[i]]$residuals^2))
    tstRMSE <- sqrt(mean((testpoly$y - (predict(fit[[i]],newdata=testpoly)))^2))
    RMSE[i,] <- cbind(i,trnRMSE,tstRMSE)
  }
  return(list(fit,RMSE))
}

results <- fit_poly(trainset,testset)
RMSE <- as.data.frame(results[[2]])
which.min(RMSE$V3)
min(RMSE$V3)
bestmodel <- results[[1]][[bestpoly]]


# select best model

## run 50 times to ensure best polynomial fit is robust to test split idiosyncrasy
find_best_poly <- function(n,data){
  bestpoly <- rep(0,n)
  for(i in 1:n){
    test <- sample.int(nrow(data),nrow(data)*ttsplit)
    testset <- data[test,]
    trainset <- data[-test,]
    results <- fit_poly(trainset,testset)
    RMSE <- as.data.frame(results[[2]])
    bestpoly[i] <- which.min(RMSE$V3)
  }
  return(bestpoly)
}

CV <- find_best_poly(50,data)
bestpoly <- table(CV) %>% which.max %>% names %>% as.numeric

ggplot(RMSE, aes(x=V1)) + 
  geom_line(aes(y=V2), color="darkred") + 
  geom_line(aes(y=V3), color="darkblue") +
  annotate("text",label="Training Error", x=40, y=0.014, color="darkred") + 
  annotate("text",label="Testing Error", x=40, y=0.033, color="darkblue") +
  labs(title="Error as function of polynomial degree",y="RMSE",x="Polynomial Degree")

# plot fit for best model
model <- function(x,coefs) {
  y <- coefs[1]
  for(i in 1:bestpoly){
    y <- y + (x^(i))*coefs[i+1]
  }
  return(y)
}
ggplot(data) + geom_point(aes(x,y)) + 
  stat_function(fun=model,args=list(coefs=bestmodel$coef),color="red",size=1)

# report coefficients for best model
coefs
