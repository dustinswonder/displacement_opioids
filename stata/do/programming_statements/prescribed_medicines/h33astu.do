/************************************************************************************************/
/* Stata User File for H33A Data                                                                 */
/*                                                                                              */
/* This file contains information and a sample Stata program to create a permanent              */
/* Stata dataset for users who want to use Stata in processing the MEPS data provided           */
/* in this PUF release.  Stata (StataCorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the Medical Expenditure Panel Survey (MEPS).                                  */
/* The input file for creating a permanent Stata dataset is the ASCII data file                 */
/* (H33A.DAT) supplied in this PUF release, which in turn can be extracted from the              */
/* .EXE file. After entering the Stata interactive environment access the Stata DO-File         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  Copy and paste the following Stata commands into the editor and save as a           */
/* DO file.  A DO file is a Stata program which may then be executed using the DO command.      */
/* For example, if the DO file is named H33A.DO and is located in the directory                  */
/* C:\MEPS\PROG, then the file may be executed by typing the following command into             */
/* the Stata command line:                                                                      */
/*                         do C:\MEPS\PROG\H33A.DO                                               */
/* The program below will output the Stata dataset H33A.DTA                                      */
/************************************************************************************************/


#delimit ;

log using $logdir/H33A.log, replace;
clear;

* INPUT ALL VARIABLES;
infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  str    RXRECIDX 17-31
  str    LINKIDX 32-43
  byte   PURCHRD 44-44
  byte   RXR2FLAG 45-46
  byte   RXBEGDD 47-48
  byte   RXBEGMM 49-50
  int    RXBEGYR 51-54
  str    RXNAME 55-104
  str    RXHHNAME 105-134
  str    RXNDC 135-145
  double RXQUANTY 146-152
  str    RXFORM 153-202
  str    RXFRMUNT 203-252
  str    RXSTRENG 253-302
  str    RXUNIT 303-352
  str    RXUNITOS 353-402
  byte   PHARTP1 403-404
  byte   PHARTP2 405-406
  byte   PHARTP3 407-408
  byte   PHARTP4 409-410
  byte   PHARTP5 411-412
  byte   PHARTP6 413-414
  byte   PHARTP7 415-416
  byte   RXFLG 417-417
  byte   PCIMPFLG 418-418
  byte   CLMOMFLG 419-419
  byte   INPCFLG 420-420
  byte   DIABFLG 421-421
  byte   SAMPLE 422-422
  str    RXICD1X 423-425
  str    RXICD2X 426-428
  str    RXICD3X 429-431
  str    RXCCC1X 432-434
  str    RXCCC2X 435-437
  str    RXCCC3X 438-440
  double RXSF99X 441-447
  double RXMR99X 448-454
  double RXMD99X 455-461
  double RXPV99X 462-468
  double RXVA99X 469-474
  double RXCH99X 475-480
  double RXOF99X 481-485
  double RXSL99X 486-491
  double RXWC99X 492-497
  double RXOT99X 498-503
  double RXOR99X 504-509
  double RXOU99X 510-515
  double RXXP99X 516-522
  double PERWT99F 523-534
  int    VARSTR99 535-537
  byte   VARPSU99 538-539
using $datadir/prescribed_medicines/H33A.dat;

*DEFINE VARIABLE LABELS;
label variable DUID "DWELLING UNIT ID";
label variable PID "PERSON NUMBER";
label variable DUPERSID "PERSON ID (DUID + PID)";
label variable RXRECIDX "UNIQUE Rx/PRESCRIBED MEDICINE IDENTIFIER";
label variable LINKIDX "ID FOR LINKAGE TO COND/OTH EVENT FILES";
label variable PURCHRD "ROUND Rx/PRESCR MED OBTAINED/PURCHASED";
label variable RXR2FLAG "FLAG FOR PANEL 3 R2 EVENT IN 1999";
label variable RXBEGDD "DAY PERSON STARTED TAKING MEDICINE";
label variable RXBEGMM "MONTH PERSON STARTED TAKING MEDICINE";
label variable RXBEGYR "YEAR PERSON STARTED TAKING MEDICINE";
label variable RXNAME "MEDICATION NAME (IMPUTED)";
label variable RXHHNAME "HC REPORTED MEDICATION NAME";
label variable RXNDC "NATIONAL DRUG CODE (IMPUTED)";
label variable RXQUANTY "QUANTITY OF Rx/PRESCR MED (IMPUTED)";
label variable RXFORM "FORM OF Rx/PRESCRIBED MEDICINE (IMPUTED)";
label variable RXFRMUNT "UNIT OF MEAS FORM Rx/PRESC MED (IMPUTED)";
label variable RXSTRENG "STRENGTH OF Rx/PRESCR MED DOSE (IMPUTED)";
label variable RXUNIT "UNIT OF MEAS STRENGTH OF Rx (IMPUTED)";
label variable RXUNITOS "OTH SPEC UNIT MEAS Rx MED DOSE (IMPUTED)";
label variable PHARTP1 "TYPE OF PHARMACY PROV - 1ST";
label variable PHARTP2 "TYPE OF PHARMACY PROV - 2ND";
label variable PHARTP3 "TYPE OF PHARMACY PROV - 3RD";
label variable PHARTP4 "TYPE OF PHARMACY PROV - 4TH";
label variable PHARTP5 "TYPE OF PHARMACY PROV - 5TH";
label variable PHARTP6 "TYPE OF PHARMACY PROV - 6TH";
label variable PHARTP7 "TYPE OF PHARMACY PROV - 7TH";
label variable RXFLG "NDC IMPUTATION SOURCE ON PC DONOR REC";
label variable PCIMPFLG "TYPE OF HC TO PC PRESCRIPTION MATCH";
label variable CLMOMFLG "CHGE/PYMNT, Rx CLAIM FILING, OMTYPE STAT";
label variable INPCFLG "PID HAS AT LEAST 1 RECORD IN PC";
label variable DIABFLG "Rx INSULIN OR DIABETIC EQUIPMENT/SUPPLY";
label variable SAMPLE "HOUSEHLD RCVD FREE SAMPLE OF Rx IN ROUND";
label variable RXICD1X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD2X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD3X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXCCC1X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC2X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC3X "MODIFIED CLINICAL CLASS CODE";
label variable RXSF99X "AMOUNT PAID, SELF OR FAMILY (IMPUTED)";
label variable RXMR99X "AMOUNT PAID, MEDICARE (IMPUTED)";
label variable RXMD99X "AMOUNT PAID, MEDICAID (IMPUTED)";
label variable RXPV99X "AMOUNT PAID, PRIVATE INSURANCE (IMPUTED)";
label variable RXVA99X "AMOUNT PAID, VETERANS (IMPUTED)";
label variable RXCH99X "AMOUNT PAID, CHAMPUS/CHAMPVA (IMPUTED)";
label variable RXOF99X "AMOUNT PAID, OTHER FEDERAL (IMPUTED)";
label variable RXSL99X "AMOUNT PAID, STATE & LOCAL GOV (IMPUTED)";
label variable RXWC99X "AMOUNT PAID, WORKERS COMP (IMPUTED)";
label variable RXOT99X "AMOUNT PAID, OTHER INSURANCE (IMPUTED)";
label variable RXOR99X "AMOUNT PAID, OTHER PRIVATE (IMPUTED)";
label variable RXOU99X "AMOUNT PAID, OTHER PUBLIC (IMPUTED)";
label variable RXXP99X "SUM OF PAYMENTS RXSF99X-RXOU99X(IMPUTED)";
label variable PERWT99F "FINAL PERSON LEVEL WEIGHT, 1999";
label variable VARSTR99 "VARIANCE ESTIMATION STRATUM, 1999";
label variable VARPSU99 "VARIANCE ESTIMATION PSU, 1999";


