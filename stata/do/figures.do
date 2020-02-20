/*******************************************************************************
Project: 		Effects of Job Displacement on Prescription Opiate Use: Evidence from 
				 the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	02/19/2020
Description: 	This .do file makes figures for the paper.
*******************************************************************************/

global gpr = "plotregion(color(white) margin(small)) graphregion(color(white))"
 
/*******************************************************************************
	Figure 2: Opioid prescribing rate over time, by data source 
*******************************************************************************/

use "$dtadir/analysis.dta", clear

gen n = 1 

collapse (sum) OPDTOTAL OPDTOTAL_INCL_MAT NONCOUGHOPDTOTAL n [aw = LONGWT], by(PRIMARY_YEAR)

gen OPDPRSC_PER_100_MEPS = OPDTOTAL / (n / 100)
gen ALLOPDPRSC_PER_100_MEPS = OPDTOTAL_INCL_MAT / (n / 100)
gen NONCOUGHOPDPRSC_PER_100_MEPS = NONCOUGHOPDTOTAL / (n / 100)

label variable OPDPRSC_PER_100_MEPS "Non-MAT opioid prescriptions/100 MEPS participants"
label variable ALLOPDPRSC_PER_100_MEPS "All opioid prescriptions/100 MEPS participants"
label variable NONCOUGHOPDPRSC_PER_100_MEPS "Non-cough opd presc./100 MEPS participants"

/* Manually input prescribing rates from CDC via IQVIA
	SOURCE: https://www.cdc.gov/drugoverdose/maps/rxrate-maps.html */
gen OPDPRSC_PER_100_IQVIA = cond(PRIMARY_YEAR == 2006, 72.4, ///
							cond(PRIMARY_YEAR == 2007, 75.9, ///
							cond(PRIMARY_YEAR == 2008, 78.2, ///
							cond(PRIMARY_YEAR == 2009, 79.5, ///
							cond(PRIMARY_YEAR == 2010, 81.2, ///
							cond(PRIMARY_YEAR == 2011, 80.9, ///
							cond(PRIMARY_YEAR == 2012, 81.3, ///
							cond(PRIMARY_YEAR == 2013, 78.1, ///
							cond(PRIMARY_YEAR == 2014, 75.6, ///
							cond(PRIMARY_YEAR == 2015, 70.6, ///
							cond(PRIMARY_YEAR == 2016, 66.5, 58.7)))))))))))

twoway (scatter ALLOPDPRSC_PER_100_MEPS PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lp(-) lcolor(maroon) ms(o) mcolor(maroon)) ///
	(scatter OPDPRSC_PER_100_MEPS PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lp(1) lcolor(maroon) ms(o) mcolor(maroon)) ///
	(scatter NONCOUGHOPDPRSC_PER_100_MEPS PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lcolor(maroon) lpattern(_) ms(S) mcolor(maroon)) ///
	(scatter OPDPRSC_PER_100_IQVIA PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lcolor(blue) ms(S) mcolor(blue)), $gpr ytitle("Opioid prescriptions/100 individuals") ///
	legend(label(1 "MEPS, all opioids") label(2 "MEPS, non-MAT opioids") ///
		label(3 "MEPS, non-cough opioids") label(4 "CDC via IQVIA") region(lcolor(white)))
graph export "$figs/fig2.pdf", replace 

/*******************************************************************************
	Figure 3: Share prescriptions linked to prime-age individuals by inclusion 
		in analysis sample, 1999-2017
*******************************************************************************/

use "$dtadir/analysis.dta", clear

drop if PANEL < 4

gen n = AGEGRP > 0
gen n_mme = AGEGRP > 0 & PANEL > 14
	
collapse (rawsum) OPDTOTAL TOTAL120PLUSMME n n_mme, by(sample)

label define sample 1 "Analysis sample" 0 "Prime-age, not analysis sample"
label values sample sample

foreach variable in OPDTOTAL TOTAL120PLUSMME n n_mme {
	qui summ `variable'
	gen proportion_`variable' = (`variable' / r(sum)) * 100
}

foreach countvar in OPDTOTAL TOTAL120PLUSMME {

	if regexm("`countvar'", "120") {
		local labelsupp = " 120+ MME/day"
		local samplecount = "n_mme"
		local samplenote = " (Panel > 14)"
		local subfig = "b"
	} 
	else {
		local labelsupp = ""
		local samplecount = "n"
		local samplenote = ""
		local subfig = "a"
	}
	
	local filename = lower("`countvar'")
		
	* Proportions of opioid prescriptions, individuals
	graph bar proportion_`countvar' proportion_`samplecount', over(sample) $gpr ///
		legend(label(1 "Sh`labelsupp' opioid presc. rcvd by prime-age ind.`samplenote'") ///
			label(2 "Sh prime-age individuals`samplenote'") rows(2) region(lcolor(white))) 
	graph export "$figs/fig3`subfig'.pdf", replace
}