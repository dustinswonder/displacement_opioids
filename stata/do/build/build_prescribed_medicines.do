/*******************************************************************************
Project: Effects of Job Displacement on Prescription Opiate Use: Evidence from 
		 the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	01/25/2020
Description: This .do file appends Prescribed Medicines files across years, 
			 giving a pool of all prescription records ever prescribed to MEPS 
			 survey participants from 1996-2017. The records are cleaned as 
			 well, so that the output .dta file is ready to merge with clean,
			 appended longitudinal data for analysis.
*******************************************************************************/

/*******************************************************************************
***	(0) PRELIMINARIES: START A LOG FILE, LOAD IN FILES WHICH NEED TO BE SAVED **
*******	AS DTA OR TEMPFILE *****************************************************
*******************************************************************************/

capture log close
clear all

/*******************************************************************************
	(0.1) RUN STATA PROGRAMMING STATEMENTS TO GET RAW PRESCRIBED MEDICINES FILES 
		IN .DTA FORMAT
*******************************************************************************/

local year = 1996

foreach file_num in 10 16 26 33 51 59 67 77 85 94 102 110 118 126 135 144 152 ///
	160 168 178 188 197 {

	quietly do $dodir/programming_statements/prescribed_medicines/h`file_num'astu.do
	qui save $rawdir/prescribed_medicines/Prescribed_Medicines_`year'.dta, replace
	qui rm $rawdir/prescribed_medicines/H`file_num'a.dta

	local year = `year' + 1
}

/*******************************************************************************
	(0.2) RUN STATA PROGRAMMING STATEMENTS TO GET RAW MULTUM LEXICON  
		SUPPLEMENTARY FILES IN .DTA FORMAT

	Multum Lexicon, a private firm, classifies prescriptions by their 
	therapeutic categories in MEPS Prescribed Medicines datasets. Therapeutic 
	category variables are out-of-date or absent from MEPS Prescribed Medicines 
	files 1996-2013 as downloaded directly from website; supplemental files are 
	provided to merge with Prescribed Medicines files to give accurate 
	therapeutic categories.
*******************************************************************************/

local year = 1996

forvalues i = 1/18 {
	quietly do $dodir/programming_statements/multum_lexicon/h68f`i'stu.do
	qui save $rawdir/multum_lexicon/ML_supplementary_`year'.dta, replace
	qui rm $rawdir/multum_lexicon/H68F`i'.dta

	local year = `year' + 1
}

/*******************************************************************************
	(0.3) RUN STATA PROGRAMMING STATEMENTS TO GET RAW FULL YEAR CONSOLIDATED  
		SUPPLEMENTARY FILES IN .DTA FORMAT
*******************************************************************************/

local year = 1996

foreach file_num in 12 20 28 38 50 60 70 79 89 {
	quietly do $dodir/programming_statements/full_year_consolidated/h`file_num'stu.do
	qui save $rawdir/full_year_consolidated/Full_Year_Consolidated_`year'.dta, replace
	qui rm $rawdir/full_year_consolidated/H`file_num'.dta

	local year = `year' + 1
}

/*******************************************************************************
	(0.4) SAVE SPREADSHEET OF INCORRECTLY SPELLED/PROPRIETARY OPIOID NAMES  
		STORED IN RXNAME, THEIR CORRECT NAMES, AND THE OPIOID COMPONENTS 
		THEREOF AS .DTA FILE
*******************************************************************************/

import excel using "$datadir/opioidlist.xlsx", firstrow clear

sort RXNAME
rename OPIATE_COMPONENT OPD_COMPONENT_rxname

keep RXNAME NONPROPRIETARYNAME OPD_COMPONENT_rxname

save "$dtadir/opioidlist.dta", replace

/*******************************************************************************
	(0.5) SAVE SPREADSHEET OF NATIONAL DRUG CODES AND OPIOID NAMES TO MERGE ONTO 
		PRESCRIBED MEDICINES RECORDS IN ORDER TO VERIFY DRUG NAMES
*******************************************************************************/
	 
import excel using "$datadir/CDC_Oral_Morphine_Milligram_Equivalents_Sept_2018.xlsx", /* 
	 */ firstrow case(upper) sheet("Opioids") clear
	 
rename NDC RXNDC
drop NDC_NUMERIC

gen NONPROPRIETARYNAME_CDC = strupper(GENNME)
drop GENNME

gen RXUNIT_CDC = strupper(UOM)
drop UOM

tostring STRENGTH_PER_UNIT, generate(RXSTRENG_CDC) force
drop STRENGTH_PER_UNIT

destring RXNDC, replace

rename (PRODNME MASTER_FORM) (PROPRIETARYNAME_CDC RXFORM_CDC)

keep RXNDC PROPRIETARYNAME_CDC NONPROPRIETARYNAME_CDC RXUNIT_CDC RXFORM_CDC ///
	 RXSTRENG_CDC MME_CONVERSION_FACTOR

sort RXNDC PROPRIETARYNAME_CDC
	
save "$dtadir/CDC_NDC.dta", replace

/*******************************************************************************
	(0.6) MERGE 1996-2013 PRESCRIBED MEDICINES FILES TO MULTUM LEXICON 
		SUPPLEMENTARY FILES, ADDING/REPLACING THERAPEUTIC CATEGORY VARIABLES 
		TO BASE PRESCRIBED MEDICINES FILES (ALREADY INCLUDED IN LATER YEARS)
*******************************************************************************/

quietly forvalues i = 1996/2013 {
	use "$rawdir/prescribed_medicines/Prescribed_Medicines_`i'.dta"
	capture confirm variable TC1
	if _rc == 0 {
		drop TC*
	}
	
	tempfile prescibedmedicines_with_ml_`i'
	
	merge 1:1 RXRECIDX DUPERSID using /*
		*/ "$rawdir/multum_lexicon/ML_supplementary_`i'.dta", /*
		*/ assert(3) nogen
	
	/* Panel variable isn't included in early years of Prescribed Medicines; we 
		want to have this, though */
	if `i' > 1996 & `i' < 2005 {
		merge m:1 DUPERSID using "$rawdir/full_year_consolidated/Full_Year_Consolidated_`i'.dta", /*
					*/ keepusing(PANEL) assert(2 3) keep(3) nogen
		rename PANEL PANEL // Sometimes panel variable has suffix which is a year
	}
		
	save `prescibedmedicines_with_ml_`i''
}

