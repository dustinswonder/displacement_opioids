/*******************************************************************************
Project: Effects of Job Displacement on Prescription Opiate Use: Evidence from 
		 the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	01/25/2020
Description: 	This .do file makes appendix tables.
*******************************************************************************/

/*******************************************************************************
	Set environment
*******************************************************************************/

clear

capture log close
log using "$logdir/appx_tables.log", replace

/*******************************************************************************
	Use data from longitudinal files to construct/format key controls
*******************************************************************************/

* Enumerate health control variables
#delimit ;
global healthcontrols "BADMNTLHLTH1 MNTLHLTHMED1 EVERADCLIM EVERADDAYA EVERADILCR  
			EVERADSPEC EVERADRISK EVERADSOCA EVERASPRIN EVERHYSTER EVERAIDHLP  
			EVERUNABLE EVERWLKLIM EVERWRKLIM EVERJTPAIN EVERBENDIF EVERFNGRDF  
			EVERMILDIF EVERRCHDIF EVERSTNDIF EVERWLKDIF EVERIPNGTD EVERDDNWRK";
#delimit cr

/*******************************************************************************
***	SUPPLEMENTAL EXHIBITS ******************************************************
*******************************************************************************/

/*******************************************************************************
	Tables A.1-A.3: Main regression results: Independent variable = (1) ever 
		displaced (2) ever laid off (3) displaced b/c biz dissolved or sold
*******************************************************************************/

/*******************************************************************************
	(I.1) Prepare data to make tables
*******************************************************************************/

* Enumerate health control variables
#delimit ;
global healthcontrols "BADMNTLHLTH1 MNTLHLTHMED1 EVERADCLIM EVERADDAYA EVERADILCR  
			EVERADSPEC EVERADRISK EVERADSOCA EVERASPRIN EVERHYSTER EVERAIDHLP  
			EVERUNABLE EVERWLKLIM EVERWRKLIM EVERJTPAIN EVERBENDIF EVERFNGRDF  
			EVERMILDIF EVERRCHDIF EVERSTNDIF EVERWLKDIF EVERIPNGTD EVERDDNWRK";
#delimit cr

use "$dtadir/analysis.dta", clear

gen BLUECOLLAR = COCCP1 >= 6 & !missing(COCCP1)
gen NONHISP_WHITE = RACEX == 1 & HISPANX == 0
gen BREADWINNER = SHAREINCWAGES >= 0.5
gen ONENOWRKPD = RDSNOWRK > 0 & !missing(RDSNOWRK)

