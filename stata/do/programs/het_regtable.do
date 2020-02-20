capture program drop het_regtable

program define het_regtable

	set more off

	syntax, intxn(string) controls(string) saveas(string) [not_category_cap(string)]

	local intxnlab : variable label `intxn'
	local lower_intxnlab = lower("`intxnlab'")

	if "`not_category_cap'" == "" {
		local upper_not_category_cap = "Not " + lower("`lower_intxnlab'")
	} 
	else {
		local upper_not_category_cap = "`not_category_cap'"
	}
	local lower_not_category_cap = lower("`upper_not_category_cap'")

	local intxn_ext = lower("`intxn'")

	#delimit ;
	local varlist = "EVERUSEDOPDS HAD6PLUSOPDPRSC HAD12PLUSOPDPRSC 
					EVER60MME EVER90MME EVER120MME";
	#delimit cr

		local num = 0
	foreach depvar in `varlist' {
		local ++num // count model

		g col_`depvar' = ""
		
		reg `depvar' EVERNONLAYOFFDISPL EVERNONLAYOFFDISPLx`intxn' `controls' ///
			[pw = LONGWT] if sample == 1, r
		lincom _b[EVERNONLAYOFFDISPL]
		
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
		
		qui summ `depvar' if EVERNONLAYOFFDISPL == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6
		
		* blue collar
		lincom _b[EVERNONLAYOFFDISPL] + _b[EVERNONLAYOFFDISPLx`intxn']

		replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
		replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
		replace col_`depvar' = string(e(N), "%12.0fc") in 7

		if abs(r(p))< .01{
			replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
		}

		qui summ `depvar' if EVERNONLAYOFFDISPLx`intxn' == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
		
		replace col_`depvar' = "(`num')" in 8
	}

	gen tab = "\begin{tabular}{lccc|ccc}" in 1
	gen top = "\toprule" in 1

	*Midrule
	gen mid = "  \midrule " in 1
	gen hline = " \hline" in 1

	*Bottomrule
	gen bot = "  \bottomrule" in 1

	*End
	gen end = "\end{tabular}" in 1

	#delimit ;

	gen title0 = " & \multicolumn{3}{c}{Panel A: Opioid Count Outcomes} & 
		\multicolumn{3}{c}{Panel B: MME per Day Outcomes}" in 1 ;

	gen title1 = " & Ever used opds & Rcvd. $\geq$ 6 opd. prsc. & Rcvd. $\geq$ 12 opd. prsc. 
			& Ever 60+ MME/day & Ever 90+ MME/day & Ever 120+ MME/day" in 1 ;

	gen section1 = "\multicolumn{4}{l|}{\textit{Section 1. Independent variable = individual
				ever non-layoff displaced}} & & " in 1 ;

	#delimit cr

	g labels = ""
	replace labels = "`intxnlab'" in 1
	replace labels = " \textcolor{gray}{Mean of outcome (`lower_intxnlab')} " in 3
	replace labels = "`upper_not_category_cap'" in 4
	replace labels = " \textcolor{gray}{Mean of outcome (`lower_not_category_cap')} " in 6

	listtex tab if _n == 1 using "`saveas'.tex", replace rstyle(none)
	listtex top if _n == 1, appendto("`saveas'.tex") rstyle(none)
	listtex title0 if _n == 1, appendto("`saveas'.tex") rstyle(tabular)
	listtex mid if _n == 1, appendto("`saveas'.tex") rstyle(none)
	listtex title1 if _n == 1, appendto("`saveas'.tex") rstyle(tabular)
	listtex labels col_* if _n == 8, appendto("`saveas'.tex") rstyle(tabular)

	listtex mid if _n == 1, appendto("`saveas'.tex") rstyle(none)

	listtex section1 if _n == 1, appendto("`saveas'.tex") rstyle(tabular)
	listtex labels col_* if inrange(_n, 1, 6), appendto("`saveas'.tex") rstyle(tabular)
	listtex mid if _n == 1, appendto("`saveas'.tex") rstyle(none)
		 
				/*******************************************************************
					Panel B: Independent variable = ever displaced
				*******************************************************************/
		 
	drop col*

	local num = 0
	foreach depvar in `varlist' {
		local ++num // count model

		g col_`depvar' = ""
		
		reg `depvar' EVERDISPLACED EVERDISPLACEDx`intxn' `controls' [pw = LONGWT] if sample == 1, r
		lincom _b[EVERDISPLACED]
		
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
		
		qui summ `depvar' if EVERDISPLACED == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6
		
		lincom _b[EVERDISPLACED] + _b[EVERDISPLACEDx`intxn']

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

		qui summ `depvar' if EVERDISPLACEDx`intxn' == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
		
		replace col_`depvar' = "(`num')" in 8
	}

	#delimit ;
	gen section2 = "\multicolumn{4}{l|}{\textit{Section 2. Independent variable = individual
				ever displaced}} & & " in 1 ;

	#delimit cr

	listtex section2 if _n == 1, appendto("`saveas'.tex") rstyle(tabular)
	listtex labels col_* if  inrange(_n, 1, 6), appendto("`saveas'.tex") rstyle(tabular)
	listtex mid if _n == 1, appendto("`saveas'.tex") rstyle(none)
		 
				/*******************************************************************
					Panel C: Independent variable = ever non-layoff displaced
				*******************************************************************/
		 
	drop col*

	local num = 0
	foreach depvar in `varlist' {
		local ++num // count model

		g col_`depvar' = ""
		
		reg `depvar' EVERLAIDOFF EVERLAIDOFFx`intxn' `controls' [pw = LONGWT] if sample == 1, r
		lincom _b[EVERLAIDOFF]
		
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
		
		qui summ `depvar' if EVERLAIDOFF == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6
		
		* blue collar
		lincom _b[EVERLAIDOFF] + _b[EVERLAIDOFFx`intxn']

		replace col_`depvar'  =  string(r(estimate), "%9.3f") in 1
		replace col_`depvar' =  "(" + string(r(se), "%9.3f") + ")" in 2
		replace col_`depvar' = string(e(N), "%12.0fc") in 7

		if abs(r(p))< .01{
			replace col_`depvar' = col_`depvar'+"$ ^{***}$ " in 1
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			replace col_`depvar' = col_`depvar'+"$ ^{**}$ " in 1
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			replace col_`depvar' = col_`depvar'+"$ ^{*}$ " in 1
		}

		qui summ `depvar' if EVERLAIDOFFx`intxn' == 1
		replace col_`depvar' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
		
		replace col_`depvar' = "(`num')" in 8
	}

	#delimit ;
	gen section3 = "\multicolumn{4}{l|}{\textit{Section 3. Independent variable = individual
				ever laid off}} & & " in 1 ;
	#delimit cr

	replace labels = "Observations" in 7 

	listtex section3 if _n == 1, appendto("`saveas'.tex") rstyle(tabular)
	listtex labels col_* if  inrange(_n, 1, 6), appendto("`saveas'.tex") rstyle(tabular)
	listtex hline if _n == 1, appendto("`saveas'.tex") rstyle(none)
	listtex labels col_* if  _n == 7, appendto("`saveas'.tex") rstyle(tabular)
	listtex bot if _n == 1, appendto("`saveas'.tex") rstyle(none)
	listtex end if _n == 1, appendto("`saveas'.tex") rstyle(none)

end