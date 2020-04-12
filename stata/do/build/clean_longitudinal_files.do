/*******************************************************************************
Project: Effects of Job Displacement on Prescription Opiate Use: Evidence from 
		 the Medical Expenditure Panel Survey
Created by: Dustin Swonder
Last modified: 	04/12/2020
Description: This .do file prepares merged longitudinal data files for analysis
			 by reformatting variables of interest. It outputs a data file which
			 is ready to merge with Prescribed Medicines data files for 
			 analysis.
*******************************************************************************/

/*******************************************************************************
	ENVIRONMENT
*******************************************************************************/

capture log close
log using $logdir/clean_longitudinal_files.log, replace
clear

/*******************************************************************************
	LOAD IN DATA
*******************************************************************************/

use "$dtadir/merged_longitudinal.dta" // load in appended longitudinal data files
desc

*----------- CODE YEAR INDICATORS FOR PRIMARY YEARS OF PARTICIPATION ----------*

gen PRIMARY_YEAR = 1996
forv i = 1/21 {
	local yr = 1995 + `i'
	replace PRIMARY_YEAR = cond(YEARIND == 1 | YEARIND == 2, `yr', `yr' + 1) /*
					*/ if PANEL == `i'
}
label variable PRIMARY_YEAR "Primary year of participation in MEPS survey"
drop YEARIND

*--- COMPUTE PROPORTION OF FAMILY'S Y1 INCOME COMES FROM Y1 IND WAGE INCOME ---*

drop WAGEPY2 TTLPY2
replace WAGEPY1X = 0 if missing(WAGEPY1X) | WAGEPY1X < 0

preserve // get sums of total person-level inc at dwelling unit level

collapse (rawsum) FAMILYINC1 = TTLPY1X, by(DUID) 
tempfile familyinc
save `familyinc'

restore

merge m:1 DUID using `familyinc', assert(3) nogen
gen SHAREINCWAGES = cond(FAMILYINC1 == 0 | FAMILYINC1 < 0 | missing(FAMILYINC1), ., ///
	WAGEPY1X / FAMILYINC1)

label variable SHAREINCWAGES "Wages as share of family's Y1 income"
	
drop TTLPY1X WAGEPY1X FAMILYINC
	
*-- MAKE INDICATOR FOR WHETHER FAM HAD BIZ, DIVIDEND, OR TRUST INCOME IN Y1 ---*

foreach incomevar in BUSNPY1X DIVDPY1X TRSTPY1X {
	replace `incomevar' = 0 if missing(`incomevar') | `incomevar' < 0
}

egen totalbiztrustinc = rowtotal(BUSNPY1X DIVDPY1X TRSTPY1X)

preserve

collapse (sum) fambiztrustinc = totalbiztrustinc, by(DUID)
tempfile fambizinc
save `fambizinc'

restore

