/************************************************************************************************/
/* Stata User File for H16A Data                                                                 */
/*                                                                                              */
/* This file contains information and a sample Stata program to create a permanent              */
/* Stata dataset for users who want to use Stata in processing the MEPS data provided           */
/* in this PUF release.  Stata (StataCorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the Medical Expenditure Panel Survey (MEPS).                                  */
/* The input file for creating a permanent Stata dataset is the ASCII data file                 */
/* (H16A.DAT) supplied in this PUF release, which in turn can be extracted from the              */
/* .EXE file. After entering the Stata interactive environment access the Stata DO-File         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  Copy and paste the following Stata commands into the editor and save as a           */
/* DO file.  A DO file is a Stata program which may then be executed using the DO command.      */
/* For example, if the DO file is named H16A.DO and is located in the directory                  */
/* C:\MEPS\PROG, then the file may be executed by typing the following command into             */
/* the Stata command line:                                                                      */
/*                         do C:\MEPS\PROG\H16A.DO                                               */
/* The program below will output the Stata dataset H16A.DTA                                      */
/************************************************************************************************/


#delimit ;

log using $logdir/H16A.log, replace;
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
  double RXQUANTY 144-150
  byte   RXFORM 151-152
  str    RXFORMOS 153-202
  str    RXSTRENG 203-214
  byte   RXUNIT 215-216
  str    RXUNITOS 217-266
  byte   PHARTP1 267-268
  byte   PHARTP2 269-270
  byte   PHARTP3 271-272
  byte   PHARTP4 273-274
  byte   PHARTP5 275-276
  byte   PHARTP6 277-278
  byte   PHARTP7 279-280
  byte   RXFLG 281-281
  byte   PCIMPFLG 282-282
  byte   SELFFLG 283-283
  byte   INPCFLG 284-284
  byte   DIABFLG 285-285
  byte   SAMPLE 286-286
  str    RXICD1X 287-289
  str    RXICD2X 290-292
  str    RXICD3X 293-295
  str    RXCCC1X 296-298
  str    RXCCC2X 299-301
  str    RXCCC3X 302-304
  byte   NUMCOND 305-306
  double RXSF97X 307-313
  double RXMR97X 314-320
  double RXMD97X 321-327
  double RXPV97X 328-334
  double RXVA97X 335-340
  double RXCH97X 341-346
  double RXOF97X 347-351
  double RXSL97X 352-357
  double RXWC97X 358-363
  double RXOT97X 364-369
  double RXOR97X 370-375
  double RXOU97X 376-381
  double RXXP97X 382-388
  double WTDPER97 389-400
  int    VARSTR97 401-403
  byte   VARPSU97 404-405
