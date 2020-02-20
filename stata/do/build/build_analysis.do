/*******************************************************************************
Project: Effects of Job Displacement on Prescription Opiate Use: Evidence from 
		 the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	02/09/2020
Description: This .do file merges clean longitudinal data with clean, collapsed
			 Prescribed Medicines data to produce analysis data.
*******************************************************************************/

capture log close
log using $logdir/build_analysis.log, replace

/*******************************************************************************
	Load in clean, appended longitudinal files and merge to opioids data from 
		Prescribed Medicines files
*******************************************************************************/

use "$dtadir/clean_longitudinal.dta", clear

/* Nonzero _merge == 2 b/c Prescribed Medicines & Full Year Consolidated contain
	all sampled individuals whereas Longitudinal sample only includes individuals
	who participated in the survey for all or part of period */
merge 1:1 DUPERSID PANEL using "$dtadir/opioids.dta", keep(1 3) nogen

merge 1:1 DUPERSID PANEL using "$dtadir/mental_health_meds.dta", keep(1 3) nogen

/*******************************************************************************
	Clean up outcome variables a bit and define main outcomes
*******************************************************************************/

/* If individual did not have any opioids in prescribed medicines files, replace
	variable with zero */
foreach opdvar of varlist OPDCNT? TOTALOPDEXPENDITURE OPDTOTAL OPDTOTAL_INCL_MAT {
	qui replace `opdvar' = 0 if missing(`opdvar')
}

replace MNTLHLTHMED1 = 0 if missing(MNTLHLTHMED1)
label variable MNTLHLTHMED1 "Rcvd. presc. for antidepressant/antipsychotic in R1"

assert !missing(OPDTOTAL)
gen EVERUSEDOPDS = OPDTOTAL > 0
label variable EVERUSEDOPDS "Accumulated one or more opioid prescriptions"

* Define opioid use outcome variable indicators at various thresholds of use
forv i = 2/15 {
	gen HAD`i'PLUSOPDPRSC = OPDTOTAL >= `i'
	label variable HAD`i'PLUSOPDPRSC "Accumulated `i' or more opioid prescriptions"
}

gen mme_per_day_sample = PANEL > 14 // Define group for which we can use MME vars

* Define MME per day outcome variable indicators at various thresholds of use
forv i = 60(30)120 {
	gen EVER`i'MMEPERDAY = cond(!mme_per_day_sample, .n, /* not applicable
							*/ MAXMMEPERDAY >= `i' & !missing(MAXMMEPERDAY))

	lab var EVER`i'MMEPERDAY "Ever had a prescription for greater than `i' MME per day"
}

* Want age buckets rather than years; only really interested in prime-age workers
gen AGEGRP = cond(AGEY1 < 25, -2, /// Too young
				cond(AGEY1 < 35, 1, ///
				cond(AGEY1 < 45, 2, ///
				cond(AGEY1 < 55, 3, -1)))) // Too old
label define agegrp 1 "25-34" 2 "35-44" 3 "45-54" -1 "Older than 55" -2 "Under 25"
label values AGEGRP agegrp
label variable AGEGRP "Age group"

* Can't have negative values for analysis
foreach variable in HIDEG RACEX CIND1 COCCP1 {
	replace `variable' = . if `variable' < 0
}
	
* Enumerate health control variables
#delimit ;
global healthcontrols "BADMNTLHLTH1 MNTLHLTHMED1 EVERADCLIM EVERADDAYA EVERADILCR  
			EVERADSPEC EVERADRISK EVERADSOCA EVERASPRIN EVERHYSTER EVERAIDHLP  
			EVERUNABLE EVERWLKLIM EVERWRKLIM EVERJTPAIN EVERBENDIF EVERFNGRDF  
			EVERMILDIF EVERRCHDIF EVERSTNDIF EVERWLKDIF EVERIPNGTD EVERDDNWRK";
#delimit cr	

qui reg EVERUSEDOPDS EVERDIS i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 ///
	i.COCCP1 i.HIDEG $healthcontrols i.PANEL [pw = LONGWT] if AGEGRP > 0, r
	
* Define sample and clean up weights
gen sample = OPDCNT1 == 0 & EMPST1 == 1 & AGEGRP > 0 & e(sample) == 1
replace LONGWT = round(LONGWT) // Stata doesn't allow non-whole frequency weights

label variable sample "In sample: zero first-round opioid presc., emp. in first round, prime-age"
label variable mme_per_day_sample "Entered survey beyond panel 14 (2010)"

* Clean up a bit 
rename REGION1 REGION

compress

save "$dtadir/analysis.dta", replace

log close