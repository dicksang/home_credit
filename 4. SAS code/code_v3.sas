libname homedata 'C:\Users\wyc_s\Desktop\Home Credit';
/*******************************************************************/
* Data import: Start ;
/*******************************************************************/

PROC IMPORT OUT= HOMEDATA.train
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\application_train.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.test
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\application_test.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.bureau
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\bureau.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.bureau_balance
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\bureau_balance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.credit_card_balance
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\credit_card_balance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.installments_payments
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\installments_payments.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.POS_CASH_balance
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\POS_CASH_balance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

PROC IMPORT OUT= HOMEDATA.previous_application
            DATAFILE= "C:\Users\wyc_s\Desktop\Home Credit\previous_application.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     /*GUESSINGROWS=MAX;*/
RUN;

/*******************************************************************/
* Data import: End ;
/*******************************************************************/

/*******************************************************************/
* Data exploration: Start ;
/*******************************************************************/
proc freq data = HOMEDATA.train;
tables OCCUPATION_TYPE;
run;
/*******************************************************************/
* Data exploration: End ;
/*******************************************************************/

/*******************************************************************/
* 0. Merging training and testing data together: Start;
/*******************************************************************/
* Choose one of the below the run;
/*******************************************************************/
*----- a: dataset without imputations;
Data homedata.train_test0;
set Homedata.train(in=a) Homedata.test(in=b);
if a then
source = ．TRAIN・;
else
source = ．TEST・;
run;
/*******************************************************************/
*----- b: dataset with imputations;
Data homedata.train_test0;
set Homedata.train(in=a) Homedata.test(in=b);
if a then
        source = 'TRAIN';
else
        source = 'TEST';

if AMT_ANNUITY = . then
AMT_ANNUITY = AMT_CREDIT * 0.055; *average rate to AMT credit;
Else
AMT_ANNUITY = coalesce(AMT_ANNUITY,0);

AMT_GOODS_PRICE = coalesce(AMT_GOODS_PRICE,0);
OWN_CAR_AGE = coalesce(OWN_CAR_AGE,0);
CNT_FAM_MEMBERS = coalesce(CNT_FAM_MEMBERS,0);
DAYS_LAST_PHONE_CHANGE = coalesce(DAYS_LAST_PHONE_CHANGE,0);
OBS_30_CNT_SOCIAL_CIRCLE = coalesce(OBS_30_CNT_SOCIAL_CIRCLE,0);
DEF_30_CNT_SOCIAL_CIRCLE = coalesce(DEF_30_CNT_SOCIAL_CIRCLE,0);
OBS_60_CNT_SOCIAL_CIRCLE = coalesce(OBS_60_CNT_SOCIAL_CIRCLE,0);
DEF_60_CNT_SOCIAL_CIRCLE = coalesce(DEF_60_CNT_SOCIAL_CIRCLE,0);

AMT_REQ_CREDIT_BUREAU_HOUR = coalesce(AMT_REQ_CREDIT_BUREAU_HOUR,0);
AMT_REQ_CREDIT_BUREAU_DAY = coalesce(AMT_REQ_CREDIT_BUREAU_DAY,0);
AMT_REQ_CREDIT_BUREAU_WEEK = coalesce(AMT_REQ_CREDIT_BUREAU_WEEK,0);
AMT_REQ_CREDIT_BUREAU_MON = coalesce(AMT_REQ_CREDIT_BUREAU_MON,0);
AMT_REQ_CREDIT_BUREAU_QRT = coalesce(AMT_REQ_CREDIT_BUREAU_QRT,0);
AMT_REQ_CREDIT_BUREAU_YEAR = coalesce(AMT_REQ_CREDIT_BUREAU_YEAR,0);
LTV = AMT_CREDIT/ AMT_GOODS_PRICE;
INCOME_TO_LOAN = AMT_INCOME_TOTAL/ AMT_CREDIT;
*UTILIZATION = / AMT_CREDIT;
run;

proc stdize data = Homedata.train_test0 out=Homedata.train_test missing = mean
reponly;
var APARTMENTS_AVG -- NONLIVINGAREA_AVG LTV INCOME_TO_LOAN;
run;

proc stdize data = Homedata.train_test out=Homedata.train_test missing = median
reponly;
var APARTMENTS_MODE -- NONLIVINGAREA_MEDI TOTALAREA_MODE EXT_SOURCE_1 -- EXT_SOURCE_3;
run;

* check missing in dataset;
Proc means data = Homedata.train_test N NMISS MEAN STD MAX MIN;
Run;

Proc freq data = Homedata.train_test NLEVELS;
Tables _ALL_ / noprint; * noprint to suppress printing for all variable details;
Run;

