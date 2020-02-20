/*******************************************************************************
Project: 		Effects of Job Displacement on Prescription Opiate Use: Evidence 
				from the Medical Expenditure Panel Survey
Created by: 	Dustin Swonder
Last modified: 	01/25/2020
Description: 	This .do file makes tables for the paper.
*******************************************************************************/

/*******************************************************************************
	Set environment
*******************************************************************************/

clear

capture log close
log using "$logdir/tables_slim.log", replace

/*******************************************************************************
	SUMMARY STATISTICS (Tables 1-2)
*******************************************************************************/

	/***************************************************************************
		Table 1: Demographics, industry and occupation, health status
	***************************************************************************/

use "$dtadir/analysis.dta", clear
	
/* Format categorical variables so that we can get means and standard deviations 
	as indicators */
foreach variable in REGION AGEGRP SEX RACEX HISPANX MARRY1X HIDEG COCCP1 CIND1 {
	tempvar `variable'_temp 
	qui gen ``variable'_temp' = cond(`variable' < 0, ., `variable')
	qui levelsof ``variable'_temp', local(levels)
	local lbe : value label `variable'
	
	foreach l of local levels {
		qui gen `variable'GRP`l' = `variable' == `l'
		local f`l' : label `lbe' `l'
		local `variable'`l' = "`f`l''"
		if inlist("`variable'", "COCCP1", "CIND1") {
			forv i = 0/9 {
				local `variable'`l' = ltrim(subinstr("``variable'`l''", "`i'", "", .))
			}
		}
		label variable `variable'GRP`l' "``variable'`l''" 
		if inlist("`variable'", "COCCP1", "CIND1") {
			local `variable'GRP`l' = proper("``variable'`l''")
		}
		else {
			local `variable'GRP`l' = "``variable'`l''"
		}
		
	}
}

foreach variable in $healthcontrols {
	local `variable' : variable label `variable'
}

qui gen primeage = AGEGRP > 0
qui replace mme_per_day_sample = mme_per_day_sample == 1 & sample == 1
qui gen Observations = 1

foreach samp_restriction in primeage samp mme_per_day_sample {

	preserve

	qui drop if `samp_restriction' == 0 | AGEGRP < 0

	qui collapse (mean) REGIONGRP? AGEGRPGRP? SEXGRP? RACEXGRP? HISPANXGRP? MARRY1XGRP? ///
		HIDEGGRP? /// Demographics
		CIND1GRP* COCCP1GRP* /// Industry/occupation of R1 employment
		$healthcontrols	/// Health status
		(rawsum) Observations [aw = LONGWT]

	tempfile `samp_restriction'
	save ``samp_restriction''

	restore
}

use `primeage', clear
append using `samp'
append using `mme_per_day_sample'

qui ds
local grp_fmt_vars = "`r(varlist)'"

xpose, clear varname

rename (v1 v2 v3 _varname) (primeage samp mme_samp name)

qui gen vargrp = substr(name, 1, strpos(name, "GRP") - 1)
qui replace vargrp = "DISPLACED" if regexm(name, "DISPLACED") | regexm(name, "LAIDOFF") | ///
					regexm(name, "NONLAYOFF")
qui replace vargrp = "HEALTH" if vargrp == "" & name != "Observations"
qui replace vargrp = "Observations" if name == "Observations"

foreach variable in `grp_fmt_vars' {
	qui replace name = "``variable''" if name == "`variable'" & "``variable''" != ""
}

foreach column in primeage samp mme_samp {
	qui replace `column' = round(`column' * 100, 0.1) if name != "Observations"
	qui gen `column'_obs = cond(name == "Observations", `column', .n)
}

qui replace name = "\multicolumn{2}{l}{" + name + "}" if ///
	!inlist(vargrp, "REGION", "AGE", "SEX", "RACEX", "HISPANX", "MARRY1X", "HIDEG")

format primeage samp mme_samp %9.1fc
format primeage_obs samp_obs mme_samp_obs %9.0fc

qui gen tab = "\begin{tabular}{lllrrr}" in 1
qui gen end = "\end{tabular}"
qui gen c = " "

qui gen hline = "\hline" in 1

qui gen title0 =  "& & & \multicolumn{3}{c}{Proportions of MEPS participants (\%)}" in 1
qui gen title1 =  "& & & All prime-age in MEPS & Analysis sample & MME analysis sample (2010+)" in 1

qui gen section1 = "\multicolumn{6}{l}{\textit{Section 1. Demographic characteristics}}" in 1

