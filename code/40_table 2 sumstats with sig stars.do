use $all_nfhs_ir, clear

************************************************************
* TABLE: Summary statistics with significance stars
* - Currently pregnant women
* - Women with birth 3-12 months before survey
* - Means by round x hh_struc
* - Adds N row
* - Adds significance stars for Nuclear vs Joint within round
************************************************************

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


************************************************************
* PART 1: WOMEN WHO GAVE BIRTH 3-12 MONTHS BEFORE SURVEY
************************************************************
use $all_nfhs_ir, clear

* sample restriction
keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)
keep if ever_married==1

gen columns = 1 if round==3 & hh_struc==1
replace columns = 2 if round==3 & hh_struc==2
replace columns = 3 if round==4 & hh_struc==1
replace columns = 4 if round==4 & hh_struc==2
replace columns = 5 if round==5 & hh_struc==1
replace columns = 6 if round==5 & hh_struc==2
drop if missing(columns)

label define columnlbl ///
	1 "Nuclear NFHS-3" ///
	2 "Patrilocal NFHS-3" ///
	3 "Nuclear NFHS-4" ///
	4 "Patrilocal NFHS-4" ///
	5 "Nuclear NFHS-5" ///
	6 "Patrilocal NFHS-5"
label values columns columnlbl

keep if inrange(months_ago_last_birth, 3, 12)


*-------------------------------
* 0) N by columns (unweighted)
*-------------------------------
preserve
contract columns
rename _freq N
gen varname = "n"
rename N mean
keep columns varname mean
tempfile collapsed_N_pp
save `collapsed_N_pp', replace
restore

*-------------------------------
* 1) Means (wt)
*-------------------------------
preserve
collapse (mean) ///
	facility_birth anc_four ///
	finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
	latrine owns_land ///
	[aw=wt], by(columns)

rename (facility_birth anc_four ///
		finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
		latrine owns_land) ///
	   (m_facility_birth m_anc_four ///
		m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car ///
		m_latrine m_owns_land)

reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_main_pp
save `collapsed_main_pp', replace
restore

*-------------------------------
* 2) Significance tests: Nuclear vs Joint within round
*-------------------------------
tempname post_pp
tempfile stars_pp
postfile `post_pp' str30 varname int round double p using `stars_pp', replace

foreach v in facility_birth anc_four ///
			 finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
			 latrine owns_land {
	foreach r in 3 4 5 {
		capture noisily regress `v' i.hh_struc [aw=wt] if round==`r' & inlist(hh_struc,1,2)
		if _rc==0 {
			test 2.hh_struc
			post `post_pp' ("`v'") (`r') (r(p))
		}
		else {
			post `post_pp' ("`v'") (`r') (.)
		}
	}
}
postclose `post_pp'

use `stars_pp', clear
gen stars = ""
forvalues i = 1/`=_N' {
	quietly starify p[`i']
	replace stars = "`stars'" in `i'
}
keep varname round stars
reshape wide stars, i(varname) j(round)
rename stars3 sig3
rename stars4 sig4
rename stars5 sig5
gen sample = "3-12 months ago last birth"
tempfile stars_postpartum
save `stars_postpartum', replace

*-------------------------------
* 3) Stack + wide
*-------------------------------
use `collapsed_main_pp', clear
append using `collapsed_N_pp'

reshape wide mean, i(varname) j(columns)
rename mean1 Nuclear3
rename mean2 Patrilocal3
rename mean3 Nuclear4
rename mean4 Patrilocal4
rename mean5 Nuclear5
rename mean6 Patrilocal5

gen sample = "3-12 months ago last birth"
merge 1:1 varname sample using `stars_postpartum', nogen
replace sig3 = "" if varname=="n"
replace sig4 = "" if varname=="n"
replace sig5 = "" if varname=="n"

tempfile postpartum_sample
save `postpartum_sample', replace


************************************************************
* PART 2: CURRENTLY PREGNANT WOMEN
************************************************************
use $all_nfhs_ir, clear

keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)
keep if pregnant==1 & preg==1
keep if ever_married==1