/*******************************************************************/
* 1. Bureau data: Start;
/*******************************************************************/
proc sql;
        Create table Homedata.Bureau2 as
        select SK_ID_CURR, CREDIT_ACTIVE, Count(*) as bureau_count,
               min(abs(DAYS_CREDIT)) as MIN_DAYS_CREDIT, max(abs(DAYS_CREDIT)) as MAX_DAYS_CREDIT,
               avg(abs(DAYS_CREDIT)) as AVG_DAYS_CREDIT,
               sum(case when CREDIT_DAY_OVERDUE > 0 then 1 else 0 end) as CREDIT_DAY_OVERDUE_COUNTER,
               min(abs(DAYS_CREDIT_ENDDATE)) as MIN_DAYS_CREDIT_ENDDATE,
               max(abs(DAYS_CREDIT_ENDDATE)) as MAX_DAYS_CREDIT_ENDDATT,
               avg(abs(DAYS_CREDIT_ENDDATE)) as AVG_DAYS_CREDIT_ENDDATT,
               min(AMT_CREDIT_MAX_OVERDUE) as MIN_AMT_CREDIT_MAX_OVERDUE,
               max(AMT_CREDIT_MAX_OVERDUE) as MAX_AMT_CREDIT_MAX_OVERDUE,
               avg(AMT_CREDIT_MAX_OVERDUE) as AVG_AMT_CREDIT_MAX_OVERDUE,
               min(CNT_CREDIT_PROLONG) as MIN_CNT_CREDIT_PROLONG,
               max(CNT_CREDIT_PROLONG) as MAX_CNT_CREDIT_PROLONG,
               avg(CNT_CREDIT_PROLONG) as AVG_CNT_CREDIT_PROLONG,
               min(AMT_CREDIT_SUM) as MIN_AMT_CREDIT_SUM,
               max(AMT_CREDIT_SUM) as MAX_AMT_CREDIT_SUM,
               avg(AMT_CREDIT_SUM) as AVG_AMT_CREDIT_SUM,
               sum(AMT_CREDIT_SUM) as SUM_AMT_CREDIT_SUM,
               min(AMT_CREDIT_SUM_DEBT) as MIN_AMT_CREDIT_SUM_DEBT,
               max(AMT_CREDIT_SUM_DEBT) as MAX_AMT_CREDIT_SUM_DEBT,
               avg(AMT_CREDIT_SUM_DEBT) as AVG_AMT_CREDIT_SUM_DEBT,
               sum(AMT_CREDIT_SUM_DEBT) as SUM_AMT_CREDIT_SUM_DEBT,
               min(AMT_CREDIT_SUM_LIMIT) as MIN_AMT_CREDIT_SUM_LIMIT,
               max(AMT_CREDIT_SUM_LIMIT) as MAX_AMT_CREDIT_SUM_LIMIT,
               avg(AMT_CREDIT_SUM_LIMIT) as AVG_AMT_CREDIT_SUM_LIMIT,
               min(AMT_CREDIT_SUM_OVERDUE) as MIN_AMT_CREDIT_SUM_OVERDUE,
               max(AMT_CREDIT_SUM_OVERDUE) as MAX_AMT_CREDIT_SUM_OVERDUE,
               avg(AMT_CREDIT_SUM_OVERDUE) as AVG_AMT_CREDIT_SUM_OVERDUE,
               count(distinct(CREDIT_TYPE)) as CREDIT_TYPES
        from HOMEDATA.BUREAU
        group by SK_ID_CURR, CREDIT_ACTIVE;
quit;

* preparing the column header by putting them on rows;
proc transpose data = HOMEDATA.BUREAU2 out = HOMEDATA.BUREAU3;
by SK_ID_CURR CREDIT_ACTIVE;
where CREDIT_ACTIVE not in ('Sold','Bad de');
run;

/* SAS 9.1 does not support the syntax for id and delimiter, work around is to make a field manually */
data HOMEDATA.BUREAU3_2;
set HOMEDATA.BUREAU3;
header = catx("_",CREDIT_ACTIVE,_NAME_);
run;

proc transpose data = HOMEDATA.BUREAU3_2 out = HOMEDATA.BUREAU4 (drop = _NAME_);
by SK_ID_CURR;
id header;
var COL1;
run;

/* only build the flag for sold and bad debt status*/
data HOMEDATA.BUREAU_Sold (keep = SK_ID_CURR Sold) HOMEDATA.BUREAU_BD (keep = SK_ID_CURR Bad_debt);
set HOMEDATA.BUREAU2;
if CREDIT_ACTIVE = 'Sold' then
do;
        Sold = 1;
        output HOMEDATA.BUREAU_Sold;
end;
if CREDIT_ACTIVE = 'Bad de' then
do;
        Bad_debt = 1;
        output HOMEDATA.BUREAU_BD;
end;
run;

proc sort data = HOMEDATA.BUREAU4;
by SK_ID_CURR;
run;

proc sort data = HOMEDATA.BUREAU_SOLD;
by SK_ID_CURR;
run;

proc sort data = HOMEDATA.BUREAU_BD;
by SK_ID_CURR;
run;

data HOMEDATA.BUREAU5;
merge HOMEDATA.BUREAU4(in=a)
      HOMEDATA.BUREAU_SOLD(in=b)
      HOMEDATA.BUREAU_BD(in=c);