merge m:1 DUID using `fambizinc', assert(3) nogen

gen IND_BIZTRST = totalbiztrustinc > 0
gen FAM_BIZTRST = fambiztrustinc > 0

label variable IND_BIZTRST "Ind. has biz/trust inc."
label variable FAM_BIZTRST "Family has biz/trust inc."

drop BUSNPY?X DIVDPY?X TRSTPY?X totalbiztrustinc fambiztrustinc
	
*----------------- CODE NEGATIVE VALUES OF REGION TO MISSING ------------------*

replace REGION = . if REGION < 0
label define new_region_labels 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label values REGION new_region_labels


*-------------------------- RECODE SEX AS INDICATOR ---------------------------*

recode SEX (2 = 0)
label define new_sex_labels 0 "Female" 1 "Male"
label values SEX new_sex_labels

*-------------------- RECONCILE OLD AND NEW RACE VARIABLES --------------------*
	
/* In loaded-in data, 3 versions of race var: two named RACEX and one RACEV1X. 
	First (RACEX) applies to panels 1-5; second (RACEX) applies to panels 6-15; 
	final (RACEV1X) applies to panels 16-20 -- same as taxonomy from 6-15, just 
	different variable name. Mainly use variable name & taxonomy for panels, but
	combine Asian, Native Hawaiian, and Pacific Islander categories. */

* Create new label for RACEX values
label define new_race_labels 1 "White" 2 "Black" 3 "American Indian/Alaska Native" ///
	4 "Asian/Pacific Islander" 6 "Multiple races" -1 "Inapplicable"
label values RACEX new_race_labels

* Reconcile first and last schemes with scheme for panels 6-15 
replace RACEX = cond(RACEX == 1 | RACEX == 2, 3, /*
				*/ cond(RACEX == 3, 4, /* 
				*/ cond(RACEX == 4, 2, /*
				*/ cond(RACEX == 5, 1, -1)))) if PANEL < 6
replace RACEX = RACEV1X if PANEL > 15
drop RACEV1X

* Merge Asian/Pacific Islander categories for panels 6-20
replace RACEX = 4 if RACEX == 5 & PANEL > 5

*------------- RECODE HISPANIC CATEGORIZATION VAR AS 0-1 INDICATOR ------------*

recode HISPANX (2 = 0) 
label define new_hisp_labels 0 "Not Hispanic" 1 "Hispanic"
label values HISPANX new_hisp_labels

*------------------ SIMPLIFY CODING OF MARRIAGE VARIABLE ----------------------*

recode MARRY1X (-9 -8 -7 -3 -1 6 = .) (1 7 = 1) (2 3 4 8 9 10 = 2) (5 = 3)
label define new_marriage_labels 1 "Married" 2 "Widowed/divorced/separated" 3 "Never married"
label values MARRY1X new_marriage_labels
				 
*----------------- RECONCILE OLD AND NEW EDUCATION VARIABLES ------------------*
	
/*	For panels 1,2, use HIDEG1 (highest degree of education in round one of 
	interviews). For panels 3-8, this is captured by HIDEGYR. For panels 9-16 
	and 20, this is captured by HIDEG. For panels 17-20, we rely on the EDRECODE 
	variable.  The EDRECODE variable gives hybrid between years of education and
	highest degree. */

* Create new label for HIDEG values
label define new_ed_labels 1 "No degree" 2 "GED or HS diploma" 4 "Four-year degree" 5 "Master's, doctoral, or professional degree" 7 "Other degree" -1 "Inapplicable" -3 "Missing" -9 "Not ascertained" -8 "DK" -7 "Refused"
label values HIDEG new_ed_labels
	
* Store highest degree info in same var for panels 1-9
replace HIDEG = cond(PANEL < 3, HIDEG1, HIDEGYR) if PANEL < 9
drop HIDEG? HIDEGY*

* Consolidate HIDEG categories so as to be compatible with EDRECODE coding
recode HIDEG (2 3 = 2) (6 = 5) (8 -9 -8 -7 -3 -1 = .)

* Assign individuals to HIDEG categories based on the EDRECODE information
replace HIDEG = cond(EDRECODE == 1 | EDRECODE == 2, 1, /*
				*/ cond(EDRECODE == 13 | EDRECODE == 14, 2, /*
				*/ cond(EDRECODE == 15, 4, cond(EDRECODE == 16, 5, EDRECODE)))) /*
					*/ if PANEL > 16 & PANEL < 20
drop EDRECODE
				
*------------------- CREATE INDICATORS FOR JOB DISPLACEMENT -------------------*
				
/*	I categorize an individual as having been laid of in round n if they change
	jobs between rounds n and n + 1 because (1) they were laid off (2) their 
	business dissolved or was closed or (3) their job ended. */
	
forval i = 1/4 {
	local j = `i' + 1
	gen LAIDOFF`i' = cond(missing(YCHJ`i'`j') | YCHJ`i'`j' == -3, ., /*
						*/ YCHJ`i'`j' == 5)
	label variable LAIDOFF`i' "Laid off in round `i'"

	gen BIZDISSLD`i' = cond(missing(YCHJ`i'`j') | YCHJ`i'`j' == -3, ., /*
								*/ YCHJ`i'`j' == 2)
	label variable BIZDISSLD`i' "Bus. dissolved or sold in round `i'"
 
	gen NONLAYOFFDISPL`i' = cond(missing(YCHJ`i'`j') | YCHJ`i'`j' == -3, ., /*
								*/ YCHJ`i'`j' == 1 | YCHJ`i'`j' == 2)
	label variable NONLAYOFFDISPL`i' "Bus. dissolved or sold/job ended in round `i'"

	gen DISPLACED`i' = cond(missing(YCHJ`i'`j') | YCHJ`i'`j' == -3, ., /*
							*/ LAIDOFF`i' == 1 | NONLAYOFFDISPL`i' == 1)
	label variable DISPLACED`i' "Displaced in round `i'"
	drop YCHJ`i'`j'
}