gen columns = 1 if round==3 & hh_struc==1
replace columns = 2 if round==3 & hh_struc==2
replace columns = 3 if round==4 & hh_struc==1
replace columns = 4 if round==4 & hh_struc==2
replace columns = 5 if round==5 & hh_struc==1
replace columns = 6 if round==5 & hh_struc==2
drop if missing(columns)

label define columnlbl ///
	1 "Nuclear NFHS-3" ///
	2 "Patrilocal NFHS-3" ///
	3 "Nuclear NFHS-4" ///
	4 "Patrilocal NFHS-4" ///
	5 "Nuclear NFHS-5" ///
	6 "Patrilocal NFHS-5", replace
label values columns columnlbl

*-------------------------------
* 0) N by columns (unweighted)
*-------------------------------
preserve
contract columns
rename _freq N
gen varname = "n"
rename N mean
keep columns varname mean
tempfile collapsed_N
save `collapsed_N', replace
restore

*-------------------------------
* 1) Wealth means (wt)
*-------------------------------
preserve
collapse (mean) ///
	finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
	latrine owns_land ///
	[aw=wt], by(columns)

rename (finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
		latrine owns_land) ///
	   (m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car ///
		m_latrine m_owns_land)

reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_wealth
save `collapsed_wealth', replace
restore

*-------------------------------
* 2) Autonomy means (w_state)
*-------------------------------
preserve
collapse (mean) ///
	nosay_healthcare nosay_visits ///
	[aw=w_state], by(columns)

rename (nosay_healthcare nosay_visits) ///
	   (m_nosay_healthcare m_nosay_visits)

reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_auto
save `collapsed_auto', replace
restore

*-------------------------------
* 3) Significance tests
*-------------------------------
tempname post_preg
tempfile stars_preg
postfile `post_preg' str30 varname int round double p using `stars_preg', replace

* wt-weighted vars
foreach v in finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
			 latrine owns_land {
	foreach r in 3 4 5 {
		capture noisily regress `v' i.hh_struc [aw=wt] if round==`r' & inlist(hh_struc,1,2)
		if _rc==0 {
			test 2.hh_struc
			post `post_preg' ("`v'") (`r') (r(p))
		}
		else {
			post `post_preg' ("`v'") (`r') (.)
		}
	}
}

* w_state-weighted vars
foreach v in nosay_healthcare nosay_visits {
	foreach r in 3 4 5 {
		capture noisily regress `v' i.hh_struc [aw=w_state] if round==`r' & inlist(hh_struc,1,2)
		if _rc==0 {
			test 2.hh_struc
			post `post_preg' ("`v'") (`r') (r(p))
		}
		else {
			post `post_preg' ("`v'") (`r') (.)
		}
	}
}
postclose `post_preg'

use `stars_preg', clear
gen stars = ""
forvalues i = 1/`=_N' {
	quietly starify p[`i']
	replace stars = "`stars'" in `i'
}
keep varname round stars
reshape wide stars, i(varname) j(round)
rename stars3 sig3
rename stars4 sig4
rename stars5 sig5
gen sample = "pregnant"
tempfile stars_pregnant
save `stars_pregnant', replace

*-------------------------------
* 4) Stack + wide
*-------------------------------
use `collapsed_auto', clear
append using `collapsed_wealth'
append using `collapsed_N'

reshape wide mean, i(varname) j(columns)
rename mean1 Nuclear3
rename mean2 Patrilocal3
rename mean3 Nuclear4
rename mean4 Patrilocal4
rename mean5 Nuclear5
rename mean6 Patrilocal5

gen sample = "pregnant"
merge 1:1 varname sample using `stars_pregnant', nogen
replace sig3 = "" if varname=="n"
replace sig4 = "" if varname=="n"
replace sig5 = "" if varname=="n"

