/************************************************************************************************/
/* Stata User File for HC010A Data                                                                 */
/*                                                                                              */
/* This file contains information and a sample Stata program to create a permanent              */
/* Stata dataset for users who want to use Stata in processing the MEPS data provided           */
/* in this PUF release.  Stata (StataCorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the Medical Expenditure Panel Survey (MEPS).                                  */
/* The input file for creating a permanent Stata dataset is the ASCII data file                 */
/* (hc10a.DAT) supplied in this PUF release, which in turn can be extracted from the              */
/* .EXE file. After entering the Stata interactive environment access the Stata DO-File         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  Copy and paste the following Stata commands into the editor and save as a           */
/* DO file.  A DO file is a Stata program which may then be executed using the DO command.      */
/* For example, if the DO file is named hc10a.DO and is located in the directory                  */
/* C:\MEPS\PROG, then the file may be executed by typing the following command into             */
/* the Stata command line:                                                                      */
/*                         do C:\MEPS\PROG\hc10a.DO                                               */
/* The program below will output the Stata dataset hc10a.DTA                                      */
/************************************************************************************************/


#delimit ;

log using $logdir/hc10a.log, replace;
clear;

* INPUT ALL VARIABLES;
infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  str    RXRECIDX 17-33
  str    LINKIDX 34-45
  byte   PURCHRD 46-46
  byte   RXBEGDD 47-48
  byte   RXBEGMM 49-50
  int    RXBEGYR 51-54
  str    RXNAME 55-94
  str    RXHHNAME 95-124
  str    RXNDC 125-135
  double RXQUANTY 136-142
  str    RXFORM 143-152
  str    RXSTRENG 153-162
  str    RXUNIT 163-172
  byte   PHARTP1 173-174
  byte   PHARTP2 175-176
  byte   PHARTP3 177-178
  byte   PHARTP4 179-180
  byte   PHARTP5 181-182
  byte   PHARTP6 183-184
  byte   PHARTP7 185-186
  byte   RXFLG 187-187
  byte   PCIMPFLG 188-188
  byte   SELFFLG 189-189
  byte   INPCFLG 190-190
  byte   DIABFLG 191-191
  byte   SAMPLE 192-192
  str    RXICD1X 193-195
  str    RXICD2X 196-198
  str    RXICD3X 199-201
  str    RXCCC1X 202-204
  str    RXCCC2X 205-207
  str    RXCCC3X 208-210
  byte   NUMCOND 211-212
  double RXSF96X 213-218
  double RXMR96X 219-224
  double RXMD96X 225-231
  double RXPV96X 232-238
  double RXVA96X 239-244
  double RXCH96X 245-250
  double RXOF96X 251-256
  double RXSL96X 257-262
  double RXWC96X 263-268
  double RXOT96X 269-274
  double RXOR96X 275-280
  double RXOU96X 281-285
  double RXXP96X 286-292
  double WTDPER96 293-304
  int    VARSTR96 305-307
  byte   VARPSU96 308-309
using $datadir/prescribed_medicines/HC10A.dat;