by SK_ID_CURR;
if a;
run;

proc sort data = HOMEDATA.train_test;
by SK_ID_CURR;
run;

data HOMEDATA.train_test2;
merge HOMEDATA.train_test(in=a)
      HOMEDATA.BUREAU5(in=b);
by SK_ID_CURR;
if a;

array list_var Active_bureau_count -- bad_debt;

do over list_var;
        list_var = coalesce(list_var,0);
end;

run;

* check missing in dataset;
Proc means data = Homedata.train_test2 N NMISS MEAN STD MAX MIN;
Run;

Proc freq data = Homedata.train_test2 NLEVELS;
Tables _ALL_ / noprint; * noprint to suppress printing for all variable details;
Run;

/*******************************************************************/
* 1. Bureau data: End;
/*******************************************************************/

/*******************************************************************/
* 2. BUREAU BALANCE data: Start ;
/*******************************************************************/

/* calculate counts of no PD vs PD less than 60 days and longer: credit history */

proc sql;
     Create table HOMEDATA.LOAN_ID_MAS as
            select distinct SK_ID_CURR, SK_ID_BUREAU
            from HOMEDATA.BUREAU
            order by SK_ID_BUREAU;

     Create table HOMEDATA.BUREAU_BALANCE2 as
            select SK_ID_BUREAU,
                   sum(case when STATUS in ('0','1','2','3','4','5') then 1 else 0 end) as total_cases,
                   sum(case when STATUS in ('0') then 1 else 0 end) as case_0,
                   sum(case when STATUS in ('1','2') then 1 else 0 end) as case_1_2,
                   sum(case when STATUS in ('3','4','5') then 1 else 0 end) as case_3_4_5
           from HOMEDATA.BUREAU_BALANCE
           group by SK_ID_BUREAU
           order by SK_ID_BUREAU;
quit;

data HOMEDATA.LOAN_ID_MAS2;
merge HOMEDATA.LOAN_ID_MAS(in = a) HOMEDATA.BUREAU_BALANCE2(in = b);
by SK_ID_BUREAU;
if a;
run;

proc summary data = HOMEDATA.LOAN_ID_MAS2;
class SK_ID_CURR;
var total_cases case_0 case_1_2 case_3_4_5;
output out = HOMEDATA.LOAN_ID_MAS3 sum()=;
run;

data HOMEDATA.LOAN_ID_MAS4 (keep=SK_ID_CURR case_0_pct case_1_2_pct case_3_4_5_pct);
set HOMEDATA.LOAN_ID_MAS3;
case_0_pct = case_0/ total_cases;
case_1_2_pct = case_1_2/ total_cases;
case_3_4_5_pct = case_3_4_5/ total_cases;
where SK_ID_CURR <>. ;
run;

proc sort data = HOMEDATA.LOAN_ID_MAS4;
by SK_ID_CURR;
run;

data HOMEDATA.Train_test3;
merge HOMEDATA.Train_test2(in=a) HOMEDATA.LOAN_ID_MAS4(in=b);
by SK_ID_CURR;
if a;
case_0_pct = coalesce(case_0_pct,0);
case_1_2_pct = coalesce(case_1_2_pct,0);
case_3_4_5_pct = coalesce(case_3_4_5_pct,0);
run;

* preview missing data;
proc means data = HOMEDATA.train_test3 N NMISS MEAN STD MAX MIN;
run;
/*******************************************************************/
* 2. BUREAU BALANCE data: End ;
/*******************************************************************/
/*******************************************************************/
* 3. Previous Application data: Start ;
/*******************************************************************/
data Homedata.Previous_application1;
        set Homedata.Previous_application;
        if DAYS_LAST_DUE = 365243 then DAYS_LAST_DUE = 0;
        if DAYS_TERMINATION = 365243 then DAYS_LAST_DUE = 0;
        if DAYS_FIRST_DRAWING = 365243 then DAYS_LAST_DUE = 0;
        if DAYS_FIRST_DUE = 365243 then DAYS_LAST_DUE = 0;
        if DAYS_LAST_DUE_1ST_VERSION = 365243 then DAYS_LAST_DUE = 0;
run;

