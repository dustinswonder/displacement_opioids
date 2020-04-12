/*******************************************************************************
Project: 		Effects of Job Displacement on Prescription Opiate Use: Evidence from 
				 the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	04/09/2020
Description: 	This .do file makes figures for the paper.
*******************************************************************************/

global gpr = "plotregion(color(white) margin(small)) graphregion(color(white))"

/*******************************************************************************
	Figure 2: Waterfall for sample inclusion with proportions
*******************************************************************************/
 
	/***************************************************************************
		(2.1) Load in analysis data set and compute total of all individuals, 
			plus counts under four sets of restrictions:
			a. panel >= 4 (where health status information becomes available)
			b. prime-age + panel >= 4
			c. no first-round opioid use + prime-age + panel >= 4
			d. sample (a-c restrictions plus no missing data)
	***************************************************************************/

use $dtadir/analysis.dta, clear

		/***********************************************************************
			(2.1.1) Get number of individuals in total represented in MEPS
		***********************************************************************/

qui summ LONGWT, meanonly

local alldata = `r(sum)'

		/***********************************************************************
			(2.1.2) Get number of individuals in total represented in MEPS
				panel 4 onward
		***********************************************************************/

qui summ LONGWT if PANEL >= 4 

local panel4on = `r(sum)'

		/***********************************************************************
			(2.1.3) Get number of prime-age panel 4+ individuals in US
		***********************************************************************/

qui summ LONGWT if AGEGRP > 0 & PANEL >= 4, meanonly

local primeage = `r(sum)'

		/***********************************************************************
			(2.1.4) Get number of prime-age panel 4+ individuals with no opioid
				prescriptions in the first round of the MEPS
		***********************************************************************/

qui summ LONGWT if AGEGRP > 0 & OPDCNT1 == 0 & PANEL >= 4, meanonly

local primeagenoopd = `r(sum)'

		/***********************************************************************
			(2.1.5) Get number of prime-age panel 4+ individuals with no opioid
				prescriptions in the first round of the MEPS
		***********************************************************************/

qui summ LONGWT if AGEGRP > 0 & OPDCNT1 == 0 & PANEL >= 4 & EMPST1 == 1, meanonly

local primeagenoopdemp = `r(sum)'

		/***********************************************************************
			(2.1.6) Get number of individuals in sample (will be same as 2.1.4
				except no missing data).
		***********************************************************************/

qui summ LONGWT if sample == 1, meanonly

local samp = `r(sum)'

	/***************************************************************************
		(2.2) Compute statistics for graph
	***************************************************************************/

		/***********************************************************************
			(2.2.1) Initialize variables we're going to put in graph: group 
				name, group total individuals, proportion of all individuals in
				in MEPS, proportion of individuals from panel 4-onwards, and 
				proportion of prime-age individuals from panel 4-onwards.
		***********************************************************************/

gen grpname = "All" in 1
gen grp_total = `alldata' in 1
gen prop_all = 100 in 1

gen prop_4onward = . if inrange(_n, 1, 6)
gen prop_primeage4onward = . if inrange(_n, 1, 6)

		/***********************************************************************
			(2.2.2) Cycling through groups on individuals from 2.1.1-2.1.5, 
				fill in each of variables initialized in 2.2.1
		***********************************************************************/

local row = 2
foreach grp in panel4on primeage primeagenoopd primeagenoopdemp samp {

	replace grpname = "`grp'" in `row'
	replace grp_total = ``grp'' in `row'
	replace prop_all = (``grp'' / `alldata') * 100 in `row'

	if !inlist("`grp'", "panel4on", "primeage") {
		replace prop_primeage = (``grp'' / `primeage') * 100 in `row'
	}
	if "`grp'" != "panel4on" {
		replace prop_4onward = (``grp'' / `panel4on') * 100 in `row'
	}
	local row = `row' + 1
}

		/***********************************************************************
			(2.2.3) Drop redundant variables and rows: keep only group names and
				proportions
		***********************************************************************/

keep grpname prop_*

drop if _n > 6 | _n == 1

	/***************************************************************************
		(2.3) Do quite a bit of format fineggling so that graph will work
	***************************************************************************/

assert grpname[1] == "panel4on"
gen line_midpt = (prop_all[1] / 2) + 10

foreach propvar in all 4onward primeage {
	gen dot_top_`propvar' = line_midpt + (prop_`propvar' / 2)
	gen dot_bot_`propvar' = line_midpt - (prop_`propvar' / 2)
}

gen xpos = _n
gen xpos_4onward = _n + 0.25
gen xpos_primeage = _n + 0.5

reshape long dot_top dot_bot, i(grpname prop_* line_midpt) j(proptype, string)
reshape long dot, i(grpname prop_* line_midpt proptype) j(pos, string) 

replace proptype = subinstr(proptype, "_", "", 1)

replace xpos = xpos_4onward if proptype == "4onward"
replace xpos = xpos_primeage if proptype == "primeage"
drop xpos_*

format prop_* %9.1fc

gen missingx = .
gen missingy = .

