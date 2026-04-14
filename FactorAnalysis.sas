*Olivia Williamson, Andres Davila;
*2026-04-13;
*Factor Analysis;

libname mydata "/home/u62932621/Multivariate/FinalProject/";

*Upload dataset;
proc import datafile="/home/u62932621/Multivariate/FinalProject/nhanes_analytic.csv"
    out=work.nhanes_analytic
    dbms=csv
    replace;
    getnames=yes;
    guessingrows=max;
run;

*--------------------------------------------------------------------------------------;
* Normality check — informs choice of extraction method;
*--------------------------------------------------------------------------------------;
proc univariate data=work.nhanes_analytic normal;
    var RIDAGEYR INDFMPIR BMXBMI BMXWT BMXHT
        LBXGH LBDHDD LBDLDL PAD680
        DR1TPROT DR1TCARB DR1TTFAT ALQ130;
run;

*--------------------------------------------------------------------------------------;
* Define variable list as macro for reuse — avoids repeating across every step;
*--------------------------------------------------------------------------------------;
%let factvars = RIDAGEYR INDFMPIR BMXBMI BMXWT BMXHT
                LBXGH LBDHDD LBDLDL PAD680
                DR1TPROT DR1TCARB DR1TTFAT ALQ130;

*--------------------------------------------------------------------------------------;
* Method 1: Principal Components — unrotated then varimax rotated;
* PC selected over ML due to non-normality and large sample size;
*--------------------------------------------------------------------------------------;
title "Factor Analysis - Principal Components - Unrotated";
proc factor data=work.nhanes_analytic
    method=principal nfactors=5
    simple scree ev preplot plot residuals score
    outstat=work.factout_pc;
    var &factvars;
run;

title "Factor Analysis - Principal Components - Varimax Rotation";
proc factor data=work.nhanes_analytic
    method=principal nfactors=5 rotate=varimax
    simple scree ev preplot plot residuals score
    outstat=work.factout_final;
    var &factvars;
run;

*--------------------------------------------------------------------------------------;
* Method 2: Maximum Likelihood — for comparison only;
* Note: heywood option used due to communality > 1;
*--------------------------------------------------------------------------------------;
title "Factor Analysis - Maximum Likelihood";
proc factor data=work.nhanes_analytic
    method=ml nfactors=5 heywood;
    var &factvars;
run;

title;

*--------------------------------------------------------------------------------------;
* Score dataset using final PC varimax solution;
* Save to permanent library for use in logistic regression;
*--------------------------------------------------------------------------------------;
proc score data=work.nhanes_analytic
    score=work.factout_final
    out=mydata.nhanes_scored;
    var &factvars;
run;

*--------------------------------------------------------------------------------------;
* Verify;
*--------------------------------------------------------------------------------------;
proc means data=mydata.nhanes_scored n nmiss mean std min max;
    var Factor1 Factor2 Factor3 Factor4 Factor5;
run;

proc freq data=mydata.nhanes_scored;
    tables LBXHIVC;
run;