proc sql;
     Create table Homedata.Previous_application2 as
            select SK_ID_CURR
                , case when NAME_CONTRACT_TYPE = 'Cash loans' then 'Cash'
                       when NAME_CONTRACT_TYPE = 'Consumer loans' then 'Consum'
                       when NAME_CONTRACT_TYPE = 'Revolving loans' then 'Rev'
                  end as NAME_CONTRACT_TYPE
                , count(SK_ID_PREV) as previous_application_number
                , sum(AMT_ANNUITY) as SUM_AMT_ANNUITY
                , max(AMT_ANNUITY) as MAX_AMT_ANNUITY, AVG(AMT_ANNUITY) as AVG_AMT_ANNUITY
                , sum(AMT_APPLICATION) as SUM_AMT_APPL
                , max(AMT_APPLICATION) as MAX_AMT_APPL, AVG(AMT_APPLICATION) as AVG_AMT_APPL
                , sum(AMT_CREDIT) as SUM_AMT_CREDIT
                , max(AMT_CREDIT) as MAX_AMT_CREDIT, AVG(AMT_CREDIT) as AVG_AMT_CREDIT
                , sum(AMT_DOWN_PAYMENT) as SUM_AMT_DOWN_PAYMENT
                , max(AMT_DOWN_PAYMENT) as MAX_AMT_DOWN_PAYMENT
                , AVG(AMT_DOWN_PAYMENT) as AVG_AMT_DOWN_PAYMENT
                , sum(AMT_GOODS_PRICE) as SUM_AMT_GOODS_PRICE
                , max(AMT_GOODS_PRICE) as MAX_AMT_GOODS_PRICE
                , AVG(AMT_GOODS_PRICE) as AVG_AMT_GOODS_PRICE
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'MONDAY' then 1 else 0 end) as APP_ON_MONDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'TUESDAY' then 1 else 0 end) as APP_ON_TUESDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'WEDNESDA' then 1 else 0 end) as APP_ON_WEDNESDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'THURSDAY' then 1 else 0 end) as APP_ON_THURSDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'FRIDAY' then 1 else 0 end) as APP_ON_FRIDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'SATURDAY' then 1 else 0 end) as APP_ON_SATURDAY
                , sum(case when WEEKDAY_APPR_PROCESS_START = 'SUNDAY' then 1 else 0 end) as APP_ON_SUNDAY /* NOTE: dummy variable trap*/
                , AVG(HOUR_APPR_PROCESS_START) as AVG_HOUR_APPR_PROCESS_START
                , max(RATE_DOWN_PAYMENT) as MAX_RATE_DOWN_PAYMENT
                , AVG(RATE_DOWN_PAYMENT) as AVG_RATE_DOWN_PAYMENT
                , max(RATE_INTEREST_PRIMARY) as MAX_RATE_INT_PRI
                , AVG(RATE_INTEREST_PRIMARY) as AVG_RATE_INT_PRI
                , max(RATE_INTEREST_PRIVILEGED) as MAX_RATE_INT_PRIVIL
                , AVG(RATE_INTEREST_PRIVILEGED) as AVG_RATE_INT_PRIVIL
                , count(distinct(NAME_CASH_LOAN_PURPOSE)) as loan_purposes
                , sum(case when NAME_CONTRACT_STATUS = 'Approved' then 1 else 0 end) as Approved_credit
                , sum(case when NAME_CONTRACT_STATUS = 'Canceled' then 1 else 0 end) as Cancelled_credit
                , sum(case when NAME_CONTRACT_STATUS = 'Refused' then 1 else 0 end) as Refused_credit
                , sum(case when NAME_CONTRACT_STATUS = 'Unused o' then 1 else 0 end) as Unused_credit
                , sum(abs(DAYS_DECISION)) as SUM_DAYS_DECISION
                , max(abs(DAYS_DECISION)) as MAX_DAYS_DECISION
                , AVG(abs(DAYS_DECISION)) as AVG_DAYS_DECISION
                , count(distinct(NAME_PAYMENT_TYPE)) as NAME_PAYMENT_TYPE_cnt /* count number of payment methods */
                , count(distinct(CODE_REJECT_REASON)) as CODE_REJECT_REASON_cnt
                , sum(case when NAME_TYPE_SUITE in ('Children','Family','Group of people','Spouse, partner') then 1 else 0 end)
                  as Accomp_Y
                , sum(case when NAME_TYPE_SUITE in ('Unaccompanied') then 1 else 0 end) as Accomp_N
                , sum(case when NAME_TYPE_SUITE not in ('Children','Family','Group of people','Spouse, partner','Unaccompanied')
                        then 1 else 0 end) as Accomp_Flag_Other
                , sum(case when NAME_TYPE_SUITE in ('Children','Family','Group of people','Spouse, partner') then 1 else 0 end)
                  /
                  count(*) as Accomp_Flag_Y_pct

                , sum(case when NAME_TYPE_SUITE in ('Unaccompanied') then 1 else 0 end) / count(*) as Accomp_Flag_N_pct

