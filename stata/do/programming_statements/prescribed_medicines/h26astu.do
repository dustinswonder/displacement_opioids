/************************************************************************************************/
/* Stata User File for H26A Data                                                                 */
/*                                                                                              */
/* This file contains information and a sample Stata program to create a permanent              */
/* Stata dataset for users who want to use Stata in processing the MEPS data provided           */
/* in this PUF release.  Stata (StataCorp) has the capability to produce                        */
/* appropriate standard errors for estimates from a survey with a complex sample                */
/* design such as the Medical Expenditure Panel Survey (MEPS).                                  */
/* The input file for creating a permanent Stata dataset is the ASCII data file                 */
/* (H26A.DAT) supplied in this PUF release, which in turn can be extracted from the              */
/* .EXE file. After entering the Stata interactive environment access the Stata DO-File         */
/* editor by clicking on the appropriate icon in the command line at the top of the             */
/* screen.  Copy and paste the following Stata commands into the editor and save as a           */
/* DO file.  A DO file is a Stata program which may then be executed using the DO command.      */
/* For example, if the DO file is named H26A.DO and is located in the directory                  */
/* C:\MEPS\PROG, then the file may be executed by typing the following command into             */
/* the Stata command line:                                                                      */
/*                         do C:\MEPS\PROG\H26A.DO                                               */
/* The program below will output the Stata dataset H26A.DTA                                      */
/************************************************************************************************/


#delimit ;

log using $logdir/H26A.log, replace;
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
  str    RXFORM 151-200
  str    RXSTRENG 201-212
  byte   RXUNIT 213-214
  str    RXUNITOS 215-264
  byte   PHARTP1 265-266
  byte   PHARTP2 267-268
  byte   PHARTP3 269-270
  byte   PHARTP4 271-272
  byte   PHARTP5 273-274
  byte   PHARTP6 275-276
  byte   PHARTP7 277-278
  byte   RXFLG 279-279
  byte   PCIMPFLG 280-280
  byte   SELFFLG 281-281
  byte   INPCFLG 282-282
  byte   SAMPLE 283-283
  str    RXICD1X 284-286
  str    RXICD2X 287-289
  str    RXICD3X 290-292
  str    RXCCC1X 293-295
  str    RXCCC2X 296-298
  str    RXCCC3X 299-301
  double RXSF98X 302-308
  double RXMR98X 309-314
  double RXMD98X 315-320
  double RXPV98X 321-327
  double RXVA98X 328-333
  double RXCH98X 334-339
  double RXOF98X 340-345
  double RXSL98X 346-351
  double RXWC98X 352-357
  double RXOT98X 358-363
  double RXOR98X 364-369
  double RXOU98X 370-374
  double RXXP98X 375-381
  double WTDPER98 382-393
  int    VARSTR98 394-396
  byte   VARPSU98 397-398
using $datadir/prescribed_medicines/H26A.dat;

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
label variable RXFLG "NDC IMPUTATION SOURCE ON PC DONOR REC";
label variable PCIMPFLG "TYPE OF HC TO PC PRESCRIPTION MATCH";
label variable SELFFLG "EVENT IS A SELF-FILER EVENT";
label variable INPCFLG "PID HAS AT LEAST 1 RECORD IN PC";
label variable SAMPLE "HOUSEHLD RCVD FREE SAMPLE OF Rx IN ROUND";
label variable RXICD1X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD2X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXICD3X "3 DIGIT ICD-9 CONDITION CODE";
label variable RXCCC1X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC2X "MODIFIED CLINICAL CLASS CODE";
label variable RXCCC3X "MODIFIED CLINICAL CLASS CODE";
label variable RXSF98X "AMOUNT PAID, SELF OR FAMILY (IMPUTED)";
label variable RXMR98X "AMOUNT PAID, MEDICARE (IMPUTED)";
label variable RXMD98X "AMOUNT PAID, MEDICAID (IMPUTED)";
label variable RXPV98X "AMOUNT PAID, PRIVATE INSURANCE (IMPUTED)";
label variable RXVA98X "AMOUNT PAID, VETERANS (IMPUTED)";
label variable RXCH98X "AMOUNT PAID, CHAMPUS/CHAMPVA (IMPUTED)";
label variable RXOF98X "AMOUNT PAID, OTHER FEDERAL (IMPUTED)";
label variable RXSL98X "AMOUNT PAID, STATE & LOCAL GOV (IMPUTED)";
label variable RXWC98X "AMOUNT PAID, WORKERS COMP (IMPUTED)";
label variable RXOT98X "AMOUNT PAID, OTHER INSURANCE (IMPUTED)";
label variable RXOR98X "AMOUNT PAID, OTHER PRIVATE (IMPUTED)";
label variable RXOU98X "AMOUNT PAID, OTHER PUBLIC (IMPUTED)";
label variable RXXP98X "SUM OF PAYMENTS RXSF98X-RXOU98X(IMPUTED)";
label variable WTDPER98 "POVERTY/MORTALITY/NH ADJ PERS LVL WGT 98";
label variable VARSTR98 "VARIANCE ESTIMATION STRATUM, 1998";
label variable VARPSU98 "VARIANCE ESTIMATION PSU, 1998";