*DEFINE VARIABLE LABELS;
label variable DUID "DWELLING UNIT ID";
label variable PID "PERSON NUMBER";
label variable DUPERSID "PERSON ID (DUID + PID)";
label variable RXRECIDX "UNIQUE Rx/PRESCRIBED MEDICINE IDENTIFIER";
label variable LINKIDX "ID FOR LINKAGE TO COND/OTH EVENT FILES";
label variable PURCHRD "ROUND Rx/PRESCR MED OBTAINED/PURCHASED";
label variable RXBEGDD "DAY PERSON STARTED TAKING MEDICINE";
label variable RXBEGMM "MONTH PERSON STARTED TAKING MEDICINE";
label variable RXBEGYR "YEAR PERSON STARTED TAKING MEDICINE";
label variable RXNAME "MEDICATION NAME (IMPUTED)";
label variable RXHHNAME "HC REPORTED MEDICATION NAME (IMPUTED)";
label variable RXNDC "NATIONAL DRUG CODE (IMPUTED)";
label variable RXQUANTY "QUANTITY OF Rx/PRESCR MED (IMPUTED)";
label variable RXFORM "FORM OF Rx/PRESCRIBED MEDICINE (IMPUTED)";
label variable RXSTRENG "STRENGTH OF Rx/PRESCR MED DOSE (IMPUTED)";
label variable RXUNIT "UNIT OF MEAS Rx/PRES MED DOSE (IMPUTED)";
label variable PHARTP1 "TYPE OF PHARMACY PROV - 1ST (IMPUTED)";
label variable PHARTP2 "TYPE OF PHARMACY PROV - 2ND (IMPUTED)";
label variable PHARTP3 "TYPE OF PHARMACY PROV - 3RD (IMPUTED)";
label variable PHARTP4 "TYPE OF PHARMACY PROV - 4TH (IMPUTED)";
label variable PHARTP5 "TYPE OF PHARMACY PROV - 5TH (IMPUTED)";
label variable PHARTP6 "TYPE OF PHARMACY PROV - 6TH (IMPUTED)";
label variable PHARTP7 "TYPE OF PHARMACY PROV - 7TH (IMPUTED)";
label variable RXFLG "NDC IMPUTE SCE ON PC DONOR REC (IMPUTED)";
label variable PCIMPFLG "TYPE OF HC TO PC PRESCRIPTION MATCH";
label variable SELFFLG "EVENT IS A SELF-FILER EVENT";
label variable INPCFLG "PID HAS AT LEAST 1 REC IN PC (IMPUTED)";
label variable DIABFLG "Rx INSULIN OR DIAB EQUIP/SUPP (IMPUTED)";
label variable SAMPLE "HOUSEHLD RCVD FREE SAMPLE OF Rx IN ROUND";
label variable RXICD1X "3 DIGIT ICD-9 CONDITION CODE (IMPUTED)";
label variable RXICD2X "3 DIGIT ICD-9 CONDITION CODE (IMPUTED)";
label variable RXICD3X "3 DIGIT ICD-9 CONDITION CODE (IMPUTED)";
label variable RXCCC1X "MODIFIED CLINICAL CLASS CODE (IMPUTED)";
label variable RXCCC2X "MODIFIED CLINICAL CLASS CODE (IMPUTED)";
label variable RXCCC3X "MODIFIED CLINICAL CLASS CODE (IMPUTED)";
label variable NUMCOND "TOT # COND RECS LINK TO EVNT (IMPUTED)";
label variable RXSF96X "AMOUNT PAID, SELF OR FAMILY (IMPUTED)";
label variable RXMR96X "AMOUNT PAID, MEDICARE (IMPUTED)";
label variable RXMD96X "AMOUNT PAID, MEDICAID (IMPUTED)";
label variable RXPV96X "AMOUNT PAID, PRIVATE INSURANCE (IMPUTED)";
label variable RXVA96X "AMOUNT PAID, VETERANS (IMPUTED)";
label variable RXCH96X "AMOUNT PAID, CHAMPUS/CHAMPVA (IMPUTED)";
label variable RXOF96X "AMOUNT PAID, OTHER FEDERAL (IMPUTED)";
label variable RXSL96X "AMOUNT PAID, STATE & LOCAL GOV (IMPUTED)";
label variable RXWC96X "AMOUNT PAID, WORKERS COMP (IMPUTED)";
label variable RXOT96X "AMOUNT PAID, OTHER INSURANCE (IMPUTED)";
label variable RXOR96X "AMOUNT PAID, OTHER PRIVATE (IMPUTED)";
label variable RXOU96X "AMOUNT PAID, OTHER PUBLIC (IMPUTED)";
label variable RXXP96X "SUM OF PAYMENTS RXSF96X-RXOU96X(IMPUTED)";
label variable WTDPER96 "POVERTY/MORTALITY ADJUSTED PERS LEVL WGT";
label variable VARSTR96 "VARIANCE ESTIMATION STRATUM, 1996";
label variable VARPSU96 "VARIANCE ESTIMATION PSU, 1996";


*DEFINE VALUE LABELS FOR REPORTS;
label define HC010A0001X
         0 "0 NO"
         1 "1 YES" ;

label define HC010A0002X
         0 "0 NO"
         1 "1 YES" ;

label define HC010A0003X
         0 "0"
         10 "10"
         11 "11"
         12 "12"
         4 "4"
         5 "5"
         6 "6"
         7 "7"
         8 "8"
         9 "9" ;