/* If individual is missing YCHJ variable, is missing YCHJ12 or YCHJ23 or both; 
	no missing values for YCHJ34 or YCHJ45 */
foreach designation in LAIDOFF NONLAYOFFDISPL DISPLACED BIZDISSLD {
	gen EVER`designation' = cond(missing(`designation'1) & missing(`designation'2), /*
						*/ `designation'3 + `designation'4 > 0, /*
					*/ cond(missing(`designation'1), /*
						*/ `designation'2 + `designation'3 + `designation'4 > 0, /*
					*/ cond(missing(`designation'2), /*
						*/ `designation'1 + `designation'3 + `designation'4 > 0, /*
					*/ `designation'1 + `designation'2 + `designation'3 + `designation'4 > 0)))
}

label variable EVERLAIDOFF "Displaced due to layoff"
label variable EVERBIZDISSLD "Displaced b/c bus. dissolved or sold"
label variable EVERNONLAYOFFDISPL "Displaced b/c bus. dissolved or sold/job ended"
label variable EVERDISPLACED "Displaced"

*------- COUNT HOW MANY PERIODS WERE SPENT WITHOUT WORKING WHOLE TIME ---------*

forv i = 1/5 {
	tempvar nowork`i'
	gen `nowork`i'' = EMPST`i' == 4
}

egen RDSNOWRK = rowtotal(`nowork1' `nowork2' `nowork3' `nowork4' `nowork5')

*---------------------- REFORMAT HEALTH STATUS VARIABLES ----------------------*

/*	Recode health limitation variables as indicators for having a health 
	limitation in a round, then use these round-specific indicators to create 
	indicators for whether an individual ever experienced a health condition 
	during their participation in the survey. */	

* QUESTIONS ASKED IN ROUNDS 2 & 4
	
/* Indicators for ADCLIM, ADDAYA are only one if the individual reported being
	"limited a lot." "Limited a little" and "not limited" both correspond
	to zero. ADILCR and ADSPEC a yes/no variable already with one corresponding 
	to yes and zero corresponding to no. */
foreach variable in ADCLIM ADDAYA ADILCR ADSPEC {
	forval i = 2(2)4 {
		gen I_`variable'`i' = cond(missing(`variable'`i') /*
									*/ | `variable'`i' == -3, ., /*
								*/ cond(`variable'`i' != 1, 0, 1))
	}
}

/* I classify an individual as having a high risk preference (I_ADRISK2,4 == 1)
	if they "Agree somewhat" or "Agree strongly" with the statement that they 
	are more likely to take risks than other people. */
forval i = 2(2)4 {
	gen I_ADRISK`i' = cond(missing(ADRISK`i') | `variable'`i' == -3, ., /*
						*/ cond(ADRISK`i' == 4 | ADRISK`i' == 5, 1, 0))
}

/* I classify an individual as having been prevented from participating in 
	social activities by physical health or emotional problems 
	(I_ADSOCA2,4 == 1) if they report having been prevented "some of the time," 
	"most of the time," or "all of the time." */
forval i = 2(2)4 {
	gen I_ADSOCA`i' = cond(missing(ADSOCA`i') | `variable'`i' == -3, ., /*
						*/ cond(ADSOCA`i' > 0 & ADSOCA`i' < 4, 1, 0))
}

/* For all variables available only in rounds two and four, create indicators for
	whether survey participants ever experienced difficulties described in 
	questions corresponding to these variables. */
