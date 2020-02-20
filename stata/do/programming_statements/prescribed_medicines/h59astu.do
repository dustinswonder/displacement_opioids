/************************************************************************************************/
/* Stata User File for H59A Data                                                                 */
/*                                                                                              */
/* This file contains information and a sample Stata program to create a permanent              */
/* Stata dataset for users who want to use Stata in processing the MEPS data provided           */
/* in this PUF release.  Stata (StataCorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the Medical Expenditure Panel Survey (MEPS).                                  */
/* The input file for creating a permanent Stata dataset is the ASCII data file                 */
/* (H59A.DAT) supplied in this PUF release, which in turn can be extracted from the              */
/* .EXE file. After entering the Stata interactive environment access the Stata DO-File         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  Copy and paste the following Stata commands into the editor and save as a           */
/* DO file.  A DO file is a Stata program which may then be executed using the DO command.      */
/* For example, if the DO file is named H59A.DO and is located in the directory                  */
/* C:\MEPS\PROG, then the file may be executed by typing the following command into             */
/* the Stata command line:                                                                      */
/*                         do C:\MEPS\PROG\H59A.DO                                               */
/* The program below will output the Stata dataset H59A.DTA                                      */
/************************************************************************************************/


#delimit ;

log using $logdir/H59A.log, replace;
clear;

* INPUT ALL VARIABLES;
infix
  long   DUID 1-5
  int    PID 6-8
  str    DUPERSID 9-16
  str    RXRECIDX 17-31
  str    LINKIDX 32-43
  byte   PURCHRD 44-44
  byte   RXBEGDD 45-46
  byte   RXBEGMM 47-48
  int    RXBEGYR 49-52
  str    RXNAME 53-102
  str    RXHHNAME 103-132
  str    RXNDC 133-143
  double RXQUANTY 144-151
  str    RXFORM 152-201
  str    RXFRMUNT 202-251
  str    RXSTRENG 252-301
  str    RXSTRUNT 302-351
  byte   PHARTP1 352-353
  byte   PHARTP2 354-355
  byte   PHARTP3 356-357
  byte   PHARTP4 358-359
  byte   PHARTP5 360-361
  byte   PHARTP6 362-363
  byte   PHARTP7 364-365
  byte   RXFLG 366-366
  byte   PCIMPFLG 367-367
  byte   CLMOMFLG 368-368
  byte   INPCFLG 369-369
  byte   DIABFLG 370-370
  byte   SAMPLE 371-371
  str    RXICD1X 372-374
  str    RXICD2X 375-377
  str    RXICD3X 378-380
  str    RXCCC1X 381-383
  str    RXCCC2X 384-386
  str    RXCCC3X 387-389
  double RXSF01X 390-396
  double RXMR01X 397-403
  double RXMD01X 404-410
  double RXPV01X 411-417
  double RXVA01X 418-424
  double RXTR01X 425-430
  double RXOF01X 431-436
  double RXSL01X 437-442
  double RXWC01X 443-448
  double RXOT01X 449-454
  double RXOR01X 455-460
  double RXOU01X 461-466
  double RXXP01X 467-473
  double PERWT01F 474-485
  int    VARSTR01 486-488
  byte   VARPSU01 489-490