/*******************************************************************************
***	(1) LOAD IN ALL PRESCRIBED MEDICINES FILES, KEEPING DESIRED VARIABLES ******
*******************************************************************************/

* Write lists of variables we want to keep from Prescribed Medicines files
#delimit ;
global rx_info_all "PANEL DUPERSID RXRECIDX FILEYEAR RXXP* PURCHRD RXFORMSTR 
					RXNAME RXNDC RXDRGNAM RXQUANTY RXSTRENG RXUNITSTR TC1 TC1S1 
					TC1S1_1 TC1S1_2";
#delimit cr

* Import data for 1996 Prescribed Medicines records
use `prescibedmedicines_with_ml_1996'

/* Obs are only uniquely identified across MEPS datasets by DUPERSID and PANEL, 
	so we have to make sure we have both in aggregate Prescribed Medicines data */
gen PANEL = 1 // Everyone in MEPS in 1996 is PANEL 1
gen FILEYEAR = 1996

rename (RXFORM RXUNIT) (RXFORMSTR RXUNITSTR)

* Import data for all other years of Prescribed Medicines records
quietly forvalues i = 1996/2017 {
	foreach variable in FORM UNIT {
		capture confirm string variable RX`variable'
		if _rc == 0 {
			replace RX`variable'STR = RX`variable'
		} 
		else {
			decode RX`variable', generate(RX`variable'STR_temp)
			replace RX`variable'STR = RX`variable'STR_temp
			drop RX`variable'STR_temp
		}
	}
	
	if `i' < 1999 {
		keep $rx_info_all
	}
	else if `i' < 2000 {
		keep $rx_info_all RXFRMUNT
	}
	else if `i' < 2005 {
		keep $rx_info_all RXFRMUNT RXSTRUNT
	} 
	else if `i' < 2010 { // Panel variable is in Prescribed Medicines data for 2005-onward
		keep $rx_info_all RXFRMUNT RXSTRUNT
	}
	else {
		keep $rx_info_all RXFRMUNT RXSTRUNT RXDAYSUP
	}
	
	local j = `i' + 1
	if `j' < 2014 {
		append using `prescibedmedicines_with_ml_`j''
		replace FILEYEAR = `j' if missing(FILEYEAR)
	}
	else if `j' < 2018 {
		append using "$rawdir/prescribed_medicines/Prescribed_Medicines_`j'.dta"
		replace FILEYEAR = `j' if missing(FILEYEAR)
	}
}	

replace RXNAME = upper(RXNAME)
rename RXUNITSTR RXUNIT

compress

/*******************************************************************************
***	(2) CLASSIFY PRESCRIPTIONS AS MENTAL HEALTH MEDICATIONS AND SAVE AS .DTA ***
*******************************************************************************/

preserve

* Tag whether prescriptions are antidepressants or antipsychotics
gen MNTLHLTHMED1 = inlist(TC1S1, 249, 251) & PURCHRD == 1

bysort RXDRGNAM PURCHRD: egen likely_mental_health_med = max(MNTLHLTHMED1 & RXDRGNAM != "-9") 

replace MNTLHLTHMED1 = 1 if likely == 1

keep if MNTLHLTHMED == 1
keep PANEL DUPERSID MNTLHLTHMED1

collapse (max) MNTLHLTHMED1, by(PANEL DUPERSID)

save "$dtadir/mental_health_meds.dta", replace

restore

/*******************************************************************************
***	(3) CLASSIFY PRESCRIPTIONS AS OPIOID PRESCRIPTIONS *************************
*******************************************************************************/

* Store names of opiate drugs I'm interested in
#delimit ;
global druglist "BUTORPHANOL CODEINE DIHYDROCODEINE FENTANYL HYDROCODONE 
				 HYDROMORPHONE LEVORPHANOL MEPERIDINE MORPHINE NALBUPHINE OPIUM
				 OXYCODONE OXYMORPHONE PENTAZOCINE PROPOXYPHENE TAPENTADOL 
				 TRAMADOL";
#delimit cr

	/***************************************************************************
		(3.1) USE MULTUM-LEXICON VARIABLES TO CLASSIFY DRUGS AS OPIOIDS
	***************************************************************************/

		/***********************************************************************
			(3.1.1) USE MULTUM-LEXICON IMPUTED DRUG NAMES TO CLASSIFY DRUGS AS 
				OPIOIDS
		***********************************************************************/

/* Classify drug as opioid (excluding those used in Medication-assisted treatment
	for opioid addiction) to RXDRGNAM, from Multum Lexicon supplementary files */
gen IsOPD_mldrgnam = regexm(RXDRGNAM,"BUTORPHANOL") | regexm(RXDRGNAM,"CODEINE") /*
		*/ | regexm(RXDRGNAM,"DIHYDROCODEINE") | regexm(RXDRGNAM,"FENTANYL") /*
		*/ | regexm(RXDRGNAM,"HYDROCODONE") | regexm(RXDRGNAM,"HYDROMORPHONE") /*
		*/ | regexm(RXDRGNAM,"LEVORPHANOL") | regexm(RXDRGNAM,"MEPERIDINE") /*
		*/ | regexm(RXDRGNAM,"MORPHINE") | regexm(RXDRGNAM,"NALBUPHINE") /*
		*/ | (regexm(RXDRGNAM,"OPIUM") /*
			*/ & !regexm(RXDRGNAM,"TROPIUM") & !regexm(RXDRGNAM,"TOPIUM")) /*
		*/ | regexm(RXDRGNAM,"OXYCODONE") | regexm(RXDRGNAM,"OXYMORPHONE") /*
		*/ | regexm(RXDRGNAM,"PENTAZOCINE") | regexm(RXDRGNAM,"PROPOXYPHENE")/*
		*/ | regexm(RXDRGNAM,"TAPENTADOL") | regexm(RXDRGNAM,"TRAMADOL")
	
* Classify drug as opioid, including drugs used in medication-assisted treatment
gen IsAnyOPD_mldrgnam = IsOPD_mldrgnam /// 
	| (regexm(RXDRGNAM, "BUPRENORPHIN") | regexm(RXDRGNAM, "METHADON"))
		
		/***********************************************************************
			(3.1.2) CLASSIFY DRUG AS OPIOID ACCORDING TO MULTUM LEXICON 
				THERAPEUTIC CLASS VARIABLE
		***********************************************************************/

/* Classify drug as opioid (excluding those used in Medication-assisted treatment
	for opioid addiction) to RXDRGNAM, from Multum Lexicon supplementary files */
gen IsOPD_mlTC = (TC1S1_1 == 191 | TC1S1_1 == 60) & /*
	*/ !(RXDRGNAM == "-9" | regexm(RXDRGNAM, "NARCOTIC ANALGESIC") /*
	*/ | regexm(RXDRGNAM, "BUPRENORPHIN") | regexm(RXDRGNAM, "METHADONE"))
	
* Classify drug as opioid, including drugs used in medication-assisted treatment
gen IsAnyOPD_mlTC = (TC1S1_1 == 191 | TC1S1_1 == 60)
	
gen IsAnyOPD_ml = IsAnyOPD_mlTC | IsAnyOPD_mldrgnam
drop IsAnyOPD_mlTC IsAnyOPD_mldrgnam
	
		/***********************************************************************
			(3.1.3) VERIFY THAT, FOR NON-MEDICATION ASSISTED TREATMENT OPIOIDS, 
				USING THERAPEUTIC CLASS NEVER GIVES US MORE INFORMATION THAN 
				USING THE MULTUM LEXICON DRUG NAME. DROP THERAPEUTIC CLASS 
				VARIABLE.
		***********************************************************************/

/* Using therapeutic class never gives us additional help if we already know the 
	Multum Lexicon-imputed drug name, so we go ahead and drop */
assert IsOPD_mldrgnam == 1 if IsOPD_mlTC == 1
drop IsOPD_mlTC
rename IsOPD_mldrgnam IsOPD_ml
	
/* Keep track of the opiate component of the drug, if drug is classified as an 
	opioid under the Multum Lexicon drug name criterion */
gen OPD_COMPONENT_ml = ""

quietly foreach drug in $druglist {
	replace OPD_COMPONENT_ml = "`drug'" if regexm(RXDRGNAM, "`drug'") & IsOPD_ml
}

	/***************************************************************************
		(3.2) USE CDC CATALOGUE OF OPIOID DRUGS TO CLASSIFY, MERGING ONTO 
			PRESCRIBED MEDICINES FILES USING NATIONAL DRUG CODES (NDCs)
	***************************************************************************/
	
		/***********************************************************************
			(3.2.1) CLEAN UP NDCs BY REMOVING NON-NUMERIC CHARACTERS AND SAVING
				AS LONG
		***********************************************************************/