using $datadir/prescribed_medicines/H16A.dat;

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
label variable RXFORMOS "OTH SPEC FORM OF Rx/PRESCR MED (IMPUTED)";
label variable RXSTRENG "STRENGTH OF Rx/PRESCR MED DOSE (IMPUTED)";
label variable RXUNIT "UNIT OF MEAS Rx/PRESC MED DOSE (IMPUTED)";
label variable RXUNITOS "OTH SPEC UNIT MEAS Rx MED DOSE (IMPUTED)";
label variable PHARTP1 "TYPE OF PHARMACY PROV - 1ST";
label variable PHARTP2 "TYPE OF PHARMACY PROV - 2ND";
label variable PHARTP3 "TYPE OF PHARMACY PROV - 3RD";
label variable PHARTP4 "TYPE OF PHARMACY PROV - 4TH";
label variable PHARTP5 "TYPE OF PHARMACY PROV - 5TH";
label variable PHARTP6 "TYPE OF PHARMACY PROV - 6TH";
label variable PHARTP7 "TYPE OF PHARMACY PROV - 7TH";
label variable RXFLG "NDC IMPUTE SCE ON PC DONOR REC (IMPUTED)";
label variable PCIMPFLG "TYPE OF HC TO PC PRESCRIPTION MATCH";
label variable SELFFLG "EVENT IS A SELF-FILER EVENT";
label variable INPCFLG "PID HAS AT LEAST 1 RECORD IN PC";
label variable DIABFLG "Rx INSULIN OR DIABETIC EQUIPMENT/SUPPLY";
label variable SAMPLE "HOUSEHLD RCVD FREE SAMPLE OF Rx IN ROUND";
label variable RXICD1X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD2X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD3X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXCCC1X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC2X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC3X "MODIFIED CLINICAL CLASS CODE";
label variable NUMCOND "TOT # COND RECS LINK TO EVNT";
label variable RXSF97X "AMOUNT PAID, SELF OR FAMILY (IMPUTED)";
label variable RXMR97X "AMOUNT PAID, MEDICARE (IMPUTED)";
label variable RXMD97X "AMOUNT PAID, MEDICAID (IMPUTED)";
label variable RXPV97X "AMOUNT PAID, PRIVATE INSURANCE (IMPUTED)";
label variable RXVA97X "AMOUNT PAID, VETERANS (IMPUTED)";
label variable RXCH97X "AMOUNT PAID, CHAMPUS/CHAMPVA (IMPUTED)";
label variable RXOF97X "AMOUNT PAID, OTHER FEDERAL (IMPUTED)";
label variable RXSL97X "AMOUNT PAID, STATE & LOCAL GOV (IMPUTED)";
label variable RXWC97X "AMOUNT PAID, WORKERS COMP (IMPUTED)";
label variable RXOT97X "AMOUNT PAID, OTHER INSURANCE (IMPUTED)";
label variable RXOR97X "AMOUNT PAID, OTHER PRIVATE (IMPUTED)";
label variable RXOU97X "AMOUNT PAID, OTHER PUBLIC (IMPUTED)";
label variable RXXP97X "SUM OF PAYMENTS RXSF97X-RXOU97X(IMPUTED)";
label variable WTDPER97 "POVERTY/MORTALITY ADJUSTED PERS LEVL WGT";
label variable VARSTR97 "VARIANCE ESTIMATION STRATUM, 1997";
label variable VARPSU97 "VARIANCE ESTIMATION PSU, 1997";


*DEFINE VALUE LABELS FOR REPORTS;
label define H16A0001X
         0 "0 NO"
         1 "1 YES" ;

label define H16A0002X
         0 "0 NO"
         1 "1 YES" ;

label define H16A0003X
         0 "0"
         10 "10"
         11 "11"
         12 "12"
         13 "13"
         14 "14"
         15 "15"
         16 "16"
         4 "4"
         5 "5"
         6 "6"
         7 "7"
         8 "8"
         9 "9" ;

label define H16A0004X
         0 "0 NONE"
         1 "1 EXACT MATCH TO PC Rx FOR PID"
         2 "2 REFILL OF EXACT MATCH TO PC Rx FOR PID"
         3 "3 NOT EXACT MATCH TO PC Rx FOR PID" ;

label define H16A0005X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0006X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0007X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0008X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0009X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0010X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0011X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H16A0012X
         1 "1"
         2 "2"
         3 "3"
         4 "4"
         5 "5" ;

label define H16A0013X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H16A0014X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H16A0015X
         -1 "-1 INAPPLICABLE"
         -14 "-14 NOT YET USED/TAKEN"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         99 "99 HAS NOT YET TAKEN/USED" ;

label define H16A0016X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0017X
         1 "1 NO IMPUTATION"
         2 "2 IMPUTED FROM OTHER PC RECORD"
         3 "3 IMPUTED FR SECONDARY SRC, BUT ORIG REPORTED" ;

