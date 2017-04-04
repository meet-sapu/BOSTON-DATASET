library(readxl)
library(caTools)
library(rpart)
library(rpart.plot)
library(xgboost)
library(DMwR)
library(e1071)#for SVM
library(FSelector)
library(factoextra)
library(randomForest)

#Reading and spliting data .

data = read_excel("F:/dataset/boston dataset/boston.xls")
split = sample.split(data$CHAS , SplitRatio = 0.75)
train = subset(data , split==T)
test = subset(data , split==F)

#base CART model .

model = rpart(CHAS ~ . , data = train , method = "class" )
assump = predict(model , newdata = test , type = "prob" )
pred = prediction(assump[,2] , test$CHAS)
pref = performance( pred , "tpr" , "fpr" )
plot(pref)
table(test$CHAS , assump[,2]>0.5)
auc.tmp = performance(pred,"auc")
auc = as.numeric(auc.tmp@y.values)


train = as.matrix(train)
test = as.matrix(test)

#applying xgboost .

bst = xgboost(data = train[,-4] , label = train[,4] , nrounds = 200, objective = "binary:logistic")
pred = predict( bst , test[,-4] , type="prob")
predi = prediction( pred , test[,4])
bst_pref = performance( predi , "tpr" , "fpr")
plot(bst_pref)
table(test[,4] , pred>0.5)
auc.tmp = performance(predi,"auc")
auc = as.numeric(auc.tmp@y.values)

#applying SMOTE to imbalance dataset . 

train = as.data.frame(train)#SMOTE works if data is as.data.frame .
train$CHAS = as.factor(train$CHAS)#SMOTE works only if labels are factors .
train_new = SMOTE (CHAS ~ . , train , perc.over= 600 , perc.under = 200)#SMOTE handles imbalance data.
table(train_new$CHAS)

#applying XGboost on the SMOTEd data .

train_new$CHAS = as.numeric(train_new$CHAS) #making CHAS back to numeric
train_new = as.matrix(train_new)-1 #after into numeric from factor , we need to subtract 1 .
test = as.matrix(test)
model = xgboost(data = train_new[,-4] , label = train_new[,4]  ,eta = 0.15 , nrounds = 170, objective = "binary:logistic")
new_pred = predict(model , test[,-4] , type = "prob")
new_predi = prediction(new_pred , test[,4])
new_perf = performance(new_predi , "tpr" , "fpr")
plot(new_perf)
table(test[,4] , new_pred >0.5)
auc.tmp = performance(new_predi,"auc")
auc = as.numeric(auc.tmp@y.values)


#gives test error and train error of every round ,this is used to find the optimum number of roundes . 

dtrain <- xgb.DMatrix(data = train_new[,-4], label=train_new[,4])
dtest <- xgb.DMatrix(data = test[,-4], label=test[,4])
watchlist = list(train=dtrain, test=dtest)
bstt = xgb.train(data=dtrain , nrounds=300,watchlist=watchlist, objective = "binary:logistic")
mcv = xgb.cv(data = train_new[,-4],label = train_new[,4] ,nrounds = 170 , objective = "binary:logistic" , nfold = 10)


#applying PCA

prin_comp = prcomp(train_new, scale. = T)
biplot(prin_comp, scale = 0)
std_dev = prin_comp$sdev
pr_var = std_dev^2
prop_varex = pr_var/sum(pr_var)

#scee plots to analyse optimum number of components .

plot(prop_varex, xlab = "Principal Component",
     ylab = "Proportion of Variance Explained",
     type = "b")
plot(cumsum(prop_varex), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type = "b")


#predictive modeling on the PCAed data with decision tree .

train.data = data.frame(CHAS = train_new[,4], prin_comp$x)#adding a training set with the above PCA's
train.data = train.data[,1:10]
rpart.model = rpart(CHAS ~ . ,data = train.data, method = "anova")
test.data = predict(prin_comp, newdata = test)
test.data = as.data.frame(test.data)
test.data = test.data[,1:10]
rpart.prediction = predict(rpart.model, test.data )
rpart.predi = prediction( rpart.prediction , test[,4])
curve = performance(rpart.predi  , "tpr" , "fpr") 
plot(curve)
auc.tmp = performance(rpart.predi,"auc")
auc = as.numeric(auc.tmp@y.values)
table(test[,4] , rpart.prediction>0.5)

