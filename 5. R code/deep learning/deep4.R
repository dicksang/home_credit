setwd("C:\\Users\\Dick Sang\\Desktop\\Data Analytics\\Kaggle\\Competition\\1. Home Credit Default Risk\\R code")
# rm(list=ls())

# Packages
library(xgboost)
library(magrittr)
library(dplyr)
library(Matrix)
library(keras)
library(onehot)

# Data: sum(is.na(data0))
# choosing variables from XGBoosting - 99% of variables chosen (201 columns)
data0 <- read.csv("train_test_final.csv") %>% 
         select(source,
                TARGET,
                EXT_SOURCE_2,
                EXT_SOURCE_3,
                EXT_SOURCE_1,
                LTV,
                DAYS_BIRTH,
                AVG_INSTALMENT_AMT_DIFF,
                CODE_GENDER,
                AMT_ANNUITY,
                AMT_GOODS_PRICE,
                Cash_MAX_DAYS_LD_1ST_VER,
                DAYS_EMPLOYED,
                avg_DPD_tolerance,
                NAME_EDUCATION_TYPE,
                Cash_AVG_CNT_PAYMENT,
                Active_MIN_DAYS_CREDIT,
                Consum_SUM_AMT_ANNUITY,
                Cash_Refused_credit,
                Closed_MAX_AMT_CREDIT_SUM,
                DAYS_ID_PUBLISH,
                max_home_cred_month,
                Consum_SUM_AMT_DOWN_PAYMENT,
                FLAG_OWN_CAR,
                AMT_CREDIT,
                Consum_MAX_DAYS_LD_1ST_VER,
                NAME_INCOME_TYPE,
                Rev_MIN_DAYS_FIRST_DRAWING,
                Active_bureau_count,
                Closed_SUM_AMT_CREDIT_SUM,
                Cash_high_int_group,
                Consum_MAX_AMT_ANNUITY,
                Rev_MAX_DAYS_FIRST_DRAWING,
                REGION_RATING_CLIENT_W_CITY,
                Active_MIN_DAYS_CREDIT_ENDDATE,
                NAME_FAMILY_STATUS,
                FLAG_DOCUMENT_3,
                Active_MAX_AMT_CREDIT_MAX_OVERDU,
                INCOME_TO_LOAN,
                Cash_low_int_group,
                Active_MAX_AMT_CREDIT_SUM_OVERDU,
                Cash_REPEATER_APPROVAL_PCT,
                Closed_AVG_AMT_CREDIT_SUM,
                DAYS_LAST_PHONE_CHANGE,
                Active_MIN_AMT_CREDIT_SUM,
                DEF_30_CNT_SOCIAL_CIRCLE,
                Active_AVG_AMT_CREDIT_SUM_DEBT,
                home_cred_comp,
                Consum_REPEATER_APPROVAL_PCT,
                Consum_Refused_credit,
                Active_SUM_AMT_CREDIT_SUM_DEBT,
                Active_AVG_DAYS_CREDIT_ENDDATT,
                Consum_MAX_RATE_DOWN_PAYMENT,
                Active_MAX_AMT_CREDIT_SUM,
                Active_MIN_AMT_CREDIT_SUM_DEBT,
                AVG_INSTALMENT_DELAY,
                Consum_MAX_AMT_DOWN_PAYMENT,
                Active_AVG_DAYS_CREDIT,
                DAYS_REGISTRATION,
                Rev_MIN_DAYS_LAST_DUE,
                FLAG_WORK_PHONE,
                Closed_MIN_DAYS_CREDIT_ENDDATE,
                Consum_MAX_AMT_APPL,
                Cash_MIN_DAYS_FIRST_DUE,
                Active_AVG_AMT_CREDIT_SUM,
                NUM_INSTALMENT_VERSION_CNT,
                DEF_60_CNT_SOCIAL_CIRCLE,
                Active_SUM_AMT_CREDIT_SUM,
                Consum_SUM_DAYS_DECISION,
                Consum_MIN_DAYS_TERMINATION,
                Rev_MAX_DAYS_LAST_DUE,
                avg_home_cred_insta,
                OWN_CAR_AGE,
                Consum_AVG_AMT_ANNUITY,
                Rev_Refused_credit,
                Consum_NEW_LOAN_APPROVAL_Y,
                MAX_INSTALMENT_DELAY,
                Consum_MAX_DAYS_DECISION,
                Consum_SUM_AMT_APPL,
                Active_AVG_AMT_CREDIT_SUM_LIMIT,
                Active_AVG_AMT_CREDIT_MAX_OVERDU,
                Consum_MIN_DAYS_FIRST_DUE,
                Rev_AVG_AMT_APPL,
                Closed_MIN_DAYS_CREDIT,
                Cash_AVG_SELLERPLACE_AREA,
                Cash_MAX_DAYS_TERMINATION,
                REGION_POPULATION_RELATIVE,
                Closed_MAX_DAYS_CREDIT_ENDDATT,
                Consum_AVG_DAYS_DECISION,
                Closed_MAX_DAYS_CREDIT,
                FLOORSMAX_MEDI,
                Cash_AVG_AMT_ANNUITY,
                max_DPD_tolerance,
                Consum_MAX_DAYS_FIRST_DUE,
                Cash_AVG_DAYS_DECISION,
                case_0_pct,
                Active_MAX_AMT_CREDIT_SUM_LIMIT,
                Consum_AVG_AMT_APPL,
                WALLSMATERIAL_MODE,
                Consum_AVG_CNT_PAYMENT,
                OCCUPATION_TYPE,
                TOTALAREA_MODE,
                ORGANIZATION_TYPE,
                Closed_AVG_DAYS_CREDIT_ENDDATT,
                Active_AVG_AMT_CREDIT_SUM_OVERDU,
                REG_CITY_NOT_LIVE_CITY,
                Closed_AVG_DAYS_CREDIT,
                Consum_AVG_RATE_DOWN_PAYMENT,
                AMT_REQ_CREDIT_BUREAU_QRT,
                Cash_sum_CNT_PAYMENT,
                Consum_AVG_AMT_GOODS_PRICE,
                Active_MAX_DAYS_CREDIT,
                Active_MAX_DAYS_CREDIT_ENDDATT,
                Consum_AVG_HOUR_APPR_PROCESS_STA,
                Consum_MIN_DAYS_LAST_DUE,
                Cash_WALK_IN_Y,
                Active_MAX_AMT_CREDIT_SUM_DEBT,
                Rev_AVG_AMT_GOODS_PRICE,
                YEARS_BEGINEXPLUATATION_AVG,
                Consum_AVG_SELLERPLACE_AREA,
                Cash_MAX_DAYS_LAST_DUE,
                APARTMENTS_AVG,
                Closed_AVG_AMT_CREDIT_MAX_OVERDU,
                NAME_CONTRACT_TYPE,
                SK_ID_CURR,
                Rev_MAX_DAYS_FIRST_DUE,
                Consum_AVG_AMT_DOWN_PAYMENT,
                Cash_MAX_DAYS_DECISION,
                Consum_sum_CNT_PAYMENT,
                YEARS_BEGINEXPLUATATION_MODE,
                Cash_MAX_DAYS_FIRST_DUE,
                Rev_MIN_DAYS_FIRST_DUE,
                Cash_SUM_DAYS_DECISION,
                Active_MIN_AMT_CREDIT_SUM_LIMIT,
                Consum_MAX_AMT_CREDIT,
                Consum_Approved_credit,
                FLAG_DOCUMENT_18,
                Consum_high_int_group,
                LANDAREA_AVG,
                Rev_SUM_AMT_APPL,
                BASEMENTAREA_AVG,
                case_1_2_pct,
                Cash_MAX_CNT_PAYMENT,
                home_cred_act_pct,
                home_cred_DPD_cnt,
                Consum_MAX_DAYS_LAST_DUE,
                LIVINGAREA_MODE,
                max_home_cred_insta,
                Cash_SUM_AMT_ANNUITY,
                Cash_AVG_HOUR_APPR_PROCESS_START,
                LIVINGAREA_AVG,
                Cash_Accomp_Flag_N_pct,
                Cash_SUM_AMT_APPL,
                Cash_CODE_REJECT_REASON_cnt,
                Consum_MAX_DAYS_TERMINATION,
                Cash_AVG_AMT_APPL,
                Cash_MIN_DAYS_LAST_DUE,
                Consum_product_mobile,
                Rev_MAX_DAYS_DECISION,
                LIVINGAREA_MEDI,
                LANDAREA_MODE,
                COMMONAREA_MODE,
                Rev_SUM_AMT_ANNUITY,
                Closed_MIN_AMT_CREDIT_SUM,
                Closed_AVG_AMT_CREDIT_SUM_DEBT,
                AMT_INCOME_TOTAL,
                Rev_AVG_DAYS_DECISION,
                Cash_MAX_AMT_APPL,
                Cash_CROSS_SELL_Y,
                ENTRANCES_AVG,
                Consum_REFRESHER_APPROVAL_PCT,
                Rev_Accomp_Flag_N_pct,
                Cash_Accomp_Flag_Y_pct,
                avg_DPD_net,
                Cash_insured_pct,
                Consum_product_household,
                LIVINGAPARTMENTS_MODE,
                Consum_MAX_CNT_PAYMENT,
                Cash_APP_ON_TUESDAY,
                HOUR_APPR_PROCESS_START,
                max_DPD_net,
                LANDAREA_MEDI,
                Cash_MAX_AMT_ANNUITY,
                Rev_MAX_AMT_APPL,
                Cash_MAX_AMT_CREDIT,
                Consum_SUM_AMT_CREDIT,
                APARTMENTS_MODE,
                NONLIVINGAPARTMENTS_AVG,
                Consum_Accompanied_Flag_Other_pc,
                mean_CREDIT_CARD_UTIL,
                std_CREDIT_CARD_UTIL,
                mean_CREDIT_CARD_PAYMENT,
                std_CREDIT_CARD_PAYMENT,
                mean_CC_Paid_less_than_mp,
                mean_CC_CNT_DRAWINGS_CURRENT,
                mean_CC_DPD_MONTHS_SUM)