/* Merge CDC data onto Prescribed Medicines records using NDC to help with 
	identification of opioids */
foreach letter in B T {
	replace RXNDC = subinstr(RXNDC, "`letter'", "", .)
}

destring RXNDC, replace ignore("-")

		/***********************************************************************
			(3.2.2) MERGE TO CDC CATALOGUE AND CLASSIFY IF THERE'S A MERGE 
		***********************************************************************/

merge m:1 RXNDC using "$dtadir/CDC_NDC.dta", keep(1 3)

/* Classify drug as opioid according to non-proprietary name, as merged in from 
	CDC database according to national drug codes */
gen IsOPD_cdcndc = _merge == 3 & !regexm(NONPROPRIETARYNAME_CDC, "BUPRENORPHIN") & /*
					*/ !regexm(NONPROPRIETARYNAME_CDC, "METHADONE")
					
gen IsAnyOPD_cdcndc = _merge == 3 // keep track of opioids incl. buprenorphine and methadone

gen hasCDCinfo = _merge == 3
drop _merge

/* Keep track of the opiate component of the drug, if drug is classified as an 
	opioid under the CDC NDC nonproprietary drug name criterion */
gen OPD_COMPONENT_cdcndc = ""

quietly foreach drug in $druglist {
	replace OPD_COMPONENT_cdcndc = "`drug'" if regexm(NONPROPRIETARYNAME_CDC, "`drug'") & IsOPD_cdcndc
}

	/***************************************************************************
		(3.3) CORRECT PRESCRIPTION NAMES USING HAND-MADE LIST OF PROPRIETARY
			NAMES AND MISSPELLINGS IN PRESCRIBED MEDICINES FILES, THEN CLASSIFY
			OPIOIDS BASED ON NAMES
	***************************************************************************/

		/***********************************************************************
			(3.3.1) MERGE ON LIST OF MISSPELLED PROPRIETARY NAMES AND MAKE A 
				CORRECTED NAME VARIABLE
		***********************************************************************/

merge m:1 RXNAME using "$dtadir/opioidlist.dta", keep(1 3)

* Create new, corrected name variable
gen RXNAME_opdlist = cond(_merge == 3, NONPROPRIETARYNAME, RXNAME)
drop _merge

		/***********************************************************************
			(3.3.2) CLASSIFY AS OPIOID USING CORRECTED NAMES 
		***********************************************************************/

/* Classify drug as opioid not used in medication-assisted treatment according 
	to non-proprietary name, as merged in from opioidlist.dta */
gen IsOPD_rxname = regexm(RXNAME_opdlist,"BUTORPHANOL") | regexm(RXNAME_opdlist,"CODEINE") /*
	*/ | regexm(RXNAME_opdlist,"DIHYDROCODEINE") | regexm(RXNAME_opdlist,"FENTANYL") /*
	*/ | regexm(RXNAME_opdlist,"HYDROCODONE") | regexm(RXNAME_opdlist,"HYDROMORPHONE") /*
	*/ | regexm(RXNAME_opdlist,"LEVORPHANOL") | regexm(RXNAME_opdlist,"MEPERIDINE") /*
	*/ | regexm(RXNAME_opdlist,"MORPHINE") | regexm(RXNAME_opdlist,"NALBUPHINE") /*
	*/ | (regexm(RXNAME_opdlist,"OPIUM") /*
		*/ & !regexm(RXNAME_opdlist,"TROPIUM") & !regexm(RXNAME_opdlist,"TOPIUM")) /*
	*/ | regexm(RXNAME_opdlist,"OXYCODONE") | regexm(RXNAME_opdlist,"OXYMORPHONE") /*
	*/ | regexm(RXNAME_opdlist,"PENTAZOCINE") | regexm(RXNAME_opdlist,"PROPOXYPHENE")/*
	*/ | regexm(RXNAME_opdlist,"TAPENTADOL") | regexm(RXNAME_opdlist,"TRAMADOL")
	