qui gen region = "& \multicolumn{5}{l}{\textit{U.S. Census Region}}" in 1
qui gen agegrp = "& \multicolumn{5}{l}{\textit{Ten-Year Age Group}}" in 1
qui gen sex = "& \multicolumn{5}{l}{\textit{Sex}}" in 1
qui gen race = "& \multicolumn{5}{l}{\textit{Race}}" in 1
qui gen ethnicity = "& \multicolumn{5}{l}{\textit{Ethnicity}}" in 1
qui gen marital = "& \multicolumn{5}{l}{\textit{Marital status}}" in 1
qui gen education = "& \multicolumn{5}{l}{\textit{Educational attainment}}" in 1

qui gen section2 = "\multicolumn{6}{l}{\textit{Section 2. Industry of round one employment}}" in 1

qui gen section3 = "\multicolumn{6}{l}{\textit{Section 3. Occupation of round one employment}}" in 1

qui gen section4 = "\multicolumn{6}{l}{\textit{Section 4. Health status}}" in 1

qui gen opdcnt = "& \multicolumn{5}{l}{\textit{Prescription counts}}" in 1
qui gen mmeperday = "& \multicolumn{5}{l}{\textit{High MME per day prescriptions}}" in 1

local filename = "table1"

listtex tab if _n == 1 using "$tables/`filename'.tex", replace rstyle(none)
listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	

listtex title0 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	
listtex title1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	
listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)

listtex section1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex region if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "REGION", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex agegrp if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "AGE", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex sex if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "SEX", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex race if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "RACEX", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex ethnicity if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "HISPANX", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex marital if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "MARRY1X", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex education if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "HIDEG", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex section2 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c name primeage samp mme_samp if vargrp == "CIND1", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex section3 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c name primeage samp mme_samp if vargrp == "COCCP1", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex section4 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c name primeage samp mme_samp if vargrp == "HEALTH", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)

listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	

listtex c name primeage_obs samp_obs mme_samp_obs if vargrp == "Observations", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)

listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	
listtex end if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)

	/***************************************************************************
		Table 2: Displacement and opioid use
	***************************************************************************/

use "$dtadir/analysis.dta", clear

qui gen primeage = AGEGRP > 0
qui replace mme_per_day_sample = mme_per_day_sample == 1 & sample == 1
qui gen Observations = 1

foreach samp_restriction in primeage samp mme_per_day_sample {

	preserve

	qui drop if `samp_restriction' == 0 | AGEGRP < 0

	qui collapse (mean) EVERDISPLACED EVERLAIDOFF EVERNONLAYOFFDISPL /// Displacement 
		EVERUSEDOPDS HAD6PLUS HAD12PLUS EVER*MMEPERDAY /// Opioid use 
		(rawsum) Observations [aw = LONGWT]

	tempfile `samp_restriction'
	save ``samp_restriction''

	restore
}

use `primeage', clear
append using `samp'
append using `mme_per_day_sample'

qui ds
local grp_fmt_vars = "`r(varlist)'"

xpose, clear varname

rename (v1 v2 v3 _varname) (primeage samp mme_samp name)

gen vargrp = "DISPLACED" if regexm(name, "DISPLACED") | regexm(name, "LAIDOFF") | ///
					regexm(name, "NONLAYOFF")
qui replace vargrp = cond(regexm(name, "MME"), "MME", "OPDCNT") if vargrp == "" & name != "Observations"
qui replace vargrp = "Observations" if name == "Observations"

qui replace name = "Displaced" if name == "EVERDISPLACED"
qui replace name = "Laid off" if name == "EVERLAIDOFF"
qui replace name = "Displaced b/c bus. diss. or sold/job ended" if name == "EVERNONLAYOFFDISPL"

qui replace name = "Accumulated one or more opioid prescriptions" if name == "EVERUSEDOPDS"

forv opdcnt = 6(6)12 {
	qui replace name = "Accumulated `opdcnt' or more opioid prescriptions" ///
		if name == "HAD`opdcnt'PLUSOPDPRSC"
}

forv mme = 60(30)120 {
	qui replace name = "Ever had a prescription for greater than `mme' MME per day" ///
		if name == "EVER`mme'MMEPERDAY" 
}

foreach column in primeage samp mme_samp {
	qui replace `column' = round(`column' * 100, 0.1) if name != "Observations"
	qui gen `column'_obs = cond(name == "Observations", `column', .n)
}

qui replace name = "\multicolumn{2}{l}{" + name + "}" if !inlist(vargrp, "OPDCNT", "MME")

format primeage samp mme_samp %9.1fc
format primeage_obs samp_obs mme_samp_obs %9.0fc