foreach intxn in BLUECOLLAR NONHISP_WHITE ONENOWRKPD FAM_BIZTRST BREADWINNER {
	foreach indepvar in EVERDISPLACED EVERLAIDOFF EVERBIZDISSLD {
		gen `indepvar'x`intxn' = `indepvar' * `intxn'
	}
}

lab var BLUECOLLAR "Blue-collar"
lab var NONHISP_WHITE "Non-Hisp. white"
lab var BREADWINNER "Wage inc. was majority of Y1 family income"
lab var ONENOWRKPD "At lst 1 pd did not work"

tempfile base
save `base'

/*******************************************************************************
	(I.2) Make regression table
*******************************************************************************/

	/***************************************************************************
		(I.2.1) Section 1: Baseline
	***************************************************************************/

foreach indepvar in EVERDISPLACED EVERLAIDOFF EVERBIZDISSLD {

	use `base', clear

	local tabname = lower("`indepvar'")
	local num = 0

	if "`indepvar'" == "EVERDISPLACED" {
		local tablab = "Ever displaced"
		local filename = "appxAtable1"
	}
	else if "`indepvar'" == "EVERLAIDOFF" {
		local tablab = "Ever laid off"
		local filename = "appxAtable2"
	}
	else {
		assert "`indepvar'" == "EVERBIZDISSLD"
		local tablab "Displaced b/c biz disslvd/sold"
		local filename = "appxAtable3"
	}

	foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
		EVER90MME EVER120MME {
			
		local ++num // count model

		g col_`depvar' = ""

		reg `depvar' `indepvar' i.REGION i.AGEGRP i.RACEX i.HISPANX ///
			i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL [pw = LONGWT] ///
			if sample == 1, r
		lincom _b[`indepvar']
		
		replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
		replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
		replace col_`depvar' = string(e(N), "%12.0fc") in 7

		if abs(r(p))< .01 {
			replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
		}
		
		qui summ `depvar' if `indepvar' == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3

		replace col_`depvar' = "(`num')" in 8
	}

	#delimit ;

	gen tab = "\begin{tabular}{lccc|ccc}" in 1 ;
	gen top = "\toprule" in 1 ;

	*Midrule ;
	gen mid = "  \midrule " in 1 ;
	gen hline = " \hline" in 1 ;

	*Bottomrule ;
	gen bot = "  \bottomrule" in 1 ;

	*End ;
	gen end = "\end{tabular}" in 1 ;

	gen title0 = " & \multicolumn{3}{c}{Panel A: Opioid Count Outcomes} & \multicolumn{3}{c}{Panel B: MME per Day Outcomes}" in 1 ;

	gen title1 = " & Ever used opds & Rcvd. $\geq$ 6 opd. prsc. & Rcvd. $\geq$ 12 opd. prsc. 
			& Ever 60+ MME/day & Ever 90+ MME/day & Ever 120+ MME/day" in 1 ;

	gen section1 = "\multicolumn{4}{l|}{\textit{Section 1. Baseline}} & & " in 1 ;
				
	gen labels = "`tablab'" ;
	replace labels = "" in 2 ;
	replace labels = " \textcolor{gray}{Mean of outcome} " in 3 ;
	replace labels = "Observations" in 7 ;
	replace labels = "" in 8;

	listtex tab if _n == 1 using "$appxtables/`filename'.tex", replace rstyle(none) ;
	listtex top if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;	
	listtex title0 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
	listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
	listtex title1 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
	listtex labels col_* if _n == 8, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;

	listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;

	listtex section1 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
	listtex labels col_* if  inrange(_n, 1, 3), appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
	listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
	#delimit cr

	/***************************************************************************
		(I.2.2) Sections 2-6: Interaction Regressions
	***************************************************************************/

	local secnum = 2 // For numbering sections of the table

	foreach intxn in BLUECOLLAR NONHISP_WHITE ONENOWRKPD FAM_BIZTRST BREADWINNER {

		/***********************************************************************
			(I.2.2.1) Makes sure we have correct labels for text parts of table
		***********************************************************************/

		local intxnlab : variable label `intxn'
		local lower_intxnlab = lower("`intxnlab'")

		local upper_not_category_cap = "Not " + lower("`lower_intxnlab'")

		local controls = "i.REGION i.AGEGRP i.RACEX i.HISPANX `intxn' i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL"

		if "`intxn'" == "BLUECOLLAR" {
			local controls = "i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 BLUECOLLAR i.HIDEG $healthcontrols i.PANEL"
			local upper_not_category_cap = "White-collar"
			local seclab = "occupation"
		} 
		else if "`intxn'" == "NONHISP_WHITE" {
			local controls = "i.REGION i.AGEGRP NONHISP_WHITE i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL"
			local seclab = "race/ethnicity"
		}
		else if "`intxn'" == "ONENOWRKPD" {
			local upper_not_category_cap = "Worked all ref pds"
			local seclab = "whether individual did not work for at least one period"
		}
		else if "`intxn'" == "FAM_BIZTRST" {
			local upper_not_category_cap = "No fam biz/trust inc."
			local seclab = "whether dwelling unit has business/trust income"
		}
		else {
			assert "`intxn'" == "BREADWINNER"
			local upper_not_category_cap = "Wage inc. not majority of Y1 family inc."
			local seclab = "share of dwelling unit income from individuals' wage income"
		}	

		local lower_not_category_cap = lower("`upper_not_category_cap'")

		drop col* section labels
		 
		/***********************************************************************
			(I.2.2.2) Run regressions and make table
		***********************************************************************/

		local num = 0
		foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
			EVER90MME EVER120MME {

			local ++num // count model

			g col_`depvar' = ""
			
			reg `depvar' `indepvar' `indepvar'x`intxn' `controls' ///
				[pw = LONGWT] if sample == 1, r
			lincom _b[`indepvar']
			
			replace col_`depvar'  =  string(r(estimate), "%9.3f") in 4
			replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 5
			replace col_`depvar' = string(e(N), "%12.0fc") in 7

			if abs(r(p))< .01 {
				replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 4
			}
			if abs(r(p)) < .05 & abs(r(p)) >= .01 {
				replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 4
			}
			if abs(r(p)) < .1 & abs(r(p)) >= .05 {
				replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 4
			}
			
			qui summ `depvar' if `indepvar' == 1
			replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6
			
			* blue collar
			lincom _b[`indepvar'] + _b[`indepvar'x`intxn']

			replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
			replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
			replace col_`depvar' = string(e(N), "%12.0fc") in 7

			if abs(r(p))< .01 {
				replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
			}
			if abs(r(p)) < .05 & abs(r(p)) >= .01 {
				replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
			}
			if abs(r(p)) < .1 & abs(r(p)) >= .05 {
				replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
			}

			qui summ `depvar' if `indepvar'x`intxn' == 1
			replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
			
			replace col_`depvar' = "(`num')" in 8
		}

		#delimit ;
		gen section = "\multicolumn{4}{l|}{\textit{Section `secnum'. Heterogeneity by `seclab'}} & & " in 1 ;
		#delimit cr

		g labels = ""
		replace labels = "`intxnlab'" in 1
		replace labels = " \textcolor{gray}{Mean of outcome (`lower_intxnlab')} " in 3
		replace labels = "`upper_not_category_cap'" in 4
		replace labels = " \textcolor{gray}{Mean of outcome (`lower_not_category_cap')} " in 6
		replace labels = "Observations" in 7 

		listtex section if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)
		listtex labels col_* if  inrange(_n, 1, 6), appendto("$appxtables/`filename'.tex") ///
			rstyle(tabular)
		listtex hline if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)

		if `secnum' == 6 { // Last section 
			listtex labels col_* if  _n == 7, appendto("$appxtables/`filename'.tex") ///
				rstyle(tabular)
		}
		
		local secnum = `secnum' + 1

	}

	listtex bot if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)
	listtex end if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)
}

/********************************************************************************
	Table A.3: Heterogeneity by round one pain, all displacement types
********************************************************************************/

use "$dtadir/analysis.dta", clear

* Prep data
foreach indepvar in EVERDISPLACED EVERLAIDOFF EVERNONLAYOFFDISPL {
	gen `indepvar'xBADMNTLHLTH1 = `indepvar' * BADMNTLHLTH1
}

label variable BADMNTLHLTH1 "Fair/poor R1 m. hlth"

het_regtable, intxn("BADMNTLHLTH1") /// program
	controls("i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL") ///
	not_category_cap("Good or better R1 m. hlth") saveas("$appxtables/appxAtable4")

/********************************************************************************
	Table A.4: Heterogeneity by self-reported round one mental health status, 
		all displacement types
********************************************************************************/

use "$dtadir/analysis.dta", clear

* Prep data
foreach indepvar in EVERDISPLACED EVERLAIDOFF EVERNONLAYOFFDISPL {
	gen `indepvar'xMNTLHLTHMED1 = `indepvar' * MNTLHLTHMED1
}

het_regtable, intxn("MNTLHLTHMED1") /// program
	controls("i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL") ///
	not_category_cap("No R1 antidep./antipsy. presc.") saveas("$appxtables/appxAtable5")
	
/********************************************************************************
	Table A.5: Heterogeneity by receipt of antidepressant/antipsychotic in round 
		one, all displacement types
********************************************************************************/

use "$dtadir/analysis.dta", clear

* Prep data
foreach indepvar in EVERDISPLACED EVERLAIDOFF EVERNONLAYOFFDISPL {
	gen `indepvar'xR1PAIN = `indepvar' * R1PAIN
}

label variable R1PAIN "Had R1 pain"

het_regtable, intxn("R1PAIN") ///
	controls("i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL") ///
	not_category_cap("No R1 pain") saveas("$appxtables/appxAtable6")

/********************************************************************************
	Table C.1: Baseline regression results, controlling only for round one 
		health status, all displacement types
********************************************************************************/

		/***********************************************************************
			Baseline with only R1 health controls
		***********************************************************************/
	
use "$dtadir/analysis.dta", clear

			/*******************************************************************
				Panel A: Independent variable = ever displaced
			*******************************************************************/

local num = 0
foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
	EVER90MME EVER120MME {
	local ++num // count model

	g col_`depvar' = ""
	
	reg `depvar' EVERDIS i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 ///
		i.COCCP1 i.HIDEG R1PAIN BADMNTLHLTH1 MNTLHLTHMED1 i.PANEL [pw = LONGWT] ///
		if sample == 1, r
	lincom _b[EVERDIS]
	
	replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
	replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
	replace col_`depvar' = string(e(N), "%12.0fc") in 7

	if abs(r(p))< .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
	}
	if abs(r(p)) < .05 & abs(r(p)) >= .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
	}
	if abs(r(p)) < .1 & abs(r(p)) >= .05 {
		replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
	}
	
	qui summ `depvar' if EVERDIS == 1
	replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3

	replace col_`depvar' = "(`num')" in 8
}

#delimit ;

gen tab = "\begin{tabular}{lccc|ccc}" in 1 ;
gen top = "\toprule" in 1 ;

*Midrule ;
gen mid = "  \midrule " in 1 ;
gen hline = " \hline" in 1 ;

*Bottomrule ;
gen bot = "  \bottomrule" in 1 ;

*End ;
gen end = "\end{tabular}" in 1 ;

gen title0 = " & \multicolumn{3}{c}{Panel A: Opioid Count Outcomes} & \multicolumn{3}{c}{Panel B: MME per Day Outcomes}" in 1 ;

gen title1 = " & Ever used opds & Rcvd. $\geq$ 6 opd. prsc. & Rcvd. $\geq$ 12 opd. prsc. 
		& Ever 60+ MME/day & Ever 90+ MME/day & Ever 120+ MME/day \\" in 1 ;

gen section1 = "\multicolumn{4}{l|}{\textit{Section 1. Independent variable = individual
			ever displaced}} & & " in 1 ;

