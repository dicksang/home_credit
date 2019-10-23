setwd("C:\\Users\\Dick Sang\\Desktop\\Data Analytics\\Kaggle\\Competition\\1. Home Credit Default Risk\\R code\\LGBM")
rm(list=ls())

# Packages
library(devtools)
library(lightgbm)
library(magrittr)
library(dplyr)
library(Matrix)

# Data
data0 <- read.csv("train_test_final.csv")
str(data0)

# data <- train data
data <- data0[data0$TARGET %in% c("0","1"),]
data_project <- data0[!data0$TARGET %in% c("0","1"),]

# Partition data
set.seed(1234)
ind <- sample(2, nrow(data), replace = T, prob = c(0.8, 0.2))

train <- data[ind==1,]
test <- data[ind==2,]

############################################################
# 1. train + test data (100%)
############################################################
# Create matrix - One-Hot Encoding for Factor variables
# avoid missing lines by the settings
previous_na_action <- options('na.action')
options(na.action='na.pass')
completem <- sparse.model.matrix(TARGET ~ .-1, data = data)
options(na.action=previous_na_action$na.action)
head(completem)

complete_label <- data[,"TARGET"]
# complete_matrix <- xgb.DMatrix(data = as.matrix(completem), label = complete_label)
############################################################
# 1.a. testing data
############################################################
previous_na_action <- options('na.action')
options(na.action='na.pass')
testm <- sparse.model.matrix(TARGET~.-1, data = test)
options(na.action=previous_na_action$na.action)

test_label <- test[,"TARGET"]
# test_matrix <- xgb.DMatrix(data = as.matrix(testm), label = test_label)
############################################################
# 1.b. training data
############################################################
# Create matrix - One-Hot Encoding for Factor variables
# avoid missing lines by the settings
previous_na_action <- options('na.action')
options(na.action='na.pass')
trainm <- sparse.model.matrix(TARGET ~ .-1, data = train)
options(na.action=previous_na_action$na.action)
head(trainm)
# 
train_label <- train[,"TARGET"]
# train_matrix <- xgb.DMatrix(data = as.matrix(trainm), label = train_label)
############################################################
# 1.b. testing data
############################################################
# previous_na_action <- options('na.action')
# options(na.action='na.pass')
# testm <- sparse.model.matrix(TARGET~.-1, data = test)
# options(na.action=previous_na_action$na.action)
# 
# test_label <- test[,"TARGET"]
# test_matrix <- xgb.DMatrix(data = as.matrix(testm), label = test_label)
############################################################
# 2. projecting data
############################################################
previous_na_action <- options('na.action')
options(na.action='na.pass')
projectm <- sparse.model.matrix(TARGET~.-1, data = data_project)
options(na.action=previous_na_action$na.action)
#--------------------Advanced features ---------------------------
# To use advanced features, we need to put data in lgb.Dataset
dtrain <- lgb.Dataset(data = trainm, label = train_label, free_raw_data = FALSE)
dtest <- lgb.Dataset(data = testm, label = test_label, free_raw_data = FALSE)
dcomplete <- lgb.Dataset(data = completem, label = complete_label, free_raw_data = FALSE)
#--------------------Using validation set-------------------------
# valids is a list of lgb.Dataset, each of them is tagged with name
valids <- list(train = dtrain, test = dtest)
############################################################
# parameter setup - full parameter as below
############################################################
N <- 1400
metrics = 'auc'

bst <- lgb.train(data = dtrain,
                valids = valids,
                learning_rate = 0.02,
                num_leaves = 20,                
                colsample_bytree=.95,
                subsample=.9,
                max_depth=8,
                boosting_type = 'goss',
                reg_alpha=0.05,
                reg_lambda=0.07,
                min_split_gain=0.01,
                nrounds = N,
                objective = "binary",
                metric = metrics
                # ,init_model = bst
                )

auc_train_df <- as.data.frame(as.matrix(bst$record_evals[2]$train$auc$eval)) %>%
                  select(TRAIN_AUC=V1)
auc_val_df <- as.data.frame(as.matrix(bst$record_evals[3]$test$auc$eval)) %>%
                select(VAL_AUC=V1)

auc_df<- cbind(auc_train_df, auc_val_df)

# choosing min train error and max validation errors as plot y limits
plot(x=(1:N), auc_train_df$TRAIN_AUC, type = 'l', col = "red"
            , ylim=c(min(as.data.frame(auc_df$VAL_AUC))
                   , max(as.data.frame(auc_df$TRAIN_AUC))))
lines(x=(1:N), auc_df$VAL_AUC, type = 'l', col = "blue")
axis(side=1, at=(1:N)) # label on x-axis with integer values

# returns optimal number of iteration
(max_val_auc <- max(as.data.frame(auc_df$VAL_AUC)))
(iteration <- which(as.list(auc_df$VAL_AUC) == max_val_auc))

############################################################
# applying model
############################################################
LGBM7_2 <- lightgbm(data = dcomplete,
                    learning_rate = 0.02,
                    num_leaves = 20,                
                    colsample_bytree=.95,
                    subsample=.9,
                    max_depth=8,
                    boosting_type = 'goss',
                    reg_alpha=0.05,
                    reg_lambda=0.07,
                    min_split_gain=0.01,
                    nrounds = N,
                    objective = "binary",
                    metric = metrics
                )

# records error at final step
AUC_LGBM7_2 <- as.data.frame(as.matrix(LGBM7_2$record_evals[2]$train$auc$eval))
# prediction
pred <- predict(LGBM7_2, projectm)
output_LGBM_7_2 <- cbind(data_project$SK_ID_CURR,pred)

write.csv(as.list(AUC_LGBM7_2), "AUC_LGBM7_2.csv")

options(scipen=999)
write.csv(output_LGBM_7_2,"output_7_2.csv")