qui gen tab = "\begin{tabular}{lllrrr}" in 1
qui gen end = "\end{tabular}" in 1
qui gen c = " "
qui gen hline = "\hline" in 1

qui gen title0 =  "& & & \multicolumn{3}{c}{Proportions of MEPS participants (\%)}" in 1
qui gen title1 =  "& & & All prime-age in MEPS & Analysis sample & MME analysis sample (2010+)" in 1

qui gen section1 = "\multicolumn{6}{l}{\textit{Section 1. Displacement}}" in 1
qui gen section2 = "\multicolumn{6}{l}{\textit{Section 2. Opioid use}}" in 1

qui gen opdcnt = "& \multicolumn{5}{l}{\textit{Prescription counts}}" in 1
qui gen mmeperday = "& \multicolumn{5}{l}{\textit{High MME per day prescriptions}}" in 1

local filename = "table2"

listtex tab if _n == 1 using "$tables/`filename'.tex", replace rstyle(none)
listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	

listtex title0 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	
listtex title1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	
listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)

listtex section1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c name primeage samp mme_samp if vargrp == "DISPLACED", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	

listtex section2 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex mmeperday if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "MME", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)	
listtex opdcnt if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
listtex c c name primeage samp mme_samp if vargrp == "OPDCNT", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)

listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	

listtex c name primeage_obs samp_obs mme_samp_obs if vargrp == "Observations", ///
	appendto("$tables/`filename'.tex") rstyle(tabular)

listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	
listtex end if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)
	
/*******************************************************************************
	Table 3: Regression table
*******************************************************************************/

/*******************************************************************************
	(1) Prepare data to make tables
*******************************************************************************/

* Enumerate health control variables
#delimit ;
global healthcontrols "BADMNTLHLTH1 MNTLHLTHMED1 EVERADCLIM EVERADDAYA EVERADILCR  
			EVERADSPEC EVERADRISK EVERADSOCA EVERASPRIN EVERHYSTER EVERAIDHLP  
			EVERUNABLE EVERWLKLIM EVERWRKLIM EVERJTPAIN EVERBENDIF EVERFNGRDF  
			EVERMILDIF EVERRCHDIF EVERSTNDIF EVERWLKDIF EVERIPNGTD EVERDDNWRK";
#delimit cr

use "$dtadir/analysis.dta", clear

qui gen BLUECOLLAR = COCCP1 >= 6 & !missing(COCCP1)
qui gen NONHISP_WHITE = RACEX == 1 & HISPANX == 0
qui gen BREADWINNER = SHAREINCWAGES >= 0.5
qui gen ONENOWRKPD = RDSNOWRK > 0 & !missing(RDSNOWRK)

foreach intxn in BLUECOLLAR NONHISP_WHITE ONENOWRKPD FAM_BIZTRST BREADWINNER {
	qui gen EVERNONLAYOFFDISPLx`intxn' = EVERNONLAYOFFDISPL * `intxn'
}

lab var BLUECOLLAR "Blue-collar"
lab var NONHISP_WHITE "Non-Hisp. white"
lab var BREADWINNER "Wage inc. was majority of Y1 family income"
lab var ONENOWRKPD "At lst 1 pd did not work"

/*******************************************************************************
	(2) Make regression table
*******************************************************************************/

	/***************************************************************************
		(2.1) Section 1: Baseline
	***************************************************************************/
	 
local num = 0
foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
	EVER90MME EVER120MME {
		
	local ++num // count model

	gen col_`depvar' = ""

	qui reg `depvar' EVERNONLAYOFFDISPL i.REGION i.AGEGRP i.RACEX i.HISPANX ///
		i.MARRY1X i.CIND1 i.COCCP1 i.HIDEG $healthcontrols i.PANEL [pw = LONGWT] ///
		if sample == 1, r
	qui lincom _b[EVERNONLAYOFFDISPL]
	
	qui replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
	qui replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
	qui replace col_`depvar' = string(e(N), "%12.0fc") in 7

	if abs(r(p))< .01 {
		qui replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
	}
	if abs(r(p)) < .05 & abs(r(p)) >= .01 {
		qui replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
	}
	if abs(r(p)) < .1 & abs(r(p)) >= .05 {
		qui replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
	}
	
	qui summ `depvar' if EVERNONLAYOFFDISPL == 1
	qui replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3

	qui replace col_`depvar' = "(`num')" in 8
}

#delimit ;

qui gen tab = "\begin{tabular}{lccc|ccc}" in 1 ;
qui gen top = "\toprule" in 1 ;