data0_2 <- data0[, sapply(data0, function(col) length(unique(col))) > 1] %>%
           select(-source)
# sapply(data0_2, function(col) length(unique(col))) # check

# data <- train data: note - never use any quantity computed on the test data (data leakage?)
data_train_test <- data0_2[data0_2$TARGET %in% c("0","1"),] %>% select(-TARGET)
train_test_label <- data0_2[data0_2$TARGET %in% c("0","1"),] %>% select(TARGET) %>% t %>% as.vector()

data_project <- data0_2[!data0_2$TARGET %in% c("0","1"),] %>% select(-TARGET)
# project: to be labelled
# project_label <- data0_2[!data0_2$TARGET %in% c("0","1"),] %>% select(TARGET) %>% as.vector()
############################################################
# Create matrix - One-Hot Encoding for Factor variables
# standardize the train, test and project data
############################################################
# standardize the train, test data
ind <- sapply(data_train_test, is.numeric)
data_train_test2 <- data_train_test
data_train_test2[ind] <- lapply(data_train_test2[ind], scale)
# TRAIN_TEST: encode data using onehot encoding
encoder_train_test2 <- onehot(data_train_test2, max_levels = 60)
data_train_test3 <- predict(encoder_train_test2, data_train_test2) %>% as.matrix()