* Classify as any opioid, incl. medication-assisted treatment
gen IsAnyOPD_rxname = IsOPD_rxname | /// Keep track of all presc., incl. buprenorphine & methadone
	(regexm(RXNAME_opdlist, "BUPRENORPHIN") | regexm(RXNAME_opdlist, "METHADON"))

/* OPD_COMPONENT_rxname is only correctly defined for observations corrected 
	using opdlist.dta; need to track opioid components for other observations */	
quietly foreach drug in $druglist {
	replace OPD_COMPONENT_rxname = "`drug'" if regexm(RXNAME_opdlist, "`drug'") & /*
		*/ IsOPD_rxname & OPD_COMPONENT_rxname == ""
}
	
	/***************************************************************************
		(3.4) USE RESULTS OF THREE DIFFERENT CLASSIFICATION METHODS IN 3.1-3.3
			TO DECIDE WHETHER PRESCRIPTION PERTAINS TO AN OPIOID. IF 2/3 
			METHODS CLASSIFY PRESCRIPTION AS OPIOID, CALLY IT AN OPIOID
	***************************************************************************/

		/***********************************************************************
			(3.4.1) CROSS-CHECK DIFFERENT METHODS
		***********************************************************************/

foreach mthd in ml cdcndc rxname {
	foreach othrmthd in ml cdcndc rxname {
		if "`mthd'" != "`othrmthd'" {
			di "Num differences b/w opioid component using `mthd' and `othrmthd'" 
			count if OPD_COMPONENT_`mthd' != OPD_COMPONENT_`othrmthd' /*
					*/ & IsOPD_`mthd' == IsOPD_`othrmthd'
			di "Num obs counted as opioids under both schemes"
			count if IsOPD_`mthd' == IsOPD_`othrmthd' & IsOPD_`mthd' == 1
		}
	}
}

		/***********************************************************************
			(3.4.2) USE INDICATORS CREATED FROM DIFFERENT METHODS TO CREATE 
				INDICATOR FOR WHETHER PRESCRIPTION IS AN OPIOID OR NOT
		***********************************************************************/

/* Trust hierarchy of drug determination: 
	(1) CDC database (with NDC numbers) 
	(2) Multum Lexicon corrected drug names 
	(3) Using original names, or names corrected with opdlist.dta 
   Take drug name and opiate component according to maximum trust source, if 
   there are discrepancies (see above). */
gen IsOPD = IsOPD_ml + IsOPD_cdcndc + IsOPD_rxname > 1
replace RXNAME = cond(IsOPD_cdcndc == 1, NONPROPRIETARYNAME_CDC, RXDRGNAM)
gen OPD_COMPONENT = cond(IsOPD_cdcndc == 1, OPD_COMPONENT_cdcndc, OPD_COMPONENT_ml)

gen IsAnyOPD = IsAnyOPD_ml + IsAnyOPD_cdcndc + IsAnyOPD_rxname > 1

	/***************************************************************************
		(3.5) SAVE A SEPARATE TEMPFILE OF ALL OPIOIDS -- DON'T NEED TO CLEAN
			INFORMATION FOR OPIOIDS USED IN MEDICATION-ASSISTED TREATMENT, BUT 
			DO WANT TO COUNT THEM FOR THE PURPOSE OF COMPUTING PRESCRIBING RATES
			AND MATCHING IQVIA AGGREGATES
	***************************************************************************/

preserve

keep if IsAnyOPD == 1

keep RXRECIDX FILEYEAR PANEL DUPERSID IsAnyOPD

tempfile mat_opds
save `mat_opds'

restore

	/***************************************************************************
		(3.6) KEEP (AS MAIN DATASET) ONLY OPIOIDS NOT USED IN MEDICATION-
			ASSISTED TREATMENT
	***************************************************************************/

* Clean up a bit
keep if IsOPD

drop IsOPD_* IsAnyOPD* NONPROPRIETARYNAME_CDC OPD_COMPONENT_* PROPRIETARYNAME /*
	*/ RXDRGNAM RXNAME_opdlist TC* 

compress

/*******************************************************************************
***	(4) CLEAN UP INFORMATION IN MAIN DATASET OF NON-MEDICATION-ASSISTED- *******
******* TREATMENT OPIOIDS ******************************************************
*******************************************************************************/

	/***************************************************************************
		(4.1) CLASSIFY DRUGS AS COUGH SYRUPS IF THEY CONTAIN COUGH SYRUP/
			ANTIHISTAMINE INGREDIENTS
	***************************************************************************/

* Use CDC drug form if we're missing data
replace RXFORMSTR = upper(RXFORM_CDC) if missing(RXFORMSTR) & hasCDCinfo == 1

* Replace common abbreviations of drug names which are common in cough medicines
replace RXNAME = subinstr(RXNAME, "CPM", "CHLORPHENIRAMINE", .) if !hasCDCinfo

replace RXNAME = subinstr(RXNAME, "PE", "PHENYLEPHRINE", .) if !hasCDCinfo & /*
				*/ !regexm(RXNAME, "PENTAZOCINE") & !regexm(RXNAME, "MEPERIDINE")
				
replace RXNAME = subinstr(RXNAME, "PSE", "PSEUDOEPHEDRINE", .) if !hasCDCinfo & /*
				*/ !regexm(RXNAME, "PSEUDOEPHEDRINE")
				
gen probable_cough_syr = regexm(RXNAME, "PHENYLEPHRINE") | regexm(RXNAME, "GUAIFENESIN") | ///
				regexm(RXNAME, "PROMETHAZINE") | regexm(RXNAME, "CHLORPHENIRAMINE") | ///
				regexm(RXNAME, "HOMATROPINE") | regexm(RXNAME, "TRIPROLIDINE") | ///
				regexm(RXNAME, "DIPHENHYDRAMINE") | regexm(RXNAME, "BROMPHENIRAMINE") | ///
				regexm(RXNAME, "BROMODIPHENHYDRAMINE") | ///
				regexm(RXNAME, "POTASSIUM GUAIACOLSULFONATE")

	/***************************************************************************
		(4.2) COMPUTE OR IMPUTE MME IF POSSIBLE

			The main idea is to follow the CDC catalogue info as much as 
			possible.
	***************************************************************************/

		/***********************************************************************
			(4.2.1) Copy CDC strength and units into main variable if we were 
				able to merge drug to CDC catalogue 
		***********************************************************************/

* Take unit and strength from CDC if possible
foreach variable in STRENG UNIT {
	replace RX`variable' = RX`variable'_CDC if hasCDCinfo == 1
}