foreach propvar of varlist prop_* {
	rename `propvar' `propvar'_num
	gen `propvar' = cond(missing(`propvar'_num), "", string(round(`propvar'_num, 0.1)))
	drop `propvar'_num
}

	/***************************************************************************
		(2.4) Make graph (I know, this code looks crazy)
	***************************************************************************/

twoway (scatter missingx missingy, c(l) msym(O) mcolor(gs7) lcolor(gs7)) ///
	(scatter missingx missingy, c(l) msym(T) mcolor(gs7) lcolor(gs7) lpattern(_)) ///
	(scatter missingx missingy, c(l) msym(S) mcolor(gs7) lcolor(gs7) lpattern(-)) ///
	(scatter dot xpos if proptype == "all" & grpname == "panel4on", ///
		c(l) mcolor(maroon) lcolor(maroon) lpattern(1)) ///
	(scatter dot xpos if proptype == "all" & grpname == "primeage", ///
		c(l) mcolor(navy) lcolor(navy) lpattern(1)) ///
	(scatter dot xpos if proptype == "all" & grpname == "primeagenoopd", ///
		c(l) mcolor(midblue) lcolor(midblue) lpattern(1)) ///
	(scatter dot xpos if proptype == "all" & grpname == "primeagenoopdemp", ///
		c(l) mcolor(ltblue) lcolor(ltblue) lpattern(1)) ///
	(scatter dot xpos if proptype == "all" & grpname == "samp", ///
		c(l) mcolor(gs13) lcolor(gs13) lpattern(1)) ///
	(scatter dot xpos if proptype == "4onward" & grpname == "primeage", ///
		c(l) msym(T) mcolor(navy) lcolor(navy) lpattern(_)) ///
	(scatter dot xpos if proptype == "4onward" & grpname == "primeagenoopd", ///
		c(l) msym(T) mcolor(midblue) lcolor(midblue) lpattern(_)) ///
	(scatter dot xpos if proptype == "4onward" & grpname == "primeagenoopdemp", ///
		c(l) msym(T) mcolor(ltblue) lcolor(ltblue) lpattern(_)) ///
	(scatter dot xpos if proptype == "4onward" & grpname == "samp", ///
		c(l) msym(T) mcolor(gs13) lcolor(gs13) lpattern(_)) ///
	(scatter dot xpos if proptype == "primeage" & grpname == "primeagenoopd", ///
		c(l) msym(S) mcolor(midblue) lcolor(midblue) lpattern(-)) ///
	(scatter dot xpos if proptype == "primeage" & grpname == "primeagenoopdemp", ///
		c(l) msym(S) mcolor(ltblue) lcolor(ltblue) lpattern(-)) ///
	(scatter dot xpos if proptype == "primeage" & grpname == "samp", ///
		c(l) msym(S) mcolor(gs13) lcolor(gs13) lpattern(-)) ///
	(scatter line_midpt xpos if proptype == "all", ///
		mlab(prop_all) mlabsize(vsmall)  ms(none) mlabcolor(black) mlabpos(0)) ///
	(scatter line_midpt xpos if proptype == "4onward", ///
		mlab(prop_4onward) mlabsize(vsmall) ms(none) mlabcolor(black) mlabpos(0)) ///
	(scatter line_midpt xpos if proptype == "primeage", ///
		mlab(prop_primeage) mlabsize(vsmall) ms(none) mlabcolor(black) mlabpos(0)), ///
	$gpr ysc(off) xsc(range(0.5 6)) ///
	xtitle(" ") ylab(,nogrid) ysize(9) xsize(12) ///
	xlab(1 "Panel 4 onward" 2.25 "Prime-age" 3.25 "No R1 opds" 4.25 "Employed R1" 5.25 "Sample") ///
	legend(row(3) order(1 "% all MEPS participants" 2 "% panel 4+" 3 "% prime-age panel 4+") ///
		region(lcolor(white)) bmargin(zero))
graph export "$figs/fig2.pdf", replace

/*******************************************************************************
	Figure 3: Opioid prescribing rate over time, by data source 
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
	c(l) lp(-) lcolor(maroon) ms(none) mcolor(maroon)) ///
	(scatter OPDPRSC_PER_100_MEPS PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lp(1) lcolor(maroon) ms(none) mcolor(maroon)) ///
	(scatter NONCOUGHOPDPRSC_PER_100_MEPS PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lcolor(maroon) lpattern(_) ms(none) mcolor(maroon)) ///
	(scatter OPDPRSC_PER_100_IQVIA PRIMARY_YEAR if inrange(PRIMARY_YEAR, 2006, 2016), ///
	c(l) lcolor(blue) ms(none) mcolor(blue)), $gpr ytitle("Opioid prescriptions/100 individuals") ///
	legend(label(1 "MEPS, all opioids") label(2 "MEPS, non-MAT opioids") ///
		label(3 "MEPS, non-cough opioids") label(4 "CDC via IQVIA") region(lcolor(white)))
graph export "$figs/fig3.pdf", replace

/*******************************************************************************
	Figure 4: Share prescriptions linked to prime-age individuals by inclusion 
		in analysis sample, 1999-2017
*******************************************************************************/

use "$dtadir/analysis.dta", clear

drop if PANEL < 4

gen n = cond(AGEGRP > 0, LONGWT, 0)
gen n_mme = cond(AGEGRP > 0 & PANEL > 14, LONGWT, 0)
	
collapse (rawsum) OPDTOTAL TOTAL120PLUSMME n n_mme, by(sample)

label define sample 1 "Analysis sample" 0 "Prime-age, not analysis sample"
label values sample sample

foreach variable in OPDTOTAL TOTAL120PLUSMME n n_mme {
	qui summ `variable'
	gen proportion_`variable' = (`variable' / r(sum)) * 100
	gen proportion_`variable'_lab = string(round(proportion_`variable', 0.01)) + "%"
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
	graph bar proportion_`countvar' proportion_`samplecount', over(sample) ///
		blabel(bar, position(inside) color(white) format(%9.1fc)) $gpr ///
		legend(label(1 "Sh`labelsupp' opioid presc. rcvd by prime-age ind.`samplenote'") ///
			label(2 "Sh prime-age individuals`samplenote'") rows(2) ///
			region(lcolor(white)))  ytitle("Percent")
	graph export "$figs/fig4`subfig'.pdf", replace
}