# standardize the projection data
ind <- sapply(data_project, is.numeric)
data_project2 <- data_project
data_project2[ind] <- lapply(data_project2[ind], scale)
# TRAIN_TEST: encode data using onehot encoding
encoder_project2 <- onehot(data_project2, max_levels = 60)
data_project3 <- predict(encoder_project2, data_project2) %>% as.matrix()
############################################################
# Because we will need to instantiate the same model multiple times,
# we use a function to construct it.
############################################################
# 3 layers
# can reduce dimension using Information Value

build_model <- function() {
  # model 2_2 check: structure: (250, 250)
  # model <- keras_model_sequential() %>%
  #   layer_dense(input_shape = dim(data_train_test3)[[2]], units = 250, activation = "relu"
  #               , kernel_regularizer = regularizer_l1(0.001)) %>%
  #   layer_dense(units = 250, activation = "relu"
  #               , kernel_regularizer = regularizer_l1(0.001)) %>%
  #   layer_dense(units = 1, activation="sigmoid")

  # model 2_3 check: structure: (250, 200, 200) [L1/ L2]
  # model <- keras_model_sequential() %>%
  #   layer_dense(input_shape = dim(data_train_test3)[[2]], units = 250, activation = "relu",
  #               kernel_regularizer = regularizer_l2(0.001)) %>%
  #   layer_dense(units = 200, activation = "relu", 
  #               kernel_regularizer = regularizer_l2(0.001)) %>%
  #   layer_dense(units = 200, activation = "relu", 
  #               kernel_regularizer = regularizer_l2(0.001)) %>%
  #   layer_dense(units = 1, activation="sigmoid")

  # model 2_4 check: structure: (250, 200, 200, 150) [L1/ L2]
  model <- keras_model_sequential() %>%
    layer_dense(input_shape = dim(data_train_test3)[[2]], units = 250, activation = "relu",
                kernel_regularizer = regularizer_l2(0.001)) %>%
    layer_dense(units = 200, activation = "relu",
                kernel_regularizer = regularizer_l2(0.001)) %>%
    layer_dense(units = 200, activation = "relu",
                kernel_regularizer = regularizer_l2(0.001)) %>%
    layer_dense(units = 150, activation = "relu",
                kernel_regularizer = regularizer_l2(0.001)) %>%
    layer_dense(units = 1, activation="sigmoid")
  
  model %>% compile(
    # optimizer = "rmsprop", 
    optimizer = optimizer_rmsprop(lr = 0.001), # default learning rate = 0.001
    loss = "binary_crossentropy",
    metrics = c("accuracy")
  )  
}
############################################################
# try more CV later
# CV - fold = k = 2
############################################################
k <- 5
indices <- sample(1:nrow(data_train_test3))
folds <- cut(indices, breaks = k, labels = FALSE)
num_epochs <- 12
train_accuracy <- c()
validation_accuracy <- c()