drop RX*_CDC

		/***********************************************************************
			(4.2.2) IF WE DON'T HAVE CDC INFO, TRY TO GET ACCURATE STRENGTHS
				BY MATCHING DRUGS COMPONENT-BY-COMPONENT TO A LIST OF POSSIBLE
				DRUG STRENGTHS
		***********************************************************************/

			/*******************************************************************
				(4.2.2.1) Clean up important fields of data: names and strengths 
			*******************************************************************/

* Clean up drug names if no CDC info; replace abbreviations with actual terms
replace RXNAME = subinstr(RXNAME, "APAP", "ACETAMINOPHEN", .) if !hasCDCinfo

replace RXNAME = subinstr(RXNAME, "ASA", "ASPIRIN", .) if !hasCDCinfo

replace RXNAME = subinstr(RXNAME, "PPA", "PHENYLPROPANOLAMINE", .) if !hasCDCinfo

replace RXNAME = subinstr(RXNAME, "K IODIDE", "POTASSIUM IODIDE", .) if !hasCDCinfo

* Standardize missing drug strengths to empty string
replace RXSTRENG = subinstr(RXSTRENG, "-7", "", .)
replace RXSTRENG = subinstr(RXSTRENG, "-8", "", .)
replace RXSTRENG = subinstr(RXSTRENG, "-9", "", .)
replace RXSTRENG = subinstr(RXSTRENG, "99", "", .)
replace RXSTRENG = subinstr(RXSTRENG, "9999999998", "", .)
replace RXSTRENG = subinstr(RXSTRENG, "9999999999", "", .) 

* Standardize drug name and strength format; get rid of punctuation marks and use slashes
replace RXNAME = subinstr(RXNAME, "-", "/", .)
replace RXSTRENG = subinstr(RXSTRENG, "-", "/", .)
replace RXSTRENG = subinstr(RXSTRENG, ":", "/", .)

			/*******************************************************************
				(4.2.2.2) For fentanyl, make sure drug strengths are in MG, not
					MCG
			*******************************************************************/

tempvar fentanyl_stren need_to_rescale