/* NOTE: avoid multicollinearity for term below*/
                , sum(case when NAME_TYPE_SUITE not in ('Children','Family','Group of people','Spouse, partner','Unaccompanied')
                        then 1 else 0 end) / count(*) as Accompanied_Flag_Other_pct
                , sum(case when NAME_CLIENT_TYPE = 'New' and NAME_CONTRACT_STATUS = 'Approved' then 1 else 0 end) as NEW_LOAN_APPROVAL_Y
                , sum(case when NAME_CLIENT_TYPE = 'Refreshe' and NAME_CONTRACT_STATUS = 'Approved' then 1 else 0 end)/
                        sum(case when NAME_CLIENT_TYPE = 'Refreshe' then 1 else 0 end) as REFRESHER_APPROVAL_PCT
                , sum(case when NAME_CLIENT_TYPE = 'Repeater' and NAME_CONTRACT_STATUS = 'Approved' then 1 else 0 end)/
                        sum(case when NAME_CLIENT_TYPE = 'Repeater' then 1 else 0 end) as REPEATER_APPROVAL_PCT
                , count(distinct(NAME_GOODS_CATEGORY)) as GOODS_CATEGORY_CNT
                , sum(case when NAME_PORTFOLIO = 'Cards' then 1 else 0 end)/ sum(case when NAME_PORTFOLIO <> 'XNA' then 1 else 0 end)
                        as prev_card_cnt /* count previous products*/
                , sum(case when NAME_PORTFOLIO = 'Cars' then 1 else 0 end) / sum(case when NAME_PORTFOLIO <> 'XNA' then 1 else 0 end)
                        as prev_cars_cnt /* count previous products*/
                , sum(case when NAME_PORTFOLIO = 'Cash' then 1 else 0 end) / sum(case when NAME_PORTFOLIO <> 'XNA' then 1 else 0 end)
                        as prev_cash_cnt /* count previous products*/
                , sum(case when NAME_PORTFOLIO = 'POS' then 1 else 0 end) / sum(case when NAME_PORTFOLIO <> 'XNA' then 1 else 0 end)
                        as prev_pos_cnt /* count previous products*/
                , sum(case when NAME_PRODUCT_TYPE = 'walk-in' then 1 else 0 end) as WALK_IN_Y
                , sum(case when NAME_PRODUCT_TYPE = 'x-sell' then 1 else 0 end) as CROSS_SELL_Y
                , sum(case when CHANNEL_TYPE = 'Credit and cash offices' then 1 else 0 end) as CHANNEL_CREDIT_OFFICE
                , sum(case when CHANNEL_TYPE = 'Country-wide' then 1 else 0 end) as CHANNEL_COUNTRYWIDE
                , sum(case when CHANNEL_TYPE = 'Stone' then 1 else 0 end) as CHANNEL_STONE
                , sum(case when CHANNEL_TYPE = 'Regional / Local' then 1 else 0 end) as CHANNEL_REGIONAL_LOCAL
                , sum(case when CHANNEL_TYPE not in ('Credit and cash offices','Country-wide','Stone','Regional / Local') then 1
                        else 0 end) as CHANNEL_OTHERS
                , AVG(case when SELLERPLACE_AREA = -1 then 0 else SELLERPLACE_AREA end) as AVG_SELLERPLACE_AREA

/*NAME_SELLER_INDUSTRY : too many blank values, not used */
                , sum(CNT_PAYMENT) as sum_CNT_PAYMENT
                , max(CNT_PAYMENT) as MAX_CNT_PAYMENT, AVG(CNT_PAYMENT) as AVG_CNT_PAYMENT
                , sum(case when NAME_YIELD_GROUP = 'middle' then 1 else 0 end) as middle_int_group
                , sum(case when NAME_YIELD_GROUP = 'high' then 1 else 0 end) as high_int_group
                , sum(case when NAME_YIELD_GROUP in ('low_normal', 'low_action') then 1 else 0 end) as low_int_group
                , sum(case when PRODUCT_COMBINATION like 'Cash%' then 1 else 0 end) as product_cash
                , sum(case when PRODUCT_COMBINATION like 'POS %' then 1 else 0 end) as product_POS
                , sum(case when PRODUCT_COMBINATION like 'Card %' then 1 else 0 end) as product_card
                , sum(case when PRODUCT_COMBINATION like '% household %' then 1 else 0 end) as product_household
                , sum(case when PRODUCT_COMBINATION like '% mobile %' then 1 else 0 end) as product_mobile
                , sum(case when PRODUCT_COMBINATION like '% X-Sell %' then 1 else 0 end) as product_X_Sell
                , sum(case when PRODUCT_COMBINATION like '% Street %' then 1 else 0 end) as product_street
                , max(DAYS_FIRST_DRAWING) as MAX_DAYS_FIRST_DRAWING
                , min(DAYS_FIRST_DRAWING) as MIN_DAYS_FIRST_DRAWING
                , max(DAYS_FIRST_DUE) as MAX_DAYS_FIRST_DUE
                , min(DAYS_FIRST_DUE) as MIN_DAYS_FIRST_DUE
                , max(DAYS_LAST_DUE_1ST_VERSION) as MAX_DAYS_LD_1ST_VER
                , min(DAYS_FIRST_DUE) as MIN_DAYS_LD_1ST_VER
                , max(DAYS_LAST_DUE) as MAX_DAYS_LAST_DUE
                , min(DAYS_LAST_DUE) as MIN_DAYS_LAST_DUE
                , max(DAYS_TERMINATION) as MAX_DAYS_TERMINATION
                , min(DAYS_TERMINATION) as MIN_DAYS_TERMINATION
                , sum(NFLAG_INSURED_ON_APPROVAL) / count(*) as insured_pct
