/*

This file creates the significance-star column for Table 1.

It estimates the statistical significance of the difference between the share of
pregnant women in patrilocal extended households in NFHS-3 and NFHS-5.

For each row of Table 1, it runs a weighted linear probability model of
patrilocal extended household residence on an indicator for NFHS-5, restricting
the sample to NFHS-3 and NFHS-5. NFHS-3 is the omitted survey round.

The regression is:

    patrilocal_i = alpha + beta * 1(round_i == NFHS-5) + error_i

The p-value for beta is converted into significance stars.

This file saves a dataset with only the Table 1 row labels and the corresponding
significance-star column. That dataset is later merged into the main Table 1
file created by 30_table_1_prop_patrilocal_in_subgroups.do.

You do not need to run this file directly. It is called by
30_table_1_prop_patrilocal_in_subgroups.do.


*/

do "$paths"
use "$all_nfhs_ir", clear

* keep only nuclear and patrilocal
keep if inlist(hh_struc,1,2)

* keep only nfhs3 and nfhs5 to test the difference between those
keep if inlist(round,3,5)

keep if pregnant==1

*******************************************************
* helper program to format significance stars based on p val
*******************************************************
cap program drop starify
program define starify
	args pval
	if missing(`pval') {
		c_local stars ""
	}
	else if `pval' < 0.01 {
		c_local stars "***"
	}
	else if `pval' < 0.05 {
		c_local stars "**"
	}
	else if `pval' < 0.10 {
		c_local stars "*"
	}
	else {
		c_local stars ""
	}
end

*******************************************************
* first get significance stars for the overall sample
*******************************************************
tempname post_overall
tempfile overall_sig

postfile `post_overall' str150 row_fmt double p using `overall_sig', replace

capture noisily regress patrilocal ib3.round [aw=wt], cluster(psu)
if _rc==0 {
	test 5.round
	post `post_overall' ("\textbf{All currently pregnant women}") (r(p))
}
else {
	post `post_overall' ("\textbf{All currently pregnant women}") (.)
}

postclose `post_overall'

use `overall_sig', clear
gen sig = ""
forvalues i = 1/`=_N' {
	quietly starify p[`i']
	replace sig = "`stars'" in `i'
}
keep row_fmt sig
tempfile overall_final
save `overall_final', replace

*******************************************************
* now test within various subgroups 
*******************************************************
foreach overvar in group region v013 parity {

	use "$all_nfhs_ir", clear
	keep if inlist(hh_struc,1,2)
	keep if inlist(round,3,5)
	keep if pregnant==1
	drop if missing(`overvar')

	tempname post_`overvar'
	tempfile stars_`overvar'

	postfile `post_`overvar'' str150 row_fmt double p using `stars_`overvar'', replace

	levelsof `overvar', local(levels)

	foreach lvl of local levels {

// 		capture noisily regress patrilocal ib3.round [aw=wt] if `overvar'==`lvl'
		capture noisily regress patrilocal ib3.round [aw=wt] if `overvar'==`lvl', cluster(psu)
		
		if _rc==0 {
			test 5.round
			local thisp = r(p)
		}
		else {
			local thisp = .
		}

		if "`overvar'"=="group" {
			local lbl : label (group) `lvl'
			local thisrow "\hspace*{2em}`lbl'"
		}

		if "`overvar'"=="region" {
			local lbl : label (region) `lvl'
			local thisrow "\hspace*{2em}`lbl'"
		}

		if "`overvar'"=="v013" {
			local lbl : label (v013) `lvl'
			local lbl = subinstr("`lbl'","-","--",.)
			local thisrow "\hspace*{2em}`lbl'"
		}

		if "`overvar'"=="parity" {
			if `lvl'==1 local thisrow "\hspace*{2em}0"
			if `lvl'==2 local thisrow "\hspace*{2em}1"
			if `lvl'==3 local thisrow "\hspace*{2em}2"
			if `lvl'==4 local thisrow "\hspace*{2em}3+"
		}

		post `post_`overvar'' ("`thisrow'") (`thisp')
	}

	postclose `post_`overvar''

	use `stars_`overvar'', clear
	gen sig = ""
	forvalues i = 1/`=_N' {
		quietly starify p[`i']
		replace sig = "`stars'" in `i'
	}
	keep row_fmt sig

	tempfile final_`overvar'
	save `final_`overvar'', replace
}

*******************************************************
* combine all and format 
*******************************************************
use `overall_final', clear
append using `final_group'
append using `final_region'
append using `final_v013'
append using `final_parity'


replace row_fmt = "\hspace*{2em}Forward caste"        if row_fmt=="\hspace*{2em}Forward Caste"
replace row_fmt = "\hspace*{2em}Sikh/Jain/Christian"  if row_fmt=="\hspace*{2em}Sikh, Jain, Christian"

replace row_fmt = "\hspace*{2em}Focus states$^1$"         if row_fmt=="\hspace*{2em}UP and Bihar"
replace row_fmt = "\hspace*{2em}Central"              if row_fmt=="\hspace*{2em}central"
replace row_fmt = "\hspace*{2em}East"                 if row_fmt=="\hspace*{2em}east"
replace row_fmt = "\hspace*{2em}West"                 if row_fmt=="\hspace*{2em}west"
replace row_fmt = "\hspace*{2em}North"                if row_fmt=="\hspace*{2em}north"
replace row_fmt = "\hspace*{2em}South"                if row_fmt=="\hspace*{2em}south"
replace row_fmt = "\hspace*{2em}Northeast"            if row_fmt=="\hspace*{2em}northeast"

// save "tables/table1_rowfmt_sig_only.dta", replace
save "tables/table1_rowfmt_sig_only", replace