gen `fentanyl_stren' = cond(OPD_COMPONENT == "FENTANYL", real(RXSTRENG), .)

gen `need_to_rescale' = !missing(`fentanyl_stren') & /*
		*/ (`fentanyl_stren' > 5 | /* 5 is max strength in mg for fentanyl
		*/ regexm(RXSTRUNT, "MCG") | regexm(RXFRMUNT, "MCG") | regexm(RXUNIT, "MCG"))
		
replace `fentanyl_stren' = `fentanyl_stren' / 1000 if `need_to_rescale'

replace RXSTRENG = string(`fentanyl_stren') if `need_to_rescale' == 1
foreach unitvar in RXUNIT RXSTRUNT RXFRMUNT {
	replace `unitvar' = "MG" if `need_to_rescale'
}

			/*******************************************************************
				(4.2.2.3) Go in and manually fix several prescription strenths
			*******************************************************************/

* Go in and manually fix a few strength issues (source = ORANGEBOOK)
replace RXSTRENG = "12/120" if inlist(RXSTRENG, "0.00012/120", "120/12.5")
replace RXSTRENG = "30/300" if inlist(RXSTRENG, ".0003/300", "0.0003/300") & /*
		*/ RXNAME == "ACETAMINOPHEN/CODEINE"
replace RXSTRENG = "60/300" if RXSTRENG == "0.0006/300" & RXNAME == "ACETAMINOPHEN/CODEINE"
replace RXSTRENG = "100/650" if inlist(RXSTRENG, "100/65", "650", "100100/650", "0.0001/650") & !hasCDCinfo & /*
		*/ (RXNAME == "ACETAMINOPHEN/PROPOXYPHENE" | RXNAME == "PROPOXYPHENE")
replace RXSTRENG = "50/325" if RXSTRENG == ".0005/325" & RXNAME == "ACETAMINOPHEN/PROPOXYPHENE"
replace RXSTRENG = "7.5/750" if RXSTRENG == "75/750" & RXNAME == "ACETAMINOPHEN/HYDROCODONE"
replace RXSTRENG = "7.5/650" if RXSTRENG == "0.00075/650" & RXNAME == "ACETAMINOPHEN/HYDROCODONE"
replace RXSTRENG = "4.8/325" if RXSTRENG == "4.5/325" & RXNAME == "ASPIRIN/OXYCODONE"

			/*******************************************************************
				(4.2.2.4) Split drug name and strength variables component-wise
					so we can match each drug component-wise to a list with all
					possible strengths for a combination of drugs
			*******************************************************************/

foreach variable in NAME STRENG {
	gen RX`variable'_GETSTR = cond(hasCDCinfo, "", RX`variable')
	split RX`variable'_GETSTR, parse("/")
}

			/*******************************************************************
				(4.2.2.5) Create indicators for drug having specific form
			*******************************************************************/

* Create indicators to help identify form of drug if unavailable
tempvar is_liquid solid potential_liquid not_liquid

gen `is_liquid' = inlist(RXFRMUNT, "ML", "CC") | /*
					*/ inlist(RXFORM, "LIQ", "SYP", "SYR", "SYRP", "SOL", "ELIX", "LIQD", "SOLN") | /*
					*/ inlist(RXFORMSTR, "LIQ", "SYP", "SYR") | /*
					*/ regexm(RXUNIT, "ML") | regexm(RXUNIT, "CC") | /*
					*/ regexm(RXSTRUNT, "ML") | regexm(RXSTRUNT, "CC")
				
gen `solid' = inlist(RXFRMUNT, "CAPS", "G", "GM", "MG", "OZ", "TAB") | /*
					*/ inlist(RXFORM, "TAB", "TABS", "CP12") | /*
					*/ inlist(RXFORMSTR, "TAB", "TABS", "CP12") | /*
					*/ inlist(RXUNIT, "MCG", "MG", "MG/MG") | /*
					*/ inlist(RXSTRUNT, "IU", "IU/IU", "MCG", "MCG/HR", "MG/MG", /*
								*/ "MG/MG/MG", "MG/MG/MG/MG", "U/GM")

sort RXNAME RXSTRENG
egen `potential_liquid' = max(`is_liquid' & RXSTRENG != ""), by(RXNAME RXSTRENG)
egen `not_liquid' = max(`solid' & RXSTRENG != ""), by(RXNAME RXSTRENG)

gen likely_liquid = `potential_liquid' == 1 & `not_liquid' == 0

* Manually impute likely liquid for one case (source = MICROMEDEX)
replace likely_liquid = 1 if RXNAME == "CHLORPHENIRAMINE/HYDROCODONE" & RXSTRENG == "8/10/5"

			/*******************************************************************
				(4.2.2.6) Merge each drug component-wise to a list with all 
					possible drug strengths for that drug
			*******************************************************************/

				/***************************************************************
					(4.2.2.6.1) Ensure drug component names are arranged 
						alphabetically left to right.
				***************************************************************/

* Ensure that RXNAME_GETSTR`i' are arranged alphabetically left to right
forv i = 1/4 {
	local j = `i' + 1
	assert RXNAME_GETSTR`i' < RXNAME_GETSTR`j' if RXNAME_GETSTR`i' != "" & RXNAME_GETSTR`j' != ""
}
				/***************************************************************
					(4.2.2.6.2) Import spreadsheet of possible opioid strengths 
						for drugs for which we don't have CDC info; strengths 
						taken from IBM Micromedex drug database or FDA Orange 
						Book database, if available. Save as tempfile
				***************************************************************/

preserve

import excel using "$datadir/opd_strengths.xlsx", firstrow allstring clear

/* There are some drugs in MEPS for which drug strengths were not available 
	in either the orange book or IBM Micromedex */
list RXNAME_GETSTR* if POSSIBLE_STREN1 == ""

tempfile opd_strengths
save `opd_strengths'

restore 
	
				/***************************************************************
					(4.2.2.6.3) Merge records drug-component-wise to spreadsheet
				***************************************************************/

merge m:1 RXNAME_GETSTR1 RXNAME_GETSTR2 RXNAME_GETSTR3 RXNAME_GETSTR4 /*
	*/ RXNAME_GETSTR5 using `opd_strengths', keepusing(POSSIBLE_STREN*) assert(1 3)

assert _merge == 3 if !hasCDCinfo // for each drug without CDC info, we have a merge

drop _merge

			/*******************************************************************
				(4.2.2.7) Use list of possible drug strengths to impute a drug
					strength for each record for which we don't have CDC info, 
					if possible
			*******************************************************************/

* Want to try to impute RXSTRENG where we don't have CDC records
gen RXSTRENG_IMPUTED = cond(hasCDC, .n, /* n/a if has CDC records */ .)

				/***************************************************************
					(4.2.2.7.1) Make variables to keep track of matches
				***************************************************************/

/* Cycle through opioid component strengths and possible strengths for drugs in 
	question and see whether we have any matches */
gen EXACT_MATCH = "" /* A list of possible strengths which exactly match a value 
						stored in split RXSTRENG variable */

gen PARTIAL_MATCH = "" /* A list of possible strengths which are a substring 
							of a value stored in split RXSTRENG variable */

gen exact_count = 0 /* How many of RXSTRENG fields match a possible drug 
						strength for drug in question */

gen partial_count = 0 /* How many times a possible drug strength is a substring 
						of RXSTRENG */

				/***************************************************************
					(4.2.2.7.2) Cycle through each split-up RXSTRENG variable
						and see if it matches any of the possible opioid 
						strengths we imported in the list in step 4.2.2.6.2
				***************************************************************/

quietly forv i = 1/5 { // cycle through split-up RXSTRENG variable
	forv j = 1/15 { // cycle through possible strengths from imported list

		replace exact_count = cond(RXSTRENG_GETSTR`i' == POSSIBLE_STREN`j' & /*
								*/ RXSTRENG_GETSTR`i' != "" & /*
								*/ POSSIBLE_STREN`j' != "" & /*
								*/ !regexm(EXACT_MATCH, "`j'"), exact_count + 1, exact_count)
		
		replace EXACT_MATCH = cond(RXSTRENG_GETSTR`i' == POSSIBLE_STREN`j' & /*
							*/ RXSTRENG_GETSTR`i' != "" & POSSIBLE_STREN`j' != "", /*
					*/ cond(RXSTRENG_GETSTR`i' == "5", EXACT_MATCH + "`j' (five), ", /*
						*/ EXACT_MATCH + "`j', "), EXACT_MATCH)
							
		replace partial_count = cond(regexm(RXSTRENG_GETSTR`i', POSSIBLE_STREN`j') & /*
						*/ RXSTRENG_GETSTR`i' != "" & POSSIBLE_STREN`j' != "" & /*
						*/ !regexm(RXSTRENG_GETSTR`i', POSSIBLE_STREN`j' + "0") & /*
						*/ !regexm(PARTIAL_MATCH, "`j', "), partial_count + 1, partial_count)
		
		replace PARTIAL_MATCH = PARTIAL_MATCH + "`j', " if regexm(RXSTRENG_GETSTR`i', POSSIBLE_STREN`j') & /*
							*/ !regexm(RXSTRENG_GETSTR`i', POSSIBLE_STREN`j' + "0") & /*
							*/ RXSTRENG_GETSTR`i' != "" & POSSIBLE_STREN`j' != ""
	}
}

			/*******************************************************************
				(4.2.2.8) Use matches we found by cycling through above to 
					figure out most likely true opioid strength
			*******************************************************************/

assert exact_count < 4 // At most we have three exact matches

replace PARTIAL_MATCH = "" if EXACT_MATCH != "" // Don't want partial matches if we have exact
replace partial_count = 0 if exact_count > 0

				/***************************************************************
					(4.2.2.8.1) For prescriptions for which we have two exact 
						drug strength matches, narrow down range of possible 
						strengths by eliminatign cases in which one number of 
						RXSTRENG is likely to mean "per 5 ML". If exact match 
						is 5 and prescription is liquid (as classified in step
						4.2.2.5), use other exact match strength
				***************************************************************/

/* If we have two exact matches, can narrow down by eliminating cases in which 
	one number in RXSTRENG is likely to mean "per 5 ML." If exact match is 5 and
	prescription is liquid, use other exact match strength */
tempvar exact_count_tmp
gen `exact_count_tmp' = exact_count
					
forv i = 1/15 {
	replace exact_count = exact_count - 1 if strpos(EXACT_MATCH, "five") > 0 /*
						*/ & exact_count == 2 & likely_liquid == 1
	
	replace EXACT_MATCH = subinstr(EXACT_MATCH, "`i' (five), ", "", 1) if /* 
						*/ `exact_count_tmp' == 2 & likely_liquid == 1
}

				/***************************************************************
					(4.2.2.8.2) Manually fix liquid morphine prescriptions, 
						since these are often prescribed as 2 MG / 1 ML or 
						4 MG / 1 ML. 
				***************************************************************/

forv stren = 2(2)4 {
	* Strength is recorded as mg/ml
	assert likely_liquid if RXSTRENG_GETSTR == "`stren'/1" & /*
							*/ RXNAME == "MORPHINE" & exact_count == 2
	replace EXACT_MATCH = cond(RXSTRENG_GETSTR == "2/1", "11, ", "10, ") /*
							*/ if RXSTRENG_GETSTR == "`stren'/1" & /*
							*/ RXNAME == "MORPHINE" & exact_count == 2
	replace exact_count = 1 if RXSTRENG_GETSTR == "`stren'/1" & /*
							*/ RXNAME == "MORPHINE" & exact_count == 2
}

				/***************************************************************
					(4.2.2.8.3) For prescriptions for which we have one exact 
						match value, take the value and make it our RXSTRENG
				***************************************************************/

replace EXACT_MATCH = substr(EXACT_MATCH, 1, strpos(EXACT_MATCH, ",") - 1) if exact_count == 1
forv i = 1/15 {
	replace RXSTRENG_IMPUTED = real(POSSIBLE_STREN`i') if inlist(EXACT_MATCH, "`i'", "`i' (five)")
}

				/***************************************************************
					(4.2.2.8.4) For other exact match prescriptions where we 
						have multiple exact matches, manually assign a few cases
						for which we know the exact opioid drug strengths from 
						MICROMEDEX
				***************************************************************/
 
replace RXSTRENG_IMPUTED = 2.5 if RXNAME == "CHLORPHENIRAMINE/HYDROCODONE/PHENYLEPHRINE" & /*
		*/ inlist(RXSTRENG_GETSTR, "2/2.5/5/5", "5/2.5/2/5", "2.5/5/2", "2.5/5", "10/2.5/2/5")
replace RXSTRENG_IMPUTED = 1.67 if RXNAME == "CHLORPHENIRAMINE/HYDROCODONE/PHENYLEPHRINE" & /*
		*/ inlist(RXSTRENG_GETSTR, "5/2/1.67", "5/2/1.67/5/5", "5/1.67/2", "2/1.67/5/5")
replace RXSTRENG_IMPUTED = 2 if RXNAME == "CHLORPHENIRAMINE/HYDROCODONE/PHENYLEPHRINE" & /*
		*/ inlist(RXSTRENG_GETSTR, "5/2.5/2", "5/2/2.5/5")
replace RXSTRENG_IMPUTED = 3.5 if RXNAME == "GUAIFENESIN/HYDROCODONE" & /*
							*/ inlist(RXSTRENG_GETSTR, "100/5/3.5/5", "3.5/100/5")

				/***************************************************************
					(4.2.2.8.5) For drugs for which we haven't yet imputed a 
						strength but for which we have at least one exact match,
						choose smaller of two possible strengths (there are 
						only two possible remaining at this point.
				***************************************************************/

assert exact_count < 3 if RXSTRENG_IMPUTED == .
							
/* If we haven't sorted out RXSTRENG_IMPUTED yet and exact_count == 2, impute 
	smaller of two matched strengths */
tempvar exact_stren1 exact_stren2
forv i = 1/2 { // cycle through two different strengths
	gen `exact_stren`i'' = ""
	forv j = 1/15 {
		replace `exact_stren`i'' = POSSIBLE_STREN`j' if strpos(EXACT_MATCH, "`j'") > 0 /*
			*/ & exact_count == 2 & RXSTRENG_IMPUTED == . & `exact_stren`i'' == ""
		replace EXACT_MATCH = subinstr(EXACT_MATCH, "`j'", "", .) if `exact_stren`i'' == POSSIBLE_STREN`j'
	}
}
destring `exact_stren1' `exact_stren2', replace

replace RXSTRENG_IMPUTED = cond(`exact_stren1' > `exact_stren2', `exact_stren2', `exact_stren1') /*
								*/ if exact_count == 2 & RXSTRENG_IMPUTED == .
drop EXACT exact	

				/***************************************************************
					(4.2.2.8.6) Now deal with partial matches, of which we 
						have at most two. If we have one partial match, take it
						and put into RXSTRENG. Otherwise, take smaller of two
						values.
				***************************************************************/

assert partial_count < 3 // At most we have two

* If we have one partial match, take value and put it in RXSTRENG
replace PARTIAL_MATCH = substr(PARTIAL_MATCH, 1, strpos(PARTIAL_MATCH, ",") - 1) if partial_count == 1
forv i = 1/15 {
	replace RXSTRENG_IMPUTED = real(POSSIBLE_STREN`i') if PARTIAL_MATCH == "`i'"
}

/* If we haven't sorted out RXSTRENG_IMPUTED yet and partial_count == 2, impute 
	smaller of two matched strengths */
tempvar partial_stren1 partial_stren2
forv i = 1/2 {
	gen `partial_stren`i'' = ""
	forv j = 1/15 {
		replace `partial_stren`i'' = POSSIBLE_STREN`j' if strpos(PARTIAL_MATCH, "`j'") > 0 /*
			*/ & partial_count == 2 & RXSTRENG_IMPUTED == . & `partial_stren`i'' == ""
		replace PARTIAL_MATCH = subinstr(PARTIAL_MATCH, "`j'", "", .) if `partial_stren`i'' == POSSIBLE_STREN`j'
	}
}
destring `partial_stren1' `partial_stren2', replace

replace RXSTRENG_IMPUTED = cond(`partial_stren1' > `partial_stren2', `partial_stren2', `partial_stren1') /*
								*/ if partial_count == 2 & RXSTRENG_IMPUTED == .
								
drop PARTIAL partial

* Can impute ~58% of strengths using Micromedex/Orange Book info
tab RXSTRENG_IMPUTED if !hasCDCinfo, m 

				/***************************************************************
					(4.2.2.8.7) If exact and partial matching both failed, 
						assuming drug has lowest possible strength
				***************************************************************/

forv i = 1/15 {
	if `i' < 15 {
		local j = `i' + 1
		replace RXSTRENG_IMPUTED = real(POSSIBLE_STREN`i') /*
			*/ if RXSTRENG_IMPUTED == . & POSSIBLE_STREN`j' == ""
	}
	else {
		replace RXSTRENG_IMPUTED = real(POSSIBLE_STREN`i') if RXSTRENG_IMPUTED == .
	}
}

replace RXSTRENG = string(RXSTRENG_IMPUTED) if RXSTRENG_IMPUTED != .n
destring RXSTRENG, replace

/* Ensure that, if we're missing RXSTRENG at this point, the drug in question is 
	one of the drugs for which strength was not available in the Orange Book or 
	Micromedex */
assert inlist(RXNAME, "CHLORPHENIRAMINE/CODEINE/PHENYLEPHRINE/POTASSIUM IODIDE", /*
			*/ "CODEINE/DIPHENHYDRAMINE/PHENYLEPHRINE", /*
			*/ "DEXBROMPHENIRAMINE/HYDROCODONE/PHENYLEPHRINE", /*
			*/ "HYDROCODONE/PHENIRAMINE/PHENYLEPHRINE/PHENYLPROPANOLAMINE/PYRILAMINE") if missing(RXSTRENG)

drop RXSTRENG_IMPUTED RXNAME_GETSTR* RXSTRENG_GET* POSSIBLE* likely hasCDCinfo

tab RXSTRENG, m // Can get a strength for 99.98% of drugs

compress

		/***********************************************************************
			(4.2.3) USE MME CONVERSION FACTORS AND DRUG STRENGTH TO TRY TO GET
				MME PER DAY 
		***********************************************************************/

			/*******************************************************************
				(4.2.3.1) Fill in conversion factors for drugs without CDC info
			*******************************************************************/

tempvar mme_conv mme_conv_fentanyl
egen `mme_conv' = min(MME_CONVERSION_FACTOR), by(OPD_COMPONENT)
egen `mme_conv_fentanyl' = min(MME_CONVERSION_FACTOR), by(OPD_COMPONENT RXSTRENG)

replace MME_CONVERSION_FACTOR = cond(OPD_COMPONENT == "FENTANYL", /*
								*/ round(`mme_conv_fentanyl', 0.01), /*
									*/ round(`mme_conv', 0.01)) if missing(MME_CONVERSION_FACTOR)
								
* No MME conversion for nalbuphine			
assert OPD_COMPONENT == "NALBUPHINE" if missing(MME_CONVERSION_FACTOR)
replace MME_CONVERSION_FACTOR = 0 if missing(MME_CONVERSION_FACTOR)

			/*******************************************************************
				(4.2.3.2) Clean up prescription quantity variable  
			*******************************************************************/

* Now clean up RXQUANTY and compute total MME for prescription
replace RXQUANTY = round(RXQUANTY)
replace RXQUANTY = 0 if RXQUANTY == -9 // missing

			/*******************************************************************
				(4.2.3.3) Compute total MME for prescription, then divide by
					number of days' supply to get MME per day. Can only do this
					for prescriptions 2010 and onward.
			*******************************************************************/

gen TOTAL_MME = RXQUANTY * RXSTRENG * MME_CONVERSION_FACTOR

/* Starting in 2010, days' supply variable becomes available; can use this to 
	compute MME per day for these prescriptions */
gen MME_PER_DAY = cond(missing(RXDAYSUP) | RXDAYSUP < 0 | RXDAYSUP > 360, ., TOTAL_MME / RXDAYSUP)
	
/*******************************************************************************
*** (5) COLLAPSE TO YIELD INDIVIDUAL-LEVEL MEASURES OF PRESCRIPTION OPIATE USE *
**** BY ROUND ******************************************************************
*******************************************************************************/

gen IsOPD1 = IsOPD == 1 & PURCHRD == 1

forv rd = 2/5 {
	gen IsOPD`rd' = IsOPD == 1 & PURCHRD == `rd'
}

forv j = 60(30)120 {
	gen Is`j'PLUSMME = MME_PER_DAY >= `j'
}

egen TOTALOPDEXPENDITURE = rowtotal(RXXP*)

merge 1:1 RXRECIDX PANEL DUPERSID FILEYEAR using `mat_opds', assert(2 3) nogen

collapse (sum) OPDCNT1 = IsOPD1 OPDCNT2 = IsOPD2 OPDCNT3 = IsOPD3 ///
	OPDCNT4 = IsOPD4 OPDCNT5 = IsOPD5 OPDTOTAL = IsOPD ///
	OPDTOTAL_INCL_MAT = IsAnyOPD TOTAL60PLUSMME = Is60PLUSMME ///
	TOTAL90PLUSMME = Is90PLUSMME TOTAL120PLUSMME = Is120PLUSMME ///
	TOTALOPDEXPENDITURE ///
	COUGHOPDTOTAL = probable_cough_syr (max) MAXMMEPERDAY = MME_PER_DAY, ///
	by(PANEL DUPERSID)

gen NONCOUGHOPDTOTAL_INCL_MAT = OPDTOTAL_INCL_MAT - COUGHOPDTOTAL
drop COUGHOPDTOTAL

assert NONCOUGHOPDTOTAL_INCL_MAT >= 0
	
compress
			
save "$dtadir/opioids.dta", replace