using $datadir/prescribed_medicines/H59A.dat;

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
label variable RXHHNAME "HC REPORTED MEDICATION NAME";
label variable RXNDC "NATIONAL DRUG CODE (IMPUTED)";
label variable RXQUANTY "QUANTITY OF Rx/PRESCR MED (IMPUTED)";
label variable RXFORM "FORM OF Rx/PRESCRIBED MEDICINE (IMPUTED)";
label variable RXFRMUNT "UNIT OF MEAS FORM Rx/PRESC MED (IMPUTED)";
label variable RXSTRENG "STRENGTH OF Rx/PRESCR MED DOSE (IMPUTED)";
label variable RXSTRUNT "UNIT OF MEAS STRENGTH OF Rx (IMPUTED)";
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
label variable RXSF01X "AMOUNT PAID, SELF OR FAMILY (IMPUTED)";
label variable RXMR01X "AMOUNT PAID, MEDICARE (IMPUTED)";
label variable RXMD01X "AMOUNT PAID, MEDICAID (IMPUTED)";
label variable RXPV01X "AMOUNT PAID, PRIVATE INSURANCE (IMPUTED)";
label variable RXVA01X "AMOUNT PAID, VETERANS (IMPUTED)";
label variable RXTR01X "AMOUNT PAID, TRICARE (IMPUTED)";
label variable RXOF01X "AMOUNT PAID, OTHER FEDERAL (IMPUTED)";
label variable RXSL01X "AMOUNT PAID, STATE & LOCAL GOV (IMPUTED)";
label variable RXWC01X "AMOUNT PAID, WORKERS COMP (IMPUTED)";
label variable RXOT01X "AMOUNT PAID, OTHER INSURANCE (IMPUTED)";
label variable RXOR01X "AMOUNT PAID, OTHER PRIVATE (IMPUTED)";
label variable RXOU01X "AMOUNT PAID, OTHER PUBLIC (IMPUTED)";
label variable RXXP01X "SUM OF PAYMENTS RXSF01X-RXOU01X(IMPUTED)";
label variable PERWT01F "FINAL PERSON LEVEL WEIGHT, 2001";
label variable VARSTR01 "VARIANCE ESTIMATION STRATUM, 2001";
label variable VARPSU01 "VARIANCE ESTIMATION PSU, 2001";


*DEFINE VALUE LABELS FOR REPORTS;
label define H59A0001X
         1 "1 C+P=N,FILER=PHARMACY"
         2 "2 C+P=N,FILER=NEITHER"
         3 "3 C+P=Y,FILER=UNK/INAP"
         4 "4 C+P=Y,FILER=FAMILY"
         5 "5 C+P=Y,FILER=PHARMACY,OM=2,3"
         6 "6 C+P=Y,FILER=NEITHER,OM=2,3" ;

label define H59A0002X
         0 "0 NO"
         1 "1 YES" ;

label define H59A0003X
         0 "0 NO"
         1 "1 YES" ;

label define H59A0004X
         1 "1 EXACT MATCH TO PC Rx FOR PID"
         2 "2 NOT EXACT MATCH TO PC Rx FOR PID" ;

label define H59A0005X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0006X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0007X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0008X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0009X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0010X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0011X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE"
         5 "5 ON-LINE" ;

label define H59A0012X
         1 "1"
         2 "2"
         3 "3"
         4 "4"
         5 "5" ;

label define H59A0013X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H59A0014X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H59A0015X
         -1 "-1 INAPPLICABLE"
         -14 "-14 NOT YET USED/TAKEN"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H59A0016X
         1 "1 NO IMPUTATION"
         2 "2 IMPUTED FROM OTHER PC RECORD"
         3 "3 IMPUTED FR SECONDARY SRC, BUT ORIG REPORTED" ;

label define H59A0017X
         0 "0 NO"
         1 "1 YES" ;

* ASSOCIATE VARIABLES WITH VALUE LABEL DEFINITIONS;
label value CLMOMFLG H59A0001X;
label value DIABFLG H59A0002X;
label value INPCFLG H59A0003X;
label value PCIMPFLG H59A0004X;
label value PHARTP1 H59A0005X;
label value PHARTP2 H59A0006X;
label value PHARTP3 H59A0007X;
label value PHARTP4 H59A0008X;
label value PHARTP5 H59A0009X;
label value PHARTP6 H59A0010X;
label value PHARTP7 H59A0011X;
label value PURCHRD H59A0012X;
label value RXBEGDD H59A0013X;
label value RXBEGMM H59A0014X;
label value RXBEGYR H59A0015X;
label value RXFLG H59A0016X;
label value SAMPLE H59A0017X;

*DISPLAY A DESCRIPTION OF STATA FILE;
describe;

*LIST FIRST 20 OBSERVATIONS IN THE FILE;
list in 1/20;

save $rawdir/prescribed_medicines/H59A, replace;

#delimit cr

* data file is stored in H59A.dta
* log  file is stored in H59A.log

log close

/************************************************************************************************
 NOTES:                                                                                          
                                                                                                 
 1. This program has been tested on Stata Version 10 (for Windows).                              
                                                                                                 
 2. This program will create a permanent Stata dataset.  All additional analyses                 
    can be run using this dataset.  In addition to the dataset, this program creates             
    a log file named H59A.LOG and a data file named H59A.DTA.  If these files (H59A.DTA and H59A.LOG)
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