from Homedata.Previous_application1
where NAME_CONTRACT_TYPE in ('Cash loans','Consumer loans','Revolving loans')
group by SK_ID_CURR, NAME_CONTRACT_TYPE;

quit;

proc transpose data = HOMEDATA.Previous_application2 out = HOMEDATA.Previous_application3;
by SK_ID_CURR NAME_CONTRACT_TYPE;
run;

/* SAS 9.1 does not support the syntax for id and delimiter, work around is to make a field manually */
data HOMEDATA.Previous_application3_2;
set HOMEDATA.Previous_application3;
header = catx("_",NAME_CONTRACT_TYPE,_NAME_);
run;

proc transpose data = HOMEDATA.Previous_application3_2 out = HOMEDATA.Previous_application4 (drop = _NAME_);
by SK_ID_CURR;
id header;
var COL1;
run;

/*proc transpose data = HOMEDATA.Previous_application3 out = HOMEDATA.Previous_application4 (drop = _NAME_) DELIMITER = _;
by SK_ID_CURR;
id NAME_CONTRACT_TYPE _NAME_;
var COL1;
run;
*/

/* merge data */

data HOMEDATA.Train_test4;
merge HOMEDATA.Train_test3(in=a) HOMEDATA.Previous_application4(in=b);
by SK_ID_CURR;
if a;
array list_var Consum_previous_application_numb -- Rev_insured_pct;
do over list_var;
list_var = coalesce(list_var,0);
end;
run;

/*******************************************************************/
* 3. Previous Application data: End ;
/*******************************************************************/
/*****************************************************************************/
* 4. Previous Performance in Home Credit: Start;
/*****************************************************************************/
proc sort data = homedata.Pos_cash_balance out = homedata.Pos_cash_balance2;
by SK_ID_CURR SK_ID_PREV descending MONTHS_BALANCE NAME_CONTRACT_STATUS;
where name_contract_status in ('Active','Comple');
run;

/*proc freq data = homedata.pos_cash_balance;
tables name_contract_status;
run;*/

/* get the latest status for every previous products for a certain loan*/
data homedata.Pos_cash_balance3;
set homedata.Pos_cash_balance2;
if first.SK_ID_PREV then status_row = 1; else status_row = 0;
by SK_ID_CURR SK_ID_PREV descending MONTHS_BALANCE NAME_CONTRACT_STATUS;
run;

proc sql;
        Create table homedata.Pos_cash_balance4 as
        select SK_ID_CURR,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Comple' then 1 else 0 end) as home_cred_comp,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Active' then 1 else 0 end) as home_cred_act,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Comple' then 1 else 0 end)/ sum(status_row) as home_cred_comp_pct,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Active' then 1 else 0 end)/ sum(status_row) as home_cred_act_pct,
          max(MONTHS_BALANCE) as max_home_cred_month, /* minimum month (-ve) since most recent account: active / complete */
          avg(CNT_INSTALMENT) as avg_home_cred_insta,
          max(CNT_INSTALMENT) as max_home_cred_insta,
          max(SK_DPD-SK_DPD_DEF) as max_DPD_net,
          max(SK_DPD-SK_DPD_DEF) / sum(status_row)  as avg_DPD_net,
          max(SK_DPD_DEF) as max_DPD_tolerance,
          max(SK_DPD_DEF) / sum(status_row)  as avg_DPD_tolerance,
          sum(case when(SK_DPD-SK_DPD_DEF) > 0 then 1 else 0 end) as home_cred_DPD_cnt /* count the numbers of months that has DPD*/
        from homedata.Pos_cash_balance3
        group by SK_ID_CURR;
quit;

data HOMEDATA.Train_test5;
merge HOMEDATA.Train_test4(in=a) HOMEDATA.Pos_cash_balance4(in=b);
by SK_ID_CURR;
if a;
array list_var home_cred_comp -- home_cred_DPD_cnt;
do over list_var;
list_var = coalesce(list_var,0);
end;
run;

/*****************************************************************************/
* 4. Previous Performance in Home Credit: End;
/*****************************************************************************/
/*****************************************************************************/
* 5. Installments Payments: Start ;
/*****************************************************************************/
proc sort data = Homedata.Installments_payments;
by SK_ID_CURR SK_ID_PREV descending NUM_INSTALMENT_VERSION;
run;

proc sql;
/* account behavior, so counted on SK_ID level */
       Create table homedata.Installments_payments2 as
       select SK_ID_CURR,
              count(distinct(NUM_INSTALMENT_VERSION)) as NUM_INSTALMENT_VERSION_CNT,
              avg(DAYS_INSTALMENT - DAYS_ENTRY_PAYMENT) as AVG_INSTALMENT_DELAY,
              max(DAYS_INSTALMENT - DAYS_ENTRY_PAYMENT) as MAX_INSTALMENT_DELAY,
              avg(AMT_PAYMENT - AMT_INSTALMENT) as AVG_INSTALMENT_AMT_DIFF,
              max(AMT_PAYMENT - AMT_INSTALMENT) as MAX_INSTALMENT_AMT_DIFF
       from homedata.Installments_payments
       group by SK_ID_CURR;