*Midrule ;
qui gen mid = "  \midrule " in 1 ;
qui gen hline = " \hline" in 1 ;

*Bottomrule ;
qui gen bot = "  \bottomrule" in 1 ;

*End ;
qui gen end = "\end{tabular}" in 1 ;

qui gen title0 = " & \multicolumn{3}{c}{Panel A: Opioid Count Outcomes} & \multicolumn{3}{c}{Panel B: MME per Day Outcomes}" in 1 ;

qui gen title1 = " & Ever used opds & Rcvd. $\geq$ 6 opd. prsc. & Rcvd. $\geq$ 12 opd. prsc. 
		& Ever 60+ MME/day & Ever 90+ MME/day & Ever 120+ MME/day" in 1 ;

qui gen section1 = "\multicolumn{4}{l|}{\textit{Section 1. Baseline}} & & " in 1 ;
			
qui gen labels = "Ever non-layoff displaced" ;
qui replace labels = "" in 2 ;
qui replace labels = " \textcolor{gray}{Mean of outcome} " in 3 ;
qui replace labels = "Observations" in 7 ;
qui replace labels = "" in 8;
	 
local filename = "table3" ;

listtex tab if _n == 1 using "$tables/`filename'.tex", replace rstyle(none) ;
listtex top if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	;	
listtex title0 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	;
listtex mid if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	;
listtex title1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	;
listtex labels col_* if _n == 8, appendto("$tables/`filename'.tex") rstyle(tabular)	;

listtex mid if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	;

listtex section1 if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)	;
listtex labels col_* if  inrange(_n, 1, 3), appendto("$tables/`filename'.tex") rstyle(tabular)	;
listtex mid if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)	;
#delimit cr

	/***************************************************************************
		(2.2) Sections 2-6: Interaction Regressions
	***************************************************************************/

local secnum = 2 // For numbering sections of the table

foreach intxn in BLUECOLLAR NONHISP_WHITE ONENOWRKPD FAM_BIZTRST BREADWINNER {

		/***********************************************************************
			(2.2.1) Makes sure we have correct labels for text parts of table
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
			(2.2.1) Makes sure we have correct labels for text parts of table
		***********************************************************************/

	local num = 0
	foreach depvar in EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC EVER60MME ///
		EVER90MME EVER120MME {

		local ++num // count model

		qui gen col_`depvar' = ""
		
		qui reg `depvar' EVERNONLAYOFFDISPL EVERNONLAYOFFDISPLx`intxn' `controls' ///
			[pw = LONGWT] if sample == 1, r
		qui lincom _b[EVERNONLAYOFFDISPL]
		
		qui replace col_`depvar'  =  string(r(estimate), "%9.3f") in 4
		qui replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 5
		qui replace col_`depvar' = string(e(N), "%12.0fc") in 7

		if abs(r(p))< .01 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 4
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 4
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 4
		}
		
		qui summ `depvar' if EVERNONLAYOFFDISPL == 1
		qui replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6
		
		qui lincom _b[EVERNONLAYOFFDISPL] + _b[EVERNONLAYOFFDISPLx`intxn']

		qui replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
		qui replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
		qui replace col_`depvar' = string(e(N), "%12.0fc") in 7

		if abs(r(p))< .01 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			qui replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
		}

		qui summ `depvar' if EVERNONLAYOFFDISPLx`intxn' == 1
		qui replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
		
		qui replace col_`depvar' = "(`num')" in 8
	}

	#delimit ;
	gen section = "\multicolumn{4}{l|}{\textit{Section `secnum'. Heterogeneity by `seclab'}} & & " in 1 ;
	#delimit cr

	qui gen labels = ""
	qui replace labels = "`intxnlab'" in 1
	qui replace labels = " \textcolor{gray}{Mean of outcome (`lower_intxnlab')} " in 3
	qui replace labels = "`upper_not_category_cap'" in 4
	qui replace labels = " \textcolor{gray}{Mean of outcome (`lower_not_category_cap')} " in 6
	qui replace labels = "Observations" in 7 

	listtex section if _n == 1, appendto("$tables/`filename'.tex") rstyle(tabular)
	listtex labels col_* if  inrange(_n, 1, 6), appendto("$tables/`filename'.tex") ///
		rstyle(tabular)
	listtex hline if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)

	if `secnum' == 6 { // Last section 
		listtex labels col_* if  _n == 7, appendto("$tables/`filename'.tex") ///
			rstyle(tabular)
	}
	
	local secnum = `secnum' + 1

}

listtex bot if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)
listtex end if _n == 1, appendto("$tables/`filename'.tex") rstyle(none)