append using `postpartum_sample'


************************************************************
* PART 3: ORDER, SPACING, ROW LABELS
************************************************************

* Add header/spacer rows by expanding selected observations
expand 2 if varname=="nosay_healthcare" & sample=="pregnant"
expand 2 if varname=="nosay_visits" & sample=="pregnant"

expand 2 if varname=="facility_birth" & sample=="3-12 months ago last birth"
expand 2 if varname=="anc_four" & sample=="3-12 months ago last birth"

expand 2 if varname=="finished_floor" & sample=="pregnant"
expand 2 if varname=="owns_land"      & sample=="pregnant"

expand 2 if varname=="finished_floor" & sample=="3-12 months ago last birth"
expand 2 if varname=="owns_land"      & sample=="3-12 months ago last birth"

expand 2 if varname=="n" & sample=="pregnant"
expand 2 if varname=="n" & sample=="3-12 months ago last birth"

bysort sample varname: gen dup = _n
gen order = .

* Autonomy measures (currently pregnant sample)
replace order = 1 if varname=="nosay_healthcare" & sample=="pregnant" & dup==1
replace order = 2 if varname=="nosay_healthcare" & sample=="pregnant" & dup==2
replace order = 3 if varname=="nosay_visits"     & sample=="pregnant" & dup==1
replace order = 4 if varname=="nosay_visits"     & sample=="pregnant" & dup==2

* Healthcare measures (recently given birth sample)
replace order = 5 if varname=="facility_birth" & sample=="3-12 months ago last birth" & dup==1
replace order = 6 if varname=="facility_birth" & sample=="3-12 months ago last birth" & dup==2
replace order = 7 if varname=="anc_four"       & sample=="3-12 months ago last birth" & dup==1
replace order = 8 if varname=="anc_four"       & sample=="3-12 months ago last birth" & dup==2

* Wealth measures (currently pregnant sample)
replace order = 9  if varname=="finished_floor" & sample=="pregnant" & dup==1
replace order = 10 if varname=="finished_floor" & sample=="pregnant" & dup==2
replace order = 11 if varname=="electricity"    & sample=="pregnant"
replace order = 12 if varname=="owns_radio"     & sample=="pregnant"
replace order = 13 if varname=="owns_tv"        & sample=="pregnant"
replace order = 14 if varname=="owns_fridge"    & sample=="pregnant"
replace order = 15 if varname=="owns_bike"      & sample=="pregnant"
replace order = 16 if varname=="owns_car"       & sample=="pregnant"
replace order = 17 if varname=="latrine"        & sample=="pregnant"
replace order = 18 if varname=="owns_land"      & sample=="pregnant" & dup==1
replace order = 19 if varname=="owns_land"      & sample=="pregnant" & dup==2

* Wealth measures (recently given birth sample)
replace order = 20 if varname=="finished_floor" & sample=="3-12 months ago last birth" & dup==1
replace order = 21 if varname=="finished_floor" & sample=="3-12 months ago last birth" & dup==2
replace order = 22 if varname=="electricity"    & sample=="3-12 months ago last birth"
replace order = 23 if varname=="owns_radio"     & sample=="3-12 months ago last birth"
replace order = 24 if varname=="owns_tv"        & sample=="3-12 months ago last birth"
replace order = 25 if varname=="owns_fridge"    & sample=="3-12 months ago last birth"
replace order = 26 if varname=="owns_bike"      & sample=="3-12 months ago last birth"
replace order = 27 if varname=="owns_car"       & sample=="3-12 months ago last birth"
replace order = 28 if varname=="latrine"        & sample=="3-12 months ago last birth"
replace order = 29 if varname=="owns_land"      & sample=="3-12 months ago last birth" & dup==1
replace order = 30 if varname=="owns_land"      & sample=="3-12 months ago last birth" & dup==2

* N rows moved to bottom
replace order = 31 if varname=="n" & sample=="pregnant" & dup==1
replace order = 32 if varname=="n" & sample=="pregnant" & dup==2

replace order = 33 if varname=="n" & sample=="3-12 months ago last birth" & dup==1
replace order = 34 if varname=="n" & sample=="3-12 months ago last birth" & dup==2

sort order

gen str150 rows = ""

* Autonomy
replace rows = "\textbf{Autonomy measures (currently pregnant sample)}" if order==1
replace rows = "\hspace*{2em}No say in own healthcare"                  if order==2
replace rows = "\hspace*{2em}No say in visits to family/friends"        if order==3
replace rows = ""                                                      if order==4

* Healthcare
replace rows = "\textbf{Healthcare measures (recently given birth sample)}" if order==5
replace rows = "\hspace*{2em}Birth in a health facility"                    if order==6
replace rows = "\hspace*{2em}4+ antenatal visits"                           if order==7
replace rows = ""                                                          if order==8

* Wealth (pregnant)
replace rows = "\textbf{Wealth measures (currently pregnant sample)}" if order==9
replace rows = "\hspace*{2em}Finished floor"                          if order==10
replace rows = "\hspace*{2em}Electricity"                             if order==11
replace rows = "\hspace*{2em}Owns radio"                              if order==12
replace rows = "\hspace*{2em}Owns TV"                                 if order==13
replace rows = "\hspace*{2em}Owns refrigerator"                       if order==14
replace rows = "\hspace*{2em}Owns bicycle"                            if order==15
replace rows = "\hspace*{2em}Owns car"                                if order==16
replace rows = "\hspace*{2em}Uses toilet/latrine"                     if order==17
replace rows = "\hspace*{2em}Owns land"                               if order==18
replace rows = ""                                                     if order==19

* Wealth (postpartum)
replace rows = "\textbf{Wealth measures (recently given birth sample)}" if order==20
replace rows = "\hspace*{2em}Finished floor"                           if order==21
replace rows = "\hspace*{2em}Electricity"                              if order==22
replace rows = "\hspace*{2em}Owns radio"                               if order==23
replace rows = "\hspace*{2em}Owns TV"                                  if order==24
replace rows = "\hspace*{2em}Owns refrigerator"                        if order==25
replace rows = "\hspace*{2em}Owns bicycle"                             if order==26
replace rows = "\hspace*{2em}Owns car"                                 if order==27
replace rows = "\hspace*{2em}Uses toilet/latrine"                      if order==28
replace rows = "\hspace*{2em}Owns land"                                if order==29
replace rows = ""                                                      if order==30

* N rows at bottom with spacing
replace rows = "\textbf{N (currently pregnant sample)}"            if order==31
replace rows = ""                                                 if order==32
replace rows = "\textbf{N (recently given birth sample)}"          if order==33
replace rows = ""                                                 if order==34

order rows


************************************************************
* PART 4: DISPLAY STRINGS
************************************************************
keep rows Nuclear* Patrilocal* sig*

foreach r in 3 4 5 {

	gen str12 dispNuclear`r'    = ""
	gen str12 dispPatrilocal`r' = ""
	gen str5  dispSig`r'        = ""

	* N rows: integers with commas
	replace dispNuclear`r' = string(round(Nuclear`r'), "%9.0fc") ///
		if inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")
	replace dispPatrilocal`r' = string(round(Patrilocal`r'), "%9.0fc") ///
		if inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")

	* Other rows: proportions
	replace dispNuclear`r' = string(Nuclear`r', "%4.2f") ///
		if !missing(rows) & !inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")
	replace dispPatrilocal`r' = string(Patrilocal`r', "%4.2f") ///
		if !missing(rows) & !inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")

	* Significance stars
	replace dispSig`r' = sig`r' if !missing(rows) & !inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")
	replace dispSig`r' = "" if inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")
}

* Blank out headers / spacer rows
foreach var in dispNuclear3 dispPatrilocal3 dispSig3 ///
			   dispNuclear4 dispPatrilocal4 dispSig4 ///
			   dispNuclear5 dispPatrilocal5 dispSig5 {
	replace `var' = "" if strpos(rows, "\textbf{")!=0 & ///
		!inlist(rows, "\textbf{N (currently pregnant sample)}", "\textbf{N (recently given birth sample)}")
	replace `var' = "" if rows==""
}

keep rows disp*

list rows disp*, noobs clean

************************************************************
* PART 5: EXPORT TO LATEX
************************************************************
listtex ///
	rows ///
	dispNuclear3 dispPatrilocal3 dispSig3 ///
	dispNuclear4 dispPatrilocal4 dispSig4 ///
	dispNuclear5 dispPatrilocal5 dispSig5 ///
	using "tables/table 1 summary stats updated.tex", ///
	replace rstyle(tabular) ///
	head( ///
"\begin{tabular}{lccccccccc}" ///
"\toprule" ///
" & \multicolumn{3}{c}{NFHS-3 (2005--2006)} & \multicolumn{3}{c}{NFHS-4 (2015--2016)} & \multicolumn{3}{c}{NFHS-5 (2019--2021)} \\\\" ///
"\cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10}" ///
" & Nuclear & \shortstack{Patrilocal\\Extended} & Sig. & Nuclear & \shortstack{Patrilocal\\Extended} & Sig. & Nuclear & \shortstack{Patrilocal\\Extended} & Sig. \\\\" ///
"\midrule" ///
) ///
	foot( ///
		"\bottomrule" ///
		"\end{tabular}" ///
	)


// use $all_nfhs_ir, clear
//
// ************************************************************
// * TABLE: Summary statistics with significance stars
// * - Currently pregnant women
// * - Women with birth 3-12 months before survey
// * - Means by round x hh_struc
// * - Adds N row
// * - Adds significance stars for Nuclear vs Joint within round
// ************************************************************
//
// cap program drop starify
// program define starify
//     args pval
//     if missing(`pval') {
//         c_local stars ""
//     }
//     else if `pval' < 0.01 {
//         c_local stars "***"
//     }
//     else if `pval' < 0.05 {
//         c_local stars "**"
//     }
//     else if `pval' < 0.10 {
//         c_local stars "*"
//     }
//     else {
//         c_local stars ""
//     }
// end
//
//
// ************************************************************
// * PART 1: WOMEN WHO GAVE BIRTH 3-12 MONTHS BEFORE SURVEY
// ************************************************************
// use $all_nfhs_ir, clear
//
// * sample restriction
// keep if inlist(round,3,4,5)
// keep if inlist(hh_struc,1,2)
// keep if ever_married==1
//
// gen columns = 1 if round==3 & hh_struc==1
// replace columns = 2 if round==3 & hh_struc==2
// replace columns = 3 if round==4 & hh_struc==1
// replace columns = 4 if round==4 & hh_struc==2
// replace columns = 5 if round==5 & hh_struc==1
// replace columns = 6 if round==5 & hh_struc==2
// drop if missing(columns)
//
// label define columnlbl ///
//     1 "Nuclear NFHS-3" ///
//     2 "Patrilocal NFHS-3" ///
//     3 "Nuclear NFHS-4" ///
//     4 "Patrilocal NFHS-4" ///
//     5 "Nuclear NFHS-5" ///
//     6 "Patrilocal NFHS-5"
// label values columns columnlbl
//
// gen months_ago_last_birth = v008 - b3_01
// keep if inrange(months_ago_last_birth, 3, 12)
//
// * outcomes
// gen facility_birth = (home_birth==0) if !missing(home_birth)
//
// * wealth vars
// gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)
// gen latrine        = !inlist(v116, 30, 31) if !missing(v116)
// gen electricity    = v119==1 if !missing(v119)
// gen owns_radio     = v120==1 if !missing(v120)
// gen owns_tv        = v121==1 if !missing(v121)
// gen owns_fridge    = v122==1 if !missing(v122)
// gen owns_bike      = v123==1 if !missing(v123)
// gen owns_car       = v125==1 if !missing(v125)
// gen owns_land      = inlist(v745b,1,2,3) if !missing(v745b)
//
// *-------------------------------
// * 0) N by columns (unweighted)
// *-------------------------------
// preserve
// contract columns
// rename _freq N
// gen varname = "n"
// rename N mean
// keep columns varname mean
// tempfile collapsed_N_pp
// save `collapsed_N_pp', replace
// restore
//
// *-------------------------------
// * 1) Means (wt)
// *-------------------------------
// preserve
// collapse (mean) ///
//     facility_birth anc_four ///
//     finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//     latrine owns_land ///
//     [aw=wt], by(columns)
//
// rename (facility_birth anc_four ///
//         finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//         latrine owns_land) ///
//        (m_facility_birth m_anc_four ///
//         m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car ///
//         m_latrine m_owns_land)
//
// reshape long m_, i(columns) j(varname) string
// rename m_ mean
// tempfile collapsed_main_pp
// save `collapsed_main_pp', replace
// restore
//
// *-------------------------------
// * 2) Significance tests: Nuclear vs Joint within round
// *-------------------------------
// tempname post_pp
// tempfile stars_pp
// postfile `post_pp' str30 varname int round double p using `stars_pp', replace
//
// foreach v in facility_birth anc_four ///
//              finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//              latrine owns_land {
//     foreach r in 3 4 5 {
//         capture noisily regress `v' i.hh_struc [aw=wt] if round==`r' & inlist(hh_struc,1,2)
//         if _rc==0 {
//             test 2.hh_struc
//             post `post_pp' ("`v'") (`r') (r(p))
//         }
//         else {
//             post `post_pp' ("`v'") (`r') (.)
//         }
//     }
// }
// postclose `post_pp'
//
// use `stars_pp', clear
// gen stars = ""
// forvalues i = 1/`=_N' {
//     quietly starify p[`i']
//     replace stars = "`stars'" in `i'
// }
// keep varname round stars
// reshape wide stars, i(varname) j(round)
// rename stars3 sig3
// rename stars4 sig4
// rename stars5 sig5
// gen sample = "3-12 months ago last birth"
// tempfile stars_postpartum
// save `stars_postpartum', replace
//
// *-------------------------------
// * 3) Stack + wide
// *-------------------------------
// use `collapsed_main_pp', clear
// append using `collapsed_N_pp'
//
// reshape wide mean, i(varname) j(columns)
// rename mean1 Nuclear3
// rename mean2 Patrilocal3
// rename mean3 Nuclear4
// rename mean4 Patrilocal4
// rename mean5 Nuclear5
// rename mean6 Patrilocal5
//
// gen sample = "3-12 months ago last birth"
// merge 1:1 varname sample using `stars_postpartum', nogen
// replace sig3 = "" if varname=="n"
// replace sig4 = "" if varname=="n"
// replace sig5 = "" if varname=="n"
//
// tempfile postpartum_sample
// save `postpartum_sample', replace
//
//
// ************************************************************
// * PART 2: CURRENTLY PREGNANT WOMEN
// ************************************************************
// use $all_nfhs_ir, clear
//
// keep if inlist(round,3,4,5)
// keep if inlist(hh_struc,1,2)
// keep if pregnant==1 & preg==1
// keep if ever_married==1
//
// gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)
// gen latrine        = !inlist(v116, 30, 31) if !missing(v116)
// gen electricity    = v119==1 if !missing(v119)
// gen owns_radio     = v120==1 if !missing(v120)
// gen owns_tv        = v121==1 if !missing(v121)
// gen owns_fridge    = v122==1 if !missing(v122)
// gen owns_bike      = v123==1 if !missing(v123)
// gen owns_car       = v125==1 if !missing(v125)
// gen owns_land      = inlist(v745b,1,2,3) if !missing(v745b)
// gen facility_birth = (home_birth==0) if !missing(home_birth)
//
// gen columns = 1 if round==3 & hh_struc==1
// replace columns = 2 if round==3 & hh_struc==2
// replace columns = 3 if round==4 & hh_struc==1
// replace columns = 4 if round==4 & hh_struc==2
// replace columns = 5 if round==5 & hh_struc==1
// replace columns = 6 if round==5 & hh_struc==2
// drop if missing(columns)
//
// label define columnlbl ///
//     1 "Nuclear NFHS-3" ///
//     2 "Patrilocal NFHS-3" ///
//     3 "Nuclear NFHS-4" ///
//     4 "Patrilocal NFHS-4" ///
//     5 "Nuclear NFHS-5" ///
//     6 "Patrilocal NFHS-5", replace
// label values columns columnlbl
//
// *-------------------------------
// * 0) N by columns (unweighted)
// *-------------------------------
// preserve
// contract columns
// rename _freq N
// gen varname = "n"
// rename N mean
// keep columns varname mean
// tempfile collapsed_N
// save `collapsed_N', replace
// restore
//
// *-------------------------------
// * 1) Wealth means (wt)
// *-------------------------------
// preserve
// collapse (mean) ///
//     finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//     latrine owns_land ///
//     [aw=wt], by(columns)
//
// rename (finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//         latrine owns_land) ///
//        (m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car ///
//         m_latrine m_owns_land)
//
// reshape long m_, i(columns) j(varname) string
// rename m_ mean
// tempfile collapsed_wealth
// save `collapsed_wealth', replace
// restore
//
// *-------------------------------
// * 2) Autonomy means (w_state)
// *-------------------------------
// preserve
// collapse (mean) ///
//     nosay_healthcare nosay_visits ///
//     [aw=w_state], by(columns)
//
// rename (nosay_healthcare nosay_visits) ///
//        (m_nosay_healthcare m_nosay_visits)
//
// reshape long m_, i(columns) j(varname) string
// rename m_ mean
// tempfile collapsed_auto
// save `collapsed_auto', replace
// restore
//
// *-------------------------------
// * 3) Significance tests
// *-------------------------------
// tempname post_preg
// tempfile stars_preg
// postfile `post_preg' str30 varname int round double p using `stars_preg', replace
//
// * wt-weighted vars
// foreach v in finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
//              latrine owns_land {
//     foreach r in 3 4 5 {
//         capture noisily regress `v' i.hh_struc [aw=wt] if round==`r' & inlist(hh_struc,1,2)
//         if _rc==0 {
//             test 2.hh_struc
//             post `post_preg' ("`v'") (`r') (r(p))
//         }
//         else {
//             post `post_preg' ("`v'") (`r') (.)
//         }
//     }
// }
//
// * w_state-weighted vars
// foreach v in nosay_healthcare nosay_visits {
//     foreach r in 3 4 5 {
//         capture noisily regress `v' i.hh_struc [aw=w_state] if round==`r' & inlist(hh_struc,1,2)
//         if _rc==0 {
//             test 2.hh_struc
//             post `post_preg' ("`v'") (`r') (r(p))
//         }
//         else {
//             post `post_preg' ("`v'") (`r') (.)
//         }
//     }
// }
// postclose `post_preg'
//
// use `stars_preg', clear
// gen stars = ""
// forvalues i = 1/`=_N' {
//     quietly starify p[`i']
//     replace stars = "`stars'" in `i'
// }
// keep varname round stars
// reshape wide stars, i(varname) j(round)
// rename stars3 sig3
// rename stars4 sig4
// rename stars5 sig5
// gen sample = "pregnant"
// tempfile stars_pregnant
// save `stars_pregnant', replace
//
// *-------------------------------
// * 4) Stack + wide
// *-------------------------------
// use `collapsed_auto', clear
// append using `collapsed_wealth'
// append using `collapsed_N'
//
// reshape wide mean, i(varname) j(columns)
// rename mean1 Nuclear3
// rename mean2 Patrilocal3
// rename mean3 Nuclear4
// rename mean4 Patrilocal4
// rename mean5 Nuclear5
// rename mean6 Patrilocal5
//
// gen sample = "pregnant"
// merge 1:1 varname sample using `stars_pregnant', nogen
// replace sig3 = "" if varname=="n"
// replace sig4 = "" if varname=="n"
// replace sig5 = "" if varname=="n"
//
// append using `postpartum_sample'
//
//
// ************************************************************
// * PART 3: ORDER, SPACING, ROW LABELS
// ************************************************************
//
// input order
// 4
// 3
// 11
// 13
// 1
// 2
// 9
// 10
// 8
// 12
// 6
// 7
// 15
// 17
// 14
// 16
// 24
// 27
// 22
// 23
// 21
// 25
// 19
// 20 end
//
// sort order
// drop order
// gen order = _n
//
// expand 4 if varname=="nosay_healthcare"
// expand 2 if varname=="nosay_visits"
// expand 2 if varname=="finished_floor" & sample=="pregnant"
// expand 2 if varname=="owns_land" & sample=="pregnant"
// expand 2 if varname=="n" & sample=="pregnant"
// expand 4 if varname=="facility_birth"
// expand 2 if varname=="anc_four"
// expand 2 if varname=="finished_floor" & sample=="3-12 months ago last birth"
// expand 2 if varname=="owns_land" & sample=="3-12 months ago last birth"
// expand 2 if varname=="n" & sample=="3-12 months ago last birth"
//
// sort order
//
// input str150 rows
// "\textbf{Currently pregnant women}"
// ""
// "\textbf{Autonomy measures}"
// "\hspace*{2em}No say in own healthcare"
// "\hspace*{2em}No say in visits to family/friends"
// ""
// "\textbf{Wealth measures}"
// "\hspace*{2em}Finished floor"
// "\hspace*{2em}Electricity"
// "\hspace*{2em}Owns radio"
// "\hspace*{2em}Owns TV"
// "\hspace*{2em}Owns refrigerator"
// "\hspace*{2em}Owns bicycle"
// "\hspace*{2em}Owns car"
// "\hspace*{2em}Uses toilet/latrine"
// "\hspace*{2em}Owns land"
// ""
// "\textbf{N}"
// ""
// "\textbf{Women who gave birth 3--12 months before the survey}"
// ""
// "\textbf{Healthcare measures}"
// "\hspace*{2em}Birth in a health facility"
// "\hspace*{2em}4+ antenatal visits"
// ""
// "\textbf{Wealth measures}"
// "\hspace*{2em}Finished floor"
// "\hspace*{2em}Electricity"
// "\hspace*{2em}Owns radio"
// "\hspace*{2em}Owns TV"
// "\hspace*{2em}Owns refrigerator"
// "\hspace*{2em}Owns bicycle"
// "\hspace*{2em}Owns car"
// "\hspace*{2em}Uses toilet/latrine"
// "\hspace*{2em}Owns land"
// ""
// "\textbf{N}"
// end
//
// order rows
//
//
// ************************************************************
// * PART 4: DISPLAY STRINGS
// ************************************************************
// keep rows Nuclear* Patrilocal* sig*
//
// foreach r in 3 4 5 {
//
//     gen str12 dispNuclear`r'    = ""
//     gen str12 dispPatrilocal`r' = ""
//     gen str5  dispSig`r'        = ""
//
//     * N rows: integers with commas
//     replace dispNuclear`r' = string(round(Nuclear`r'), "%9.0fc") ///
//         if rows=="\textbf{N}"
//     replace dispPatrilocal`r' = string(round(Patrilocal`r'), "%9.0fc") ///
//         if rows=="\textbf{N}"
//
//     * Other rows: proportions
//     replace dispNuclear`r' = string(Nuclear`r', "%4.2f") ///
//         if !missing(rows) & rows!="\textbf{N}"
//     replace dispPatrilocal`r' = string(Patrilocal`r', "%4.2f") ///
//         if !missing(rows) & rows!="\textbf{N}"
//
//     * Significance stars
//     replace dispSig`r' = sig`r' if !missing(rows) & rows!="\textbf{N}"
//     replace dispSig`r' = "" if rows=="\textbf{N}"
// }
//
// * Blank out headers / spacer rows
// foreach var in dispNuclear3 dispPatrilocal3 dispSig3 ///
//                dispNuclear4 dispPatrilocal4 dispSig4 ///
//                dispNuclear5 dispPatrilocal5 dispSig5 {
//     replace `var' = "" if strpos(rows, "\textbf{")!=0 & rows!="\textbf{N}"
//     replace `var' = "" if rows==""
// }
//
// keep rows disp*
//
// list rows disp*, noobs clean
//
//
// ************************************************************
// * PART 5: EXPORT TO LATEX
// ************************************************************
// listtex ///
//     rows ///
//     dispNuclear3 dispPatrilocal3 dispSig3 ///
//     dispNuclear4 dispPatrilocal4 dispSig4 ///
//     dispNuclear5 dispPatrilocal5 dispSig5 ///
//     using "tables/table 1 summary stats.tex", ///
//     replace rstyle(tabular) ///
//     head( ///
//         "\begin{tabular}{lccccccccc}" ///
//         "\toprule" ///
//         " & \multicolumn{3}{c}{NFHS-3} & \multicolumn{3}{c}{NFHS-4} & \multicolumn{3}{c}{NFHS-5} \\\\" ///
//         "\cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10}" ///
//         " & Nuclear & Joint & Sig. & Nuclear & Joint & Sig. & Nuclear & Joint & Sig. \\\\" ///
//         "\midrule" ///
//     ) ///
//     foot( ///
//         "\bottomrule" ///
//         "\end{tabular}" ///
//     )
