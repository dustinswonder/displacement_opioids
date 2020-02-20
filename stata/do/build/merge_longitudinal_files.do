/*******************************************************************************
Project: Effects of Job Displacement on Prescription Opiate Use: Evidence from 
		 the Medical Expenditure Panel Survey -- Swonder
Created by: 	Dustin Swonder
Last modified: 	02/09/2020
Description: This .do file appends longitudinal data files so that all data for
		     all individuals in publicly available MEPS data files are available
			 for collective consideration.
*******************************************************************************/

capture log close

/*******************************************************************************
	(1) Write global macros
*******************************************************************************/

* Write lists of variables we want to keep in longitudinal (panel) data files
gl demographics "SEX RACEX AGEY1X* HISPANX MARRY1X HIDEG* REGION1 INST RURSLT?"
gl work_vars "YCHJ* EMPST? WAGE* TTLP* BUSNP* DIVDP* TRSTP*"
gl health_all_panels "IPNGTD* WLKLIM* WLKDIF* MILDIF* BENDIF* RCHDIF* FNGRDF* STNDIF* WRKLIM* UNABLE* MNHLTH*" 
gl health_panels_3plus "DDNWRK* AIDHLP*" // Additional health vars become available after panels 3 and 4
gl health_panels_4plus "JTPAIN* ASPRIN* HYSTER* ADILCR* ADSPEC* ADDAYA* ADCLIM* ADSOCA* ADRISK*"
gl identifiers "DUPERSID DUID PID PANEL YEARIND"
gl ind_occ_before7 "CIND1 COCCP1" // Industry & occupations categorization
gl ind_occ_7plus "INDCAT1 OCCCAT1" // variables changes after panel 7

/*******************************************************************************
	(2) RUN STATA PROGRAMMING STATEMENTS TO GET RAW LONGITUDINAL FILES IN .DTA 
		FORMAT

	Run programming statements (taken directly from MEPS website) to get raw  
	data from .dat format to .dta format. Original programming statements are  
	only modified to use file locations on this computer.
*******************************************************************************/

local panelnum = 1

foreach file_num in 23 35 48 58 65 71 80 86 98 106 114 122 130 139 148 156 ///
	164 172 183 193 202 {

	qui do $dodir/programming_statements/longitudinal/h`file_num'stu.do
	qui save $rawdir/longitudinal/Longitudinal_`panelnum'.dta, replace
	qui rm $rawdir/longitudinal/H`file_num'.dta

	local panelnum = `panelnum' + 1
}

/*******************************************************************************
	(3) APPENDING DATA FILES
*******************************************************************************/

* Import data for PANEL 1 (1996 - 1997) from longitudinal data files
use  "$rawdir/longitudinal/Longitudinal_1.dta", clear
keep $demographics $work_vars $health_all_panels $identifiers $ind_occ_before7 LONGWT

* Import data for all other panels from subsequent longitudinal data files
forval i = 2/21 {
	append using "$rawdir/longitudinal/Longitudinal_`i'.dta"
	if `i' < 3 {
		keep $demographics $work_vars $health_all_panels $identifiers ///
			$ind_occ_before7 LONGWT
	}  
	else if `i' < 4 {
		keep $demographics $work_vars $health_all_panels $health_panels_3plus ///
			$identifiers $ind_occ_before7 LONGWT
	} 
	else if `i' < 7 {
		keep $demographics $work_vars $health_all_panels $health_panels_3plus ///
			$health_panels_4plus $identifiers $ind_occ_before7 LONGWT
	}
	else if `i' < 16 {
		keep $demographics $work_vars $health_all_panels $health_panels_3plus ///
			$health_panels_4plus $identifiers $ind_occ_before7 $ind_occ_7plus LONGWT
	} 
	else if `i' < 17 {
		keep $demographics RACEV1X $work_vars $health_all_panels $health_panels_3plus ///
			$health_panels_4plus $identifiers $ind_occ_before7 $ind_occ_7plus LONGWT
	}
	else {
		keep $demographics RACEV1X EDRECODE $work_vars $health_all_panels ///
			$health_panels_3plus $health_panels_4plus $identifiers ///
			$ind_occ_before7 $ind_occ_7plus LONGWT
	}
}

/*******************************************************************************
	(4) Sort'n'save
*******************************************************************************/

sort PANEL DUPERSID

* Save appended longitudinal file
save "$dtadir/merged_longitudinal.dta", replace