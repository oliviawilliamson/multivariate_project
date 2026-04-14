*Olivia Williamson, Andres Davila;
*2026-04-13;
*Logistic Regression - HIV Seropositivity;

libname mydata "/home/u62932621/Multivariate/FinalProject/";

*--------------------------------------------------------------------------------------;
* Load dataset;
*--------------------------------------------------------------------------------------;
proc contents data=mydata.nhanes_scored;
run;

*--------------------------------------------------------------------------------------;
* Outcome and key covariate distributions prior to modeling;
*--------------------------------------------------------------------------------------;
proc freq data=mydata.nhanes_scored;
    tables LBXHIVC RIAGENDR RIDRETH1 SMQ040 
           DIQ010 MCQ160C BPQ020 SXQ294 DUQ250;
run;

*--------------------------------------------------------------------------------------;
* How many observations have each variable non-missing;
*--------------------------------------------------------------------------------------;
proc means data=mydata.nhanes_scored n nmiss;
    var Factor1 Factor2 Factor3 Factor4 Factor5
        LBXHIVC RIAGENDR RIDRETH1 SMQ040
        DIQ010 MCQ160C BPQ020 SXQ294 DUQ250
        LBXGLU SXQ292;
run;

*--------------------------------------------------------------------------------------;
* How many observations have ALL variables non-missing simultaneously;
*--------------------------------------------------------------------------------------;
data work.check;
    set mydata.nhanes_scored;
    if nmiss(Factor1, Factor2, Factor3, Factor4, Factor5,
             LBXHIVC, RIAGENDR, RIDRETH1, SMQ040,
             DIQ010, MCQ160C, BPQ020, SXQ294, DUQ250,
             LBXGLU, SXQ292) = 0;
run;

proc freq data=work.check;
    tables LBXHIVC;
run;

*--------------------------------------------------------------------------------------;
* Logistic Regression;
* Factor scores (Factor1-Factor5) enter as continuous predictors;
* Binary/categorical variables entered directly;
*--------------------------------------------------------------------------------------;
proc surveylogistic data=mydata.nhanes_scored;
    stratum SDMVSTRA;
    cluster SDMVPSU;
    weight WTMEC8YR;
    class RIAGENDR  (ref='1')
          RIDRETH1  (ref='3')
          DIQ010    (ref='2')
          MCQ160C   (ref='2')
          BPQ020    (ref='2')
          / param=ref;
    model LBXHIVC(event='1') =
          Factor1
          Factor2
          Factor3
          Factor4
          Factor5
          RIAGENDR
          RIDRETH1
          DIQ010
          MCQ160C
          BPQ020
          / expb;
run;
*SXQ294, DUQ250, SXQ292, and LBXGLU dropped from regression; 

*--------------------------------------------------------------------------------------;
* Logistic Regression;
* JUST factor scores, no categorical covariates;
*--------------------------------------------------------------------------------------;
proc surveylogistic data=mydata.nhanes_scored;
    stratum SDMVSTRA;
    cluster SDMVPSU;
    weight WTMEC8YR;
    model LBXHIVC(event='1') =
          Factor1
          Factor2
          Factor3
          Factor4
          Factor5
          / expb;
    ods output OddsRatios=work.or_table
               ParameterEstimates=work.pe_table;
run;

proc print data=work.or_table noobs;
    title "Odds Ratios - HIV Seropositivity";
run;

proc print data=work.pe_table noobs;
    title "Parameter Estimates - HIV Seropositivity";
run;