for (i in 1:k) {
  cat("processing fold #", i, "\n")
  # Prepare the validation data: data from partition # k
  val_indices <- which(folds == i, arr.ind = TRUE)
  val_data <- data_train_test3[val_indices,]
  val_targets <- train_test_label[val_indices]
  
  # Prepare the training data: data from all other partitions
  partial_train_data <- data_train_test3[-val_indices,]
  partial_train_targets <- train_test_label[-val_indices]
  
  # Build the Keras model (already compiled)
  model <- build_model()
  
  # Train the model (in silent mode, verbose=0)
  # batch size cannot be too large -> loss = NaN
  # batch size is the number of samples fed into the network each time
  history <- model %>% fit(partial_train_data,
                partial_train_targets,
                epochs = num_epochs,
                batch_size = 100, 
                class_weight = list("0" = 1,"1" = 10),
                validation_data = list(val_data, val_targets),
                verbose = 1)
  
  train_accuracy <- c(train_accuracy, history$metrics$acc)
  validation_accuracy <- c(validation_accuracy, history$metrics$val_acc)
}  

#-----
# model performance
(mean(train_accuracy))
(mean(validation_accuracy))
############################################################
# Train the model using all data
############################################################
# Build the Keras model (already compiled)
model <- build_model()

# Train the model (in silent mode, verbose=0)
# batch size cannot be too large -> loss = NaN
# batch size is the number of samples fed into the network each time
history <- model %>% fit(data_train_test3,
                         train_test_label,
                         # epochs = num_epochs,
                         epochs = 1,
                         batch_size = 100,
                         class_weight = list("0" = 1,"1" = 10),
                         verbose = 1)

setwd("C:\\Users\\Dick Sang\\Desktop\\Data Analytics\\Kaggle\\Competition\\1. Home Credit Default Risk\\R code\\deep learning")
save_model_hdf5(model, filepath = "model2_4_L2.h5")
############################################################
# Provide prediction
############################################################
# model <- load_model_hdf5("model2_4_L2.h5")

pred <- model %>% predict(data_project3) %>%
        as.data.frame()

# disabling scientific notation
options(scipen = 999)
output <- as.data.frame(cbind(data_project %>% select(SK_ID_CURR), pred)) %>%
          rename(TARGET=V1) %>%
          mutate(SK_ID_CURR=as.numeric(SK_ID_CURR))

setwd("C:\\Users\\Dick Sang\\Desktop\\Data Analytics\\Kaggle\\Competition\\1. Home Credit Default Risk\\R code\\deep learning")
write.csv(output, "deep_2_4_L2.csv", row.names=FALSE)