foreach variable in ADCLIM ADDAYA ADILCR ADSPEC ADRISK ADSOCA {
	gen EVER`variable' = cond(missing(`variable'2) & missing(`variable'4), ., /*
							*/ cond(missing(`variable'2), I_`variable'4 > 0, /*
							*/ cond(missing(`variable'4), I_`variable'2 > 0, /*
								*/ I_`variable'2 + I_`variable'4 > 0)))
	drop `variable'2 `variable'4 I_`variable'2 I_`variable'4
}

label variable EVERADCLIM "Ever reported limitations climbing stairs"
label variable EVERADDAYA "Ever reported difficulty performing moderate activities"
label variable EVERADILCR "Ever reported experiencing illness/inj. requiring immed. care"
label variable EVERADSPEC "Ever reported illness/inj. requiring specialist attention"
label variable EVERADRISK "Ever reported more likely to take risks than average"
label variable EVERADSOCA "Ever reported health impeding social life"

/* QUESTIONS ASKED IN ROUNDS 3 & 5
	All three of ASPRIN HYSTER JTPAIN are yes/no variables, so I map yes/no onto
	one and zero, respectively. */
foreach variable in ASPRIN HYSTER {
	forval i = 3(2)5 {
		gen I_`variable'`i' = cond(missing(`variable'`i') /*
										*/ | `variable'`i' == -3, ., /*
								*/ cond(`variable'`i' != 1, 0, 1))
	}
}

foreach variable in ASPRIN HYSTER {
	gen EVER`variable' = cond(missing(`variable'3) & missing(`variable'5), ., /*
							*/ cond(missing(`variable'3), I_`variable'5 > 0, /*
							*/ cond(missing(`variable'5), I_`variable'3 > 0, /*
								*/ I_`variable'3 + I_`variable'5 > 0)))
	drop `variable'3 `variable'5 I_`variable'3 I_`variable'5
}

label variable EVERASPRIN "Ever reported taking aspirin daily"
label variable EVERHYSTER "Ever reported undergoing hysterectomy"

* QUESTIONS ASKED IN ROUNDS 1, 3 & 5

/* AIDHLP, UNABLE, WLKLIM, and WRKLIM are all yes/no variables, so I map yes/no 
	onto one and zero, respectively */
foreach variable in AIDHLP UNABLE WLKLIM WRKLIM JTPAIN {
	forval i = 1(2)5 {
		gen I_`variable'`i' = cond(missing(`variable'`i') /*
										*/ | `variable'`i' == -3, ., /*
								*/ cond(`variable'`i' != 1, 0, 1))
	}
}

/* All the physical difficulty questions are coded on a four-point scale, with 
	3 and 4 (corresponding to "a lot of difficulty" or "unable to do [physical 
	activity]") mapping onto 1 in my indicator scale. */
foreach variable in BENDIF FNGRDF MILDIF RCHDIF STNDIF WLKDIF {
	forval i = 1(2)5 {
		gen I_`variable'`i' = cond(missing(`variable'`i') /*
										*/ | `variable'`i' == -3, ., /*
								*/ cond(`variable'`i' < 2, 0, 1))
	}
}

* Create an indicator for whether individiauls ever felt pain in first round
gen R1PAIN = I_AIDHLP1 == 1 | I_UNABLE1 == 1 | I_WLKLIM1 == 1 | I_WRKLIM1 == 1 | /*
			*/ I_JTPAIN1 == 1 | I_BENDIF1 == 1 | I_FNGRDF1 == 1 | I_MILDIF1 == 1 | /*
			*/ I_RCHDIF1 == 1 | I_STNDIF1 == 1 | I_WLKDIF1 == 1
			
foreach variable in AIDHLP UNABLE WLKLIM WRKLIM JTPAIN BENDIF FNGRDF MILDIF RCHDIF STNDIF WLKDIF {
	gen EVER`variable' = cond(missing(`variable'1) & missing(`variable'3) & missing(`variable'5), ., /*
				*/ cond(missing(`variable'1) & missing(`variable'3), I_`variable'5 > 0, /*
				*/ cond(missing(`variable'1) & missing(`variable'5), I_`variable'3 > 0, /*
				*/ cond(missing(`variable'3) & missing(`variable'5), I_`variable'1 > 0, /*
				*/ cond(missing(`variable'1), I_`variable'3 + I_`variable'5 > 0, /*
				*/ cond(missing(`variable'3), I_`variable'1 + I_`variable'5 > 0, /*
				*/ cond(missing(`variable'5), I_`variable'1 + I_`variable'3 > 0, /*
					*/ I_`variable'1 + I_`variable'3 + I_`variable'5 > 0)))))))
	drop `variable'1 `variable'3 `variable'5 I_`variable'1 I_`variable'3 I_`variable'5
}
			
label variable R1PAIN "Reported physical pain in round one of interviews"

label variable EVERAIDHLP "Ever reported using assistive device"
label variable EVERUNABLE "Ever reported complete inability to do activity"
label variable EVERWLKLIM "Ever reported general phys. difficulty"
label variable EVERWRKLIM "Ever reported phys. difficulty impeding work"
label variable EVERJTPAIN "Ever reported joint pain"
label variable EVERBENDIF "Ever reported difficulty bending/stooping"
label variable EVERFNGRDF "Ever reported difficulty grasping w/ fingers"
label variable EVERMILDIF "Ever reported difficulty walking mile"
label variable EVERRCHDIF "Ever reported difficulty reaching overhead"
label variable EVERSTNDIF "Ever reported difficulty standing 20 mins"
label variable EVERWLKDIF "Ever reported difficulty walking 3 blks"

* Reformat mental health variable to be indicator for fair or poor mental health
gen BADMNTLHLTH1 = cond(MNHLTH1 > 3 & !missing(MNHLTH1), 1, /*
		*/ cond(!missing(MNHLTH1) & MNHLTH1 != -3, 0, .))
drop MNHLTH1 MNHLTH2 MNHLTH3 MNHLTH4 MNHLTH5

label variable BADMNTLHLTH1 "Reported fair/poor mental health in R1"

/* Create indicator for whether individual spent a night as an inpatient in 
	hospital */
gen EVERIPNGTD = cond(missing(IPNGTDY1) & missing(IPNGTDY2), ., /*
					*/ cond(IPNGTDY1 < 0 & IPNGTDY2 < 0, 0, /*
					*/ cond(missing(IPNGTDY1) | IPNGTDY1 < 0, IPNGTDY2 > 0, /*
					*/ cond(missing(IPNGTDY2) | IPNGTDY2 < 0, IPNGTDY1 > 0, /*
						*/ IPNGTDY1 + IPNGTDY2 > 0))))
drop IPNGTDY1 IPNGTDY2
label variable EVERIPNGTD "Ever spent night inpatient in hospital"
	
/* Create indicator for whether individual ever missed work due to injury/illness;
	use DDNWRK variable, which is stored for each round for all panels except 
	panel 20, for which DDNWRK is stored for each year of survey participation */
gen EVERDDNWRK = cond(PANEL == 20 | PANEL == 21, /*
				*/ cond(missing(DDNWRKY1) & missing(DDNWRKY2), ., /*
				*/ cond(DDNWRKY1 < 0 & DDNWRKY2 < 0, 0, /*
				*/ cond(missing(DDNWRKY1) | DDNWRKY1 < 0, DDNWRKY2 > 0, /*
				*/ cond(missing(DDNWRKY2) | DDNWRKY2 < 0, DDNWRKY1 > 0, /*
					*/ DDNWRKY1 + DDNWRKY2 > 0)))), /*
		*/ cond(missing(DDNWRK1) & missing(DDNWRK2) & missing(DDNWRK3) & /*
				*/ missing(DDNWRK4) & missing(DDNWRK5), ., /*
			*/ cond(DDNWRK1 < 0 & DDNWRK2 < 0 & DDNWRK3 < 0 & /*
				*/ DDNWRK4 < 0 & DDNWRK5 < 0, 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0), DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK4 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK3 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK2 > 0, /*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK1 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0), DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0), DDNWRK3 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0), DDNWRK2 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0), DDNWRK1 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK3 + DDNWRK4 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK2 + DDNWRK4 > 0,/*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK1 + DDNWRK4 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK2 + DDNWRK3 > 0, /*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK1 + DDNWRK3 > 0,/*
			*/ cond((missing(DDNWRK3) | DDNWRK3 < 0) & /*
				*/ (missing(DDNWRK4) | DDNWRK4 < 0) & /*
				*/ (missing(DDNWRK5) | DDNWRK5 < 0), DDNWRK1 + DDNWRK2 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & (missing(DDNWRK2) | DDNWRK2 < 0), /*
				*/ DDNWRK3 + DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & (missing(DDNWRK3) | DDNWRK3 < 0), /*
				*/ DDNWRK2 + DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & (missing(DDNWRK4) | DDNWRK4 < 0), /*
				*/ DDNWRK2 + DDNWRK3 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & (missing(DDNWRK4) | DDNWRK4 < 0), /*
				*/ DDNWRK1 + DDNWRK3 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK3) | DDNWRK3 < 0) & (missing(DDNWRK4) | DDNWRK4 < 0), /*
				*/ DDNWRK1 + DDNWRK2 + DDNWRK5 > 0, /*
			*/ cond((missing(DDNWRK1) | DDNWRK1 < 0) & (missing(DDNWRK5) | DDNWRK5 < 0), /*
				*/ DDNWRK2 + DDNWRK3 + DDNWRK4 > 0, /*
			*/ cond((missing(DDNWRK2) | DDNWRK2 < 0) & (missing(DDNWRK5) | DDNWRK5 < 0), /*
				*/ DDNWRK1 + DDNWRK3 + DDNWRK4 > 0,/*
			*/ cond((missing(DDNWRK3) | DDNWRK3 < 0) & (missing(DDNWRK5) | DDNWRK5 < 0), /*
				*/ DDNWRK1 + DDNWRK2 + DDNWRK4 > 0, /*
			*/ cond((missing(DDNWRK4) | DDNWRK4 < 0) & (missing(DDNWRK5) | DDNWRK5 < 0), /*
				*/ DDNWRK1 + DDNWRK2 + DDNWRK3 > 0, /*
			*/ cond(missing(DDNWRK1) | DDNWRK1 < 0, DDNWRK2 + DDNWRK3 + DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond(missing(DDNWRK2) | DDNWRK2 < 0, DDNWRK1 + DDNWRK3 + DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond(missing(DDNWRK3) | DDNWRK3 < 0, DDNWRK1 + DDNWRK2 + DDNWRK4 + DDNWRK5 > 0, /*
			*/ cond(missing(DDNWRK4) | DDNWRK4 < 0, DDNWRK1 + DDNWRK2 + DDNWRK3 + DDNWRK5 > 0, /*
			*/ cond(missing(DDNWRK5) | DDNWRK5 < 0, DDNWRK1 + DDNWRK2 + DDNWRK3 + DDNWRK4 > 0, /*
				*/ DDNWRK1 + DDNWRK2 + DDNWRK3 + DDNWRK4 + DDNWRK5 > 0))))))))))))))))))))))))))))))))
drop DDNWRK*

label variable EVERDDNWRK "Ever missed work b/c illness/inj."
						
*---------- RECONCILE OLD AND NEW INDUSTRY AND OCCUPATION VARIABLES -----------*
		
/*	Information regarding industry and occupation are encapsulated in CIND and 
	COCCP variables for individuals in panels 1-6; for other panels, information 
	is encapsulated in INDCAT and OCCCAT variables. Need to reformat values
	stored in CIND and COCCP variables to match taxonomy in later variables. 
	Only interested in round 1 industry and occupation. */
	
replace CIND1 = cond(CIND1 == 5, 6, cond(CIND1 == 6, 5, /*
			  */ cond(CIND1 == 7, 8, cond(CIND1 == 8 | CIND1 == 9, 12, /*
			  */ cond(CIND1 == 10, 11, cond(CIND1 == 11, 9, /*
			  */ cond(CIND1 == 12, 13, CIND1))))))) if PANEL < 7
replace COCCP1 = cond(COCCP1 == 1, 2, cond(COCCP1 == 2, 1, /*
				*/cond(COCCP1 == 3, 4, cond(COCCP1 == 4, 5, /*
				*/cond(COCCP1 == 5, 7, cond(COCCP1 == 6 | COCCP1 == 7 | /*
											*/ COCCP1 == 9, 8, /*
				*/cond(COCCP1 == 8, 3, cond(COCCP1 == 10 | COCCP1 == 11, 6, /*
				*/cond(COCCP1 == 13, 9, COCCP1))))))))) if PANEL < 7
				
replace CIND1 = INDCAT1 if PANEL > 6
copydesc INDCAT1 CIND1
replace COCCP1 = OCCCAT1 if PANEL > 6
copydesc OCCCAT1 COCCP1

drop INDCAT1 OCCCAT1

replace COCCP1 = -9 if inlist(COCCP1, 11, 12) // standardize unknown category as -9

drop __000* // drop tempvar residue

sort PANEL DUPERSID

* Save clean longitudinal files
save "$dtadir/clean_longitudinal.dta", replace

log close