gen labels = "Ever displaced" ;
replace labels = "" in 2 ;
replace labels = " \textcolor{gray}{Mean of outcome} " in 3 ;
replace labels = "Observations" in 7 ;
replace labels = "" in 8;
	 
local filename = "appxCtable1" ;

listtex tab if _n == 1 using "$appxtables/`filename'.tex", replace rstyle(none) ;
listtex top if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;	
listtex title0 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
listtex title1 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
listtex labels col_* if _n == 8, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;

listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;

listtex section1 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
listtex labels col_* if  inrange(_n, 1, 3), appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
#delimit cr
	 
			/*******************************************************************
				Panel B: Independent variable = ever laid off
			*******************************************************************/
	 
drop col*
	 
local num = 0
foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
	EVER90MME EVER120MME {

	local ++num // count model

	g col_`depvar' = ""
	
	reg `depvar' EVERLAIDOFF i.REGION i.AGEGRP i.RACEX i.HISPANX i.MARRY1X i.CIND1 ///
		i.COCCP1 i.HIDEG R1PAIN BADMNTLHLTH1 MNTLHLTHMED1 i.PANEL ///
		[pw = LONGWT] if sample == 1, r
	lincom _b[EVERLAIDOFF]
	
	replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
	replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
	replace col_`depvar' = string(e(N), "%12.0fc") in 7

	if abs(r(p))< .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
	}
	if abs(r(p)) < .05 & abs(r(p)) >= .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
	}
	if abs(r(p)) < .1 & abs(r(p)) >= .05 {
		replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
	}
	
	qui summ `depvar' if EVERLAIDOFF == 1
	replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3

	replace col_`depvar' = "(`num')" in 8
}