*DEFINE VALUE LABELS FOR REPORTS;
label define H33A0001X
         1 "1 C+P=N,FILER=PHARMACY"
         2 "2 C+P=N,FILER=NEITHER"
         3 "3 C+P=Y,FILER=UNK/INAP"
         4 "4 C+P=Y,FILER=FAMILY"
         5 "5 C+P=Y,FILER=PHARMACY,OM=2,3"
         6 "6 C+P=Y,FILER=NEITHER,OM=2,3" ;

label define H33A0002X
         0 "0 NO"
         1 "1 YES" ;

label define H33A0003X
         0 "0 NO"
         1 "1 YES" ;

label define H33A0004X
         1 "1 EXACT MATCH TO PC Rx FOR PID"
         2 "2 NOT EXACT MATCH TO PC Rx FOR PID" ;

label define H33A0005X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0006X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0007X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0008X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0009X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0010X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0011X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H33A0012X
         1 "1"
         2 "2"
         3 "3"
         4 "4"
         5 "5" ;

label define H33A0013X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H33A0014X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H33A0015X
         -1 "-1 INAPPLICABLE"
         -14 "-14 NOT YET USED/TAKEN"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H33A0016X
         1 "1 NO IMPUTATION"
         2 "2 IMPUTED FROM OTHER PC RECORD"
         3 "3 IMPUTED FR SECONDARY SRC, BUT ORIG REPORTED" ;

label define H33A0017X
         -1 "-1 NO R2 CROSSOVER PROBLEM"
         1 "1 PANEL 3 R2 EVENT IN 1999" ;

label define H33A0018X
         0 "0 NO"
         1 "1 YES" ;

* ASSOCIATE VARIABLES WITH VALUE LABEL DEFINITIONS;
label value CLMOMFLG H33A0001X;
label value DIABFLG H33A0002X;
label value INPCFLG H33A0003X;
label value PCIMPFLG H33A0004X;
label value PHARTP1 H33A0005X;
label value PHARTP2 H33A0006X;
label value PHARTP3 H33A0007X;
label value PHARTP4 H33A0008X;
label value PHARTP5 H33A0009X;
label value PHARTP6 H33A0010X;
label value PHARTP7 H33A0011X;
label value PURCHRD H33A0012X;
label value RXBEGDD H33A0013X;
label value RXBEGMM H33A0014X;
label value RXBEGYR H33A0015X;
label value RXFLG H33A0016X;
label value RXR2FLAG H33A0017X;
label value SAMPLE H33A0018X;

*DISPLAY A DESCRIPTION OF STATA FILE;
describe;

*LIST FIRST 20 OBSERVATIONS IN THE FILE;
list in 1/20;

save $rawdir/prescribed_medicines/H33A, replace;

#delimit cr

* data file is stored in H33A.dta
* log  file is stored in H33A.log

log close

/************************************************************************************************
 NOTES:                                                                                          
                                                                                                 
 1. This program has been tested on Stata Version 10 (for Windows).                              
                                                                                                 
 2. This program will create a permanent Stata dataset.  All additional analyses                 
    can be run using this dataset.  In addition to the dataset, this program creates             
    a log file named H33A.LOG and a data file named H33A.DTA.  If these files (H33A.DTA and H33A.LOG)
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