quit;

data HOMEDATA.Train_test6;
merge HOMEDATA.Train_test5(in=a) HOMEDATA.Installments_payments2(in=b);
by SK_ID_CURR;
if a;
array list_var NUM_INSTALMENT_VERSION_CNT -- MAX_INSTALMENT_AMT_DIFF;
do over list_var;
               list_var = coalesce(list_var,0);
end;
run;
/*****************************************************************************/
* 5. Installments Payments: End ;
/*****************************************************************************/
/*****************************************************************************/
* 6. Credit Card Balance: Start ;
/*****************************************************************************/
proc sql;
        Create table HOMEDATA.Credit_card_balance1a as
        /* count previous ac #, though can count ac types, too difficult.. */
        select SK_ID_CURR, count(distinct(SK_ID_PREV)) as CREDIT_CARD_CNT
        from HOMEDATA.Credit_card_balance
        group by SK_ID_CURR;

        Create table HOMEDATA.Credit_card_balance1b as
        select SK_ID_CURR, MONTHS_BALANCE, sum(AMT_BALANCE) as AMT_BALANCE, /*to prepare for WEIGHTED_AMT */
               sum(AMT_CREDIT_LIMIT_ACTUAL) as AMT_CREDIT_LIMIT_ACTUAL,
               sum(AMT_DRAWINGS_CURRENT) as AMT_DRAWINGS_CURRENT,
               sum(AMT_PAYMENT_CURRENT) as AMT_PAYMENT_CURRENT,
               sum(case when AMT_PAYMENT_CURRENT < AMT_INST_MIN_REGULARITY then 1 else 0 end) as Paid_less_than_mp,
               sum(CNT_DRAWINGS_CURRENT) as CNT_DRAWINGS_CURRENT,
               sum(SK_DPD - SK_DPD_DEF) as DPD_MONTHS_SUM
        from HOMEDATA.Credit_card_balance
        group by SK_ID_CURR, MONTHS_BALANCE;

quit;

data HOMEDATA.Credit_card_balance2b;
        set HOMEDATA.Credit_card_balance1b;
* calculate different indicators;
CREDIT_CARD_UTIL = coalesce(AMT_BALANCE / AMT_CREDIT_LIMIT_ACTUAL,0); /* used to cal mean and sd */
CREDIT_CARD_PAYMENT = coalesce(AMT_PAYMENT_CURRENT / AMT_BALANCE,0);
CREDIT_CARD_AMT_PAYMENT_CURRENT = coalesce(AMT_PAYMENT_CURRENT,0);
CC_Paid_less_than_mp = Paid_less_than_mp;
CREDIT_CARD_CNT_DRAWINGS_CURRENT = CNT_DRAWINGS_CURRENT;
CREDIT_CARD_DPD_MONTHS_SUM = DPD_MONTHS_SUM;
run;

* calculate risk factors - mean + variance;
proc summary data = HOMEDATA.Credit_card_balance2b noprint;
Class SK_ID_CURR;
var CREDIT_CARD_UTIL
CREDIT_CARD_PAYMENT
CC_Paid_less_than_mp
CREDIT_CARD_CNT_DRAWINGS_CURRENT
CREDIT_CARD_DPD_MONTHS_SUM;
output out = HOMEDATA.Credit_card_balance3b
        mean(CREDIT_CARD_UTIL) = mean_CREDIT_CARD_UTIL
        std(CREDIT_CARD_UTIL) = std_CREDIT_CARD_UTIL
        mean(CREDIT_CARD_PAYMENT) = mean_CREDIT_CARD_PAYMENT
        std(CREDIT_CARD_PAYMENT) = std_CREDIT_CARD_PAYMENT
        mean(CC_Paid_less_than_mp) = mean_CC_Paid_less_than_mp
        mean(CREDIT_CARD_CNT_DRAWINGS_CURRENT) = mean_CC_CNT_DRAWINGS_CURRENT
        mean(CREDIT_CARD_DPD_MONTHS_SUM) = mean_CC_DPD_MONTHS_SUM;
run;

proc sort data = HOMEDATA.Credit_card_balance3b;
by SK_ID_CURR;
run;

proc sort data = HOMEDATA.Credit_card_balance1a;
by SK_ID_CURR;
run;

data HOMEDATA.Credit_card_balance4;
merge HOMEDATA.Credit_card_balance3b HOMEDATA.Credit_card_balance1a;
by SK_ID_CURR;
where SK_ID_CURR <> .;
drop _TYPE_ _FREQ_;
run;

data HOMEDATA.Train_test7;
merge HOMEDATA.Train_test6(in=a) HOMEDATA.Credit_card_balance4(in=b);
by SK_ID_CURR;
if a;
array list_var mean_CREDIT_CARD_UTIL -- CREDIT_CARD_CNT;
do over list_var;
               list_var = coalesce(list_var,0);
