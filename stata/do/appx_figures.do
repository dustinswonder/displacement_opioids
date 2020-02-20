/*******************************************************************************
Project: 		Effects of Job Displacement on Prescription Opiate Use: Evidence 
		 		from the Medical Expenditure Panel Survey.
Created by: 	Dustin Swonder
Last modified: 	02/19/2019
Description: 	This do-file makes appendix figures for the paper.
*******************************************************************************/

/*******************************************************************************
	Set environment and global parameters
*******************************************************************************/

clear

capture log close

log using $logdir/appx_figures.log, replace 

global gpr = "plotregion(color(white) margin(small)) graphregion(color(white))"

#delimit ;
global healthcontrols "BADMNTLHLTH1 MNTLHLTHMED1 EVERADCLIM EVERADDAYA EVERADILCR  
			EVERADSPEC EVERADRISK EVERADSOCA EVERASPRIN EVERHYSTER EVERAIDHLP  
			EVERUNABLE EVERWLKLIM EVERWRKLIM EVERJTPAIN EVERBENDIF EVERFNGRDF  
			EVERMILDIF EVERRCHDIF EVERSTNDIF EVERWLKDIF EVERIPNGTD EVERDDNWRK";
#delimit cr


/*******************************************************************************
	Figures 4-5: Proportions of prime-age individuals exceeding (4) thresholds 
		of non-MAT opioid prescription receipt (5) MME per day thresholds, by 
		employment activity
*******************************************************************************/

use "$dtadir/analysis.dta", clear

drop if AGEGRP < 0 // only want prime-age individuals

tempvar ROUNDSWORKED
gen `ROUNDSWORKED' = (EMPST1 == 1) + (EMPST2 == 1) + (EMPST3 == 1) ///
					+ (EMPST4 == 1) + (EMPST5 == 1)

gen EMPSTATUS = cond(`ROUNDSWORKED' == 5, 1, ///
					cond(`ROUNDSWORKED' > 0 & !missing(`ROUNDSWORKED'), 2, 3))
					
label define empstatus 1 "Always worked during MEPS particip." ///
						2 "Sometimes worked during MEPS particip." ///
						3 "Never worked during MEPS particip."
						
label values EMPSTATUS empstatus

collapse EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME EVER90MME ///
		 EVER120MME [aw = LONGWT], by(EMPSTATUS PRIMARY_YEAR)

qui ds EMPSTATUS PRIMARY_YEAR, not
foreach var in `r(varlist)' {
	replace `var' = `var' * 100
}
		
label variable PRIMARY_YEAR "Year"
label variable EVERUSEDOPDS "Received one or more opd. presc. (%)"
label variable HAD6PLUSOPDPRSC "Received 6+ opd. presc. (%)"
label variable HAD12PLUSOPDPRSC "Received 12+ opd. presc. (%)"
label variable EVER60MME "Ever had 60+ MME/day presc. (%)"
label variable EVER90MME "Ever had 90+ MME/day presc. (%)"
label variable EVER120MME "Ever had 120+ MME/day presc. (%)"