*DEFINE VALUE LABELS FOR REPORTS;
label define H26A0001X
         0 "0 NO"
         1 "1 YES" ;

label define H26A0002X
         0 "0 NONE"
         1 "1 EXACT MATCH TO PC Rx FOR PID"
         2 "2 REFILL OF EXACT MATCH TO PC Rx FOR PID"
         3 "3 NOT EXACT MATCH TO PC Rx FOR PID" ;

label define H26A0003X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0004X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0005X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0006X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0007X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0008X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0009X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         1 "1 MAIL-ORDER"
         2 "2 IN ANOTHER STORE"
         3 "3 IN HMO/CLINIC/HOSPITAL"
         4 "4 DRUG STORE" ;

label define H26A0010X
         1 "1"
         2 "2"
         3 "3"
         4 "4"
         5 "5" ;

label define H26A0011X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H26A0012X
         -1 "-1 INAPPLICABLE"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED" ;

label define H26A0013X
         -1 "-1 INAPPLICABLE"
         -14 "-14 NOT YET USED/TAKEN"
         -7 "-7 REFUSED"
         -8 "-8 DK"
         -9 "-9 NOT ASCERTAINED"
         99 "99 HAS NOT YET TAKEN/USED" ;

label define H26A0014X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0015X
         1 "1 NO IMPUTATION"
         2 "2 IMPUTED FROM OTHER PC RECORD"
         3 "3 IMPUTED FR SECONDARY SRC, BUT ORIG REPORTED" ;

label define H26A0016X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0017X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0018X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0019X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0020X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0021X
         -9 "-9 NOT ASCERTAINED"
         0 "0";
*         34.65 "$34.65 - $34.65" ;

label define H26A0022X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0023X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0024X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0025X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0026X
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

label define H26A0027X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0028X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0029X
         -9 "-9 NOT ASCERTAINED"
         0 "0" ;

label define H26A0030X
         0 "0 NO"
         1 "1 YES" ;

label define H26A0031X
         0 "0 NON-SELF-FILER"
         1 "1 SELF-FILER" ;

* ASSOCIATE VARIABLES WITH VALUE LABEL DEFINITIONS;
label value INPCFLG H26A0001X;
label value PCIMPFLG H26A0002X;
label value PHARTP1 H26A0003X;
label value PHARTP2 H26A0004X;
label value PHARTP3 H26A0005X;
label value PHARTP4 H26A0006X;
label value PHARTP5 H26A0007X;
label value PHARTP6 H26A0008X;
label value PHARTP7 H26A0009X;
label value PURCHRD H26A0010X;
label value RXBEGDD H26A0011X;
label value RXBEGMM H26A0012X;
label value RXBEGYR H26A0013X;
label value RXCH98X H26A0014X;
label value RXFLG H26A0015X;
label value RXMD98X H26A0016X;
label value RXMR98X H26A0017X;
label value RXOF98X H26A0018X;
label value RXOR98X H26A0019X;
label value RXOT98X H26A0020X;
label value RXOU98X H26A0021X;
label value RXPV98X H26A0022X;
label value RXQUANTY H26A0023X;
label value RXSF98X H26A0024X;
label value RXSL98X H26A0025X;
label value RXUNIT H26A0026X;
label value RXVA98X H26A0027X;
label value RXWC98X H26A0028X;
label value RXXP98X H26A0029X;
label value SAMPLE H26A0030X;
label value SELFFLG H26A0031X;

*DISPLAY A DESCRIPTION OF STATA FILE;
describe;

*LIST FIRST 20 OBSERVATIONS IN THE FILE;
list in 1/20;

save $rawdir/prescribed_medicines/H26A, replace;

#delimit cr

* data file is stored in H26A.dta
* log  file is stored in H26A.log

log close

/************************************************************************************************
 NOTES:                                                                                          
                                                                                                 
 1. This program has been tested on Stata Version 10 (for Windows).                              
                                                                                                 
 2. This program will create a permanent Stata dataset.  All additional analyses                 
    can be run using this dataset.  In addition to the dataset, this program creates             
    a log file named H26A.LOG and a data file named H26A.DTA.  If these files (H26A.DTA and H26A.LOG)
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

