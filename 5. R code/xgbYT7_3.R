setwd("C:\\Users\\Dick Sang\\Desktop\\Data Analytics\\Kaggle\\Competition\\1. Home Credit Default Risk\\R code")
rm(list=ls())

# Packages
library(xgboost)
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
# training data
############################################################
# Create matrix - One-Hot Encoding for Factor variables
# avoid missing lines by the settings
previous_na_action <- options('na.action')
options(na.action='na.pass')
trainm <- sparse.model.matrix(TARGET ~ .-1, data = train)
options(na.action=previous_na_action$na.action)
head(trainm)

train_label <- train[,"TARGET"]
train_matrix <- xgb.DMatrix(data = as.matrix(trainm), label = train_label)

############################################################
# testing data
############################################################
previous_na_action <- options('na.action')
options(na.action='na.pass')
testm <- sparse.model.matrix(TARGET~.-1, data = test)
options(na.action=previous_na_action$na.action)

test_label <- test[,"TARGET"]
test_matrix <- xgb.DMatrix(data = as.matrix(testm), label = test_label)

############################################################
# projecting data
############################################################
previous_na_action <- options('na.action')
options(na.action='na.pass')
projectm <- sparse.model.matrix(TARGET~.-1, data = data_project)
options(na.action=previous_na_action$na.action)
# project_matrix <- xgb.DMatrix(data = as.matrix(projectm), label = data_project)

# Parameters
nc <- length(unique(train_label))
xgb_params <- list("objective" = "multi:softprob",
                   "eval_metric" = "mlogloss", # area under curve (mlogloss, merror)
                   "num_class" = as.integer(nc))
watchlist <- list(train = train_matrix, test = test_matrix)


load(file = "Model7_1.RData")
# eXtreme Gradient Boosting Model
bst_model7_3 <- xgb.train(params = xgb_params,
                       data = train_matrix,
                       nrounds = 200,
                       watchlist = watchlist,
                       eta = 0.2,
                       max.depth = 17,
                       gamma = 20,
                       subsample = 0.8,
                       colsample_bytree = 1,
                       xgb_model = bst_model7_1,
                       missing = NA,
                       seed = 333)

save(bst_model7_3, file = "Model7_3.RData")
# load(file = "Model.RData")

# Training & test error plot
e <- data.frame(bst_model7_3$evaluation_log)
plot(e$iter, e$train_mlogloss, col = 'blue')
par(new=TRUE)
lines(e$iter, e$test_mlogloss)
par(new=FALSE)

min(e$test_mlogloss)
e[e$test_mlogloss == 0.242364,]

# Feature importance
imp <- xgb.importance(colnames(train_matrix), model = bst_model7_3)
print(imp)
xgb.plot.importance(imp)

# probability estimates for each category
p <- predict(bst_model7_3, newdata = projectm)

# Prediction & confusion matrix for each category
pred <- matrix(p, nrow = nc, ncol = length(p)/nc) %>%
  t() %>%
  data.frame() %>%
  dplyr::mutate(prob=X2)

data_proj_pred <- cbind(data_project$SK_ID_CURR,as.data.frame(pred))

write.csv(data_proj_pred,"output_7_3.csv")