label define H16A0018X
         -7 "-7 REFUSED"
         -9 "-9 NOT ASCERTAINED"
         1 "1 PILLS"
         10 "10 PATCHES"
         11 "11 TOPICAL GEL/JELLY"
         12 "12 POWDER"
         13 "13 LANCETS"
         14 "14 GRAMS"
         15 "15 OUNCES"
         16 "16 SOLUTION"
         17 "17 TEST STRIPS"
         18 "18 SYRINGES"
         19 "19 NEBULIZER"
         2 "2 LIQUID"
         20 "20 Z-PAK"
         3 "3 DROPS"
         4 "4 TOPICAL OINTMENT"
         5 "5 SUPPOSITORIES"
         6 "6 AEROSOL/SPRAY,INHALANT"
         7 "7 SHAMPOO/SOAP"
         8 "8 INJECTION"
         9 "9 IV INJECTION"
         91 "91 OTHER SPECIFY" ;

label define H16A0019X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0020X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0021X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0022X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0023X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0024X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0025X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0026X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0027X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0028X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0029X
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MG"
         10 "10 MG/MCG"
         11 "11 MG/MG"
         12 "12 MG/HR"
         13 "13 MEG/ML"
         14 "14 MCG/ML"
         15 "15 U/GM"
         16 "16 U/ML"
         17 "17 IU"
         2 "2 MCG"
         3 "3 MEG"
         4 "4 MG/ML"
         5 "5 GM"
         6 "6 GR"
         7 "7 %"
         8 "8 ML"
         9 "9 COMPOUNDS"
         91 "91 OTHER SPECIFY" ;

label define H16A0030X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0031X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0032X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H16A0033X
         0 "0 NO"
         1 "1 YES" ;

label define H16A0034X
         0 "0 NON-SELF-FILER"
         1 "1 SELF-FILER" ;

* ASSOCIATE VARIABLES WITH VALUE LABEL DEFINITIONS;
label value DIABFLG H16A0001X;
label value INPCFLG H16A0002X;
label value NUMCOND H16A0003X;
label value PCIMPFLG H16A0004X;
label value PHARTP1 H16A0005X;
label value PHARTP2 H16A0006X;
label value PHARTP3 H16A0007X;
label value PHARTP4 H16A0008X;
label value PHARTP5 H16A0009X;
label value PHARTP6 H16A0010X;
label value PHARTP7 H16A0011X;
label value PURCHRD H16A0012X;
label value RXBEGDD H16A0013X;
label value RXBEGMM H16A0014X;
label value RXBEGYR H16A0015X;
label value RXCH97X H16A0016X;
label value RXFLG H16A0017X;
label value RXFORM H16A0018X;
label value RXMD97X H16A0019X;
label value RXMR97X H16A0020X;
label value RXOF97X H16A0021X;
label value RXOR97X H16A0022X;
label value RXOT97X H16A0023X;
label value RXOU97X H16A0024X;
label value RXPV97X H16A0025X;
label value RXQUANTY H16A0026X;
label value RXSF97X H16A0027X;
label value RXSL97X H16A0028X;
label value RXUNIT H16A0029X;
label value RXVA97X H16A0030X;
label value RXWC97X H16A0031X;
label value RXXP97X H16A0032X;
label value SAMPLE H16A0033X;
label value SELFFLG H16A0034X;

*DISPLAY A DESCRIPTION OF STATA FILE;
describe;

*LIST FIRST 20 OBSERVATIONS IN THE FILE;
list in 1/20;

save $rawdir/prescribed_medicines/H16A, replace;

#delimit cr

* data file is stored in H16A.dta
* log  file is stored in H16A.log

log close

/************************************************************************************************
 NOTES:                                                                                          
                                                                                                 
 1. This program has been tested on Stata Version 10 (for Windows).                              
                                                                                                 
 2. This program will create a permanent Stata dataset.  All additional analyses                 
    can be run using this dataset.  In addition to the dataset, this program creates             
    a log file named H16A.LOG and a data file named H16A.DTA.  If these files (H16A.DTA and H16A.LOG)
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