#delimit ;
gen section2 = "\multicolumn{4}{l|}{\textit{Section 2. Independent variable = individual
			ever displaced}} & & " in 1 ;

drop labels ;
			
gen labels = "Ever laid off" ;
replace labels = "" in 2 ;
replace labels = " \textcolor{gray}{Mean of outcome} " in 3 ;
replace labels = "Observations" in 7 ;

listtex section2 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular)	;
listtex labels col_* if  inrange(_n, 1, 3), appendto("$appxtables/`filename'.tex") rstyle(tabular) ;
listtex mid if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none)	;
#delimit cr
	 
			/*******************************************************************
				Panel C: Independent variable = ever non-layoff displaced
			*******************************************************************/
	 
drop col*
	 
local num = 0
foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
	EVER90MME EVER120MME {

	local ++num // count model

	g col_`depvar' = ""
	
	reg `depvar' EVERNONLAYOFFDISPL i.REGION i.AGEGRP i.RACEX i.HISPANX ///
		i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG R1PAIN BADMNTLHLTH1 MNTLHLTHMED1 i.PANEL ///
		[pw = LONGWT] if sample == 1, r
	lincom _b[EVERNONLAYOFFDISPL]
	
	replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
	replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
	replace col_`depvar' = string(e(N), "%12.0fc") in 7

	if abs(r(p))< .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
	}
	if abs(r(p)) < .05 & abs(r(p)) >= .01 {
		replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
	}
	if abs(r(p)) < .1 & abs(r(p)) >= .05 {
		replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
	}
	
	qui summ `depvar' if EVERNONLAYOFFDISPL == 1
	replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3

	replace col_`depvar' = "(`num')" in 8
}

#delimit ;
gen section3 = "\multicolumn{4}{l|}{\textit{Section 3. Independent variable = individual
			ever non-layoff displaced}} & & " in 1 ;

drop labels ;
			
gen labels = "Ever non-layoff displaced" ;
replace labels = "" in 2 ;
replace labels = " \textcolor{gray}{Mean of outcome} " in 3 ;
replace labels = "Observations" in 7 ;

listtex section3 if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(tabular) ;
listtex labels col_* if  inrange(_n, 1, 3), appendto("$appxtables/`filename'.tex") rstyle(tabular) ;
listtex hline if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none) ;
listtex labels col_* if _n == 7, appendto("$appxtables/`filename'.tex") rstyle(tabular) ;
listtex bot if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none) ;
listtex end if _n == 1, appendto("$appxtables/`filename'.tex") rstyle(none) ;
#delimit cr