label define HC010A0004X
         0 "0 NONE"
         1 "1 EXACT MATCH TO PC Rx FOR PID"
         2 "2 REFILL OF EXACT MATCH TO PC Rx FOR PID"
         3 "3 NOT EXACT MATCH NOR REFILL OF EX MATCH" ;

label define HC010A0005X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0006X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0007X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0008X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0009X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0010X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0011X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define HC010A0012X
         1 "1"
         2 "2"
         3 "3" ;

label define HC010A0013X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define HC010A0014X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define HC010A0015X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         99 "99 HAS NOT YET TAKEN/USED" ;

label define HC010A0016X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0017X
         1 "1 NO IMPUTATION"
         2 "2 IMPUTED FROM OTHER PC RECORD"
         3 "3 IMPUTED FR SECONDARY SRC, BUT ORIG REPORTED" ;

label define HC010A0018X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0019X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0020X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0021X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0022X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0023X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0024X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0025X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0026X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0027X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0028X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0029X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define HC010A0030X
         0 "0 NO"
         1 "1 YES" ;

label define HC010A0031X
         0 "0 NON-SELF-FILER"
         1 "1 SELF-FILER" ;

* ASSOCIATE VARIABLES WITH VALUE LABEL DEFINITIONS;
label value DIABFLG HC010A0001X;
label value INPCFLG HC010A0002X;
label value NUMCOND HC010A0003X;
label value PCIMPFLG HC010A0004X;
label value PHARTP1 HC010A0005X;
label value PHARTP2 HC010A0006X;
label value PHARTP3 HC010A0007X;
label value PHARTP4 HC010A0008X;
label value PHARTP5 HC010A0009X;
label value PHARTP6 HC010A0010X;
label value PHARTP7 HC010A0011X;
label value PURCHRD HC010A0012X;
label value RXBEGDD HC010A0013X;
label value RXBEGMM HC010A0014X;
label value RXBEGYR HC010A0015X;
label value RXCH96X HC010A0016X;
label value RXFLG HC010A0017X;
label value RXMD96X HC010A0018X;
label value RXMR96X HC010A0019X;
label value RXOF96X HC010A0020X;
label value RXOR96X HC010A0021X;
label value RXOT96X HC010A0022X;
label value RXOU96X HC010A0023X;
label value RXPV96X HC010A0024X;
label value RXSF96X HC010A0025X;
label value RXSL96X HC010A0026X;
label value RXVA96X HC010A0027X;
label value RXWC96X HC010A0028X;
label value RXXP96X HC010A0029X;
label value SAMPLE HC010A0030X;
label value SELFFLG HC010A0031X;

*DISPLAY A DESCRIPTION OF STATA FILE;
describe;

*LIST FIRST 20 OBSERVATIONS IN THE FILE;
list in 1/20;

save $rawdir/prescribed_medicines/H10A, replace;

#delimit cr

* data file is stored in hc10a.dta
* log  file is stored in hc10a.log

log close

/************************************************************************************************
 NOTES:                                                                                          
                                                                                                 
 1. This program has been tested on Stata Version 10 (for Windows).                              
                                                                                                 
 2. This program will create a permanent Stata dataset.  All additional analyses                 
    can be run using this dataset.  In addition to the dataset, this program creates             
    a log file named hc10a.LOG and a data file named hc10a.DTA.  If these files (hc10a.DTA and hc10a.LOG)
    already exist in the working directory, they will be replaced when this program is executed. 
                                                                                                 
 3. If the program ends prematurely, the log file will remain open.  Before running this         
    program again, the user should enter the following Stata command: log close                  
                                                                                                 
 4. The cd command assigns C:\MEPS\DATA as the working directory and location of the input       
    ASCII and output .DTA and .LOG files and can be modified by the user as necessary.           
                                                                                                 
 5. Stata commands end with a carriage return by default. The command                            
    #delimit ;                                                                                   
    temporarily changes the command ending delimiter from a carriage return to a semicolon.      
                                                                                                 
 6. The infix command assumes that the input variables are numeric unless the variable name      
    is prefaced by str.  For example, DUPERSID is the a string (or character) variable.          
                                                                                                 
************************************************************************************************/