foreach variable in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
	EVER90MME EVER120MME {
	
	if regexm("`variable'", "MME") {
		local minyear = 2010
		local increment = 2
		local fignum = 2
		if regexm("`variable'", "60") {
			local subfig = "a"
		}
		else if regexm("`variable'", "90") {
			local subfig = "b"
		}
		else {
			assert regexm("`variable'", "120") 
			local subfig = "c"
		}
	}
	else {
		local minyear = 1996
		local increment = 4
		local fignum = 1
		if regexm("`variable'", "EVER") {
			local subfig = "a"
		}
		else if regexm("`variable'", "6") {
			local subfig = "b"
		}
		else {
			assert regexm("`variable'", "12") 
			local subfig = "c"
		}
	}
	
	twoway (scatter `variable' PRIMARY_YEAR if inrange(PRIMARY_YEAR, `minyear', 2017) & ///
			EMPSTATUS == 1, c(l) lpattern(1) lcolor(maroon) ms(o) mcolor(maroon)) ///
		(scatter `variable' PRIMARY_YEAR if inrange(PRIMARY_YEAR, `minyear', 2017) & ///
			EMPSTATUS == 2, c(l) lpattern(_) lcolor(maroon) ms(o) mcolor(maroon)) ///
		(scatter `variable' PRIMARY_YEAR if inrange(PRIMARY_YEAR, `minyear', 2017) & ///
			EMPSTATUS == 3, c(l) lpattern(-) lcolor(maroon) ms(o) mcolor(maroon)), ///
		$gpr legend(label(1 "Always worked during MEPS particip.") ///
			label(2 "Sometimes worked during MEPS particip.") ///
			label(3 "Never worked during MEPS particip.") region(lcolor(white)) rows(3)) ///
		xlab(`minyear'(`increment')2016)
	
	local filename_ext = lower("`variable'")
	graph export "$appxfigures/appxAfig`fignum'`subfig'.pdf", replace
}

/*******************************************************************************
	Appendix Figure A.3: Baseline Regression Results of Regressions of All 
		Prescription Count Indicators on Displacement
*******************************************************************************/

estimates clear

foreach indepvar in EVERNONLAYOFFDISPL EVERLAIDOFF EVERDISPLACED {

	if "`indepvar'" == "EVERNONLAYOFFDISPL" {
		local subfig = "a"
	}
	else if "`indepvar'" == "EVERLAIDOFF" {
		local subfig = "c"
	}
	else {
		assert "`indepvar'" == "EVERDISPLACED"
		local subfig = "b"
	}

	use "$dtadir/analysis.dta", clear

	local outname = lower("`indepvar'")

	qui reg EVERUSEDOPDS `indepvar' i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 ///
		i.COCCP1 i.HIDEG $healthcontrols i.PANEL [pw = LONGWT] if sample == 1, r

	estimates store prob_everused
		
	forvalues i = 2/15 {
		qui reg HAD`i'PLUS `indepvar' i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 ///
		i.COCCP1 i.HIDEG $healthcontrols i.PANEL [pw = LONGWT] if sample == 1, r
		
		estimates store prob_`i'pluspresc
	}

	coefplot (prob_everused, label(Ever used opioids)) ///
		(prob_2pluspresc, label(Had 2+ presc.)) ///
		(prob_3pluspresc, label(Had 3+ presc.)) ///
		(prob_4pluspresc, label(Had 4+ presc.)) ///
		(prob_5pluspresc, label(Had 5+ presc.)) ///
		(prob_6pluspresc, label(Had 6+ presc.)) ///
		(prob_7pluspresc, label(Had 7+ presc.)) ///
		(prob_8pluspresc, label(Had 8+ presc.)) ///
		(prob_9pluspresc, label(Had 9+ presc.)) ///
		(prob_10pluspresc, label(Had 10+ presc.)) ///
		(prob_11pluspresc, label(Had 11+ presc.)) ///
		(prob_12pluspresc, label(Had 12+ presc.)) ///
		(prob_13pluspresc, label(Had 13+ presc.)) ///
		(prob_14pluspresc, label(Had 14+ presc.)) ///
		(prob_15pluspresc, label(Had 15+ presc.)), ///
			keep(`indepvar') xline(0) $gpr  
	graph export "$appxfigures/appxAfig3`subfig'.pdf", replace
}

/*******************************************************************************
	Appendix Figure C.1: Baseline Regression Results of Regressions of All 
		Prescription Count Indicators on Displacement, Controlling Only for 
		Round One Health Status
*******************************************************************************/

estimates clear

foreach indepvar in EVERNONLAYOFFDISPL EVERLAIDOFF EVERDISPLACED {

	if "`indepvar'" == "EVERNONLAYOFFDISPL" {
		local subfig = "a"
	}
	else if "`indepvar'" == "EVERLAIDOFF" {
		local subfig = "c"
	}
	else {
		assert "`indepvar'" == "EVERDISPLACED"
		local subfig = "b"
	}

	use "$dtadir/analysis.dta", clear

	local outname = lower("`indepvar'")

	qui reg EVERUSEDOPDS `indepvar' i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X ///
		i.CIND1 i.COCCP1 i.HIDEG R1PAIN BADMNTLHLTH1 MNTLHLTHMED1 i.PANEL ///
			[pw = LONGWT] if sample == 1, r

	estimates store prob_everused
		
	forvalues i = 2/15 {
		qui reg HAD`i'PLUS `indepvar' i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X ///
		i.CIND1 i.COCCP1 i.HIDEG R1PAIN BADMNTLHLTH1 MNTLHLTHMED1 i.PANEL ///
			[pw = LONGWT] if sample == 1, r
		
		estimates store prob_`i'pluspresc
	}

	coefplot (prob_everused, label(Ever used opioids)) ///
		(prob_2pluspresc, label(Had 2+ presc.)) ///
		(prob_3pluspresc, label(Had 3+ presc.)) ///
		(prob_4pluspresc, label(Had 4+ presc.)) ///
		(prob_5pluspresc, label(Had 5+ presc.)) ///
		(prob_6pluspresc, label(Had 6+ presc.)) ///
		(prob_7pluspresc, label(Had 7+ presc.)) ///
		(prob_8pluspresc, label(Had 8+ presc.)) ///
		(prob_9pluspresc, label(Had 9+ presc.)) ///
		(prob_10pluspresc, label(Had 10+ presc.)) ///
		(prob_11pluspresc, label(Had 11+ presc.)) ///
		(prob_12pluspresc, label(Had 12+ presc.)) ///
		(prob_13pluspresc, label(Had 13+ presc.)) ///
		(prob_14pluspresc, label(Had 14+ presc.)) ///
		(prob_15pluspresc, label(Had 15+ presc.)), ///
			keep(`indepvar') xline(0) $gpr  
	graph export "$appxfigures/appxCfig1`subfig'.png", replace
}

log close