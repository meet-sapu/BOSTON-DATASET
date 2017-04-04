# BOSTON-DATASET

This dataset contains information collected by the U.S Census Service concerning housing in the area of Boston Mass. It was obtained from the StatLib archive (http://lib.stat.cmu.edu/datasets/boston), and has been used extensively throughout the literature to benchmark algorithms. However, these comparisons were primarily done outside of Delve and are thus somewhat suspect. The dataset is small in size with only 506 cases.
The data was originally published by Harrison, D. and Rubinfeld, D.L. 'Hedonic prices and the demand for clean air', J. Environ. Economics & Management, vol.5, 81-102, 1978.
The name for this dataset is simply boston. It has two prototasks: nox, in which the nitrous oxide level is to be predicted; and price, in which the median value of a home is to be predicted.
We start by spliting the boston dataset into a training and testing set . we start by applying Decision tree , usind rpart() in R .
Then we check for missing values and imbalance in the dataset . 
There are ni missing values but the dataset is imbalanced , so we will use the SMOTE algorithm to work on the imbalance training set .
After this we try and apply a different algorithm XGboost and compare its accuracy and quality with the base rpart() model .
We furthur improve the model by dimmiensionality reduction by PCA and use that dimensionally reduced data to build a decision tree and this gives the best result .

R

As usual, we will first download our datasets locally, and then we will load them into data frames in both, R .
Source of dataset : https://archive.ics.uci.edu/ml/datasets/Housing
In R, we use read.csv to read CSV files into data.frame variables. Although the R function read.csv can work with URLs, https is a problem for R in many cases, so you need to use a package like RCurl to get around it. 
Libraries used :
library(readxl) #to read .xlsv file . 
library(caTools) #for sample.split .
library(rpart) #for prediction() , performance() .
library(rpart.plot) #for plotting ROC curve .
library(xgboost) #for applying XGboost .
library(DMwR) #for applying SMOTE .
library(factoextra) #for PCA