end;
run;
/*****************************************************************************/
* 6. Credit Card Balance: End ;
/*****************************************************************************/
/*****************************************************************************/
/* Fit logistic regression model: Start */
/*****************************************************************************/
data HOMEDATA.Train_test_final;
set HOMEDATA.Train_test7;
array char_var {*} _character_;

do i = 1 to dim(char_var);
        if char_var[i] = '' then char_var[i] = 'UNKNOWN';
end;
run;

Proc freq data = Homedata.Train_test_final NLEVELS;
Tables _ALL_ / noprint; * noprint to suppress printing for all variable details;
Run;
/*****************************************************************************/
/* Fit logistic regression model: End */
/*****************************************************************************/
/* get the latest status for every previous products for a certain loan*/
/*
data homedata.Pos_cash_balance3;
set homedata.Pos_cash_balance2;
if first.SK_ID_PREV then status_row = 1; else status_row = 0;
by SK_ID_CURR SK_ID_PREV descending MONTHS_BALANCE NAME_CONTRACT_STATUS;
run;
*/
/*
proc sql;
        Create table homedata.Pos_cash_balance4 as
        select SK_ID_CURR,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Comple' then 1 else 0 end) as home_cred_comp,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Active' then 1 else 0 end) as home_cred_act,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Comple' then 1 else 0 end)/ sum(status_row) as home_cred_comp_pct,
          sum(case when status_row = 1 and NAME_CONTRACT_STATUS = 'Active' then 1 else 0 end)/ sum(status_row) as home_cred_act_pct,
          max(MONTHS_BALANCE) as max_home_cred_month, /* minimum month (-ve) since most recent account: active / complete */
/*
          avg(CNT_INSTALMENT) as avg_home_cred_insta,
          max(CNT_INSTALMENT) as max_home_cred_insta,
          max(SK_DPD-SK_DPD_DEF) as max_DPD_net,
          max(SK_DPD-SK_DPD_DEF) / sum(status_row)  as avg_DPD_net,
          max(SK_DPD_DEF) as max_DPD_tolerance,
          max(SK_DPD_DEF) / sum(status_row)  as avg_DPD_tolerance
        from homedata.Pos_cash_balance3
        group by SK_ID_CURR;
quit;
*/
/*****************************************************************************/
/* Fit logistic regression model: Start */
/*****************************************************************************/
Proc freq data = Homedata.Train_final NLEVELS;
Tables _ALL_ / noprint; * noprint to suppress printing for all variable details;
Run;

data Homedata.see;
set Homedata.Train_final;
*where AMT_GOODS_PRICE = .;
where SK_ID_CURR = 100837;
run;

proc freq data = HOMEDATA.Train_final;
tables TARGET;
run;

/*
data HOMEDATA.Train_test_final;
set HOMEDATA.Train_test2;
array char_var {*} _character_;

do i = 1 to dim(char_var);
        if char_var[i] = '' then char_var[i] = 'UNKNOWN';
end;
run;  */

/* Modeling starts here*/
data HOMEDATA.Train_final0;
set HOMEDATA.Train_test_final;
where source = 'TRAIN';
run;

data HOMEDATA.Test_final;
set HOMEDATA.Train_test_final;
where source = 'TEST';
run;

* oversample data;
proc surveyselect data = HOMEDATA.Train_final0 out = HOMEDATA.Train_oversampled seed = 123
                                                     method=urs sampsize = 282686 /*sample size*/
                                                     OUTHITS; /* oversampling*/
where TARGET = 1;
run;

* final training data;
data HOMEDATA.Train_final;
set HOMEDATA.Train_final0 (where = (TARGET = 0)) HOMEDATA.Train_oversampled;
drop source;
run;

proc logistic data = HOMEDATA.Train_final outmodel = HOMEDATA.CreditModel outest = HOMEDATA.betas;
class NAME_CONTRACT_TYPE CODE_GENDER FLAG_OWN_CAR FLAG_OWN_REALTY
      NAME_TYPE_SUITE NAME_INCOME_TYPE NAME_EDUCATION_TYPE
      NAME_FAMILY_STATUS NAME_HOUSING_TYPE OCCUPATION_TYPE
      WEEKDAY_APPR_PROCESS_START ORGANIZATION_TYPE FONDKAPREMONT_MODE
      HOUSETYPE_MODE WALLSMATERIAL_MODE EMERGENCYSTATE_MODE;
model TARGET(event='1') = NAME_CONTRACT_TYPE -- CREDIT_CARD_CNT
                                               / SELECTION = BACKWARD
                                                             FAST
                                                             DETAILS
                                                             LACKFIT;
run;

proc logistic inmodel=HOMEDATA.CreditModel;
score data = HOMEDATA.Test_final out=HOMEDATA.Test_final2;
run;
/*****************************************************************************/
/* Fit logistic regression model: End */
/*****************************************************************************/
