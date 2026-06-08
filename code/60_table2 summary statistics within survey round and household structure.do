
/*

This file creates Table 2.

Table 2 shows means for outcomes and wealth variables by household structure
in NFHS-3, NFHS-4, and NFHS-5. The two household types shown are nuclear
households and patrilocal extended households.

The file first makes the part of the table for the recent birth sample. This is
the sample of ever-married women who gave birth 3 to 12 months before the survey.

It then makes the part of the table for the pregnant sample. This is the sample
of ever-married women who report being 3 or more months pregnant at the time of
the survey.

For each variable and survey round, the file calculates weighted means for
nuclear and patrilocal extended households.

At the end, the file combines the pregnant sample and recent birth sample
results, formats the rows, and exports the LaTeX table.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/


************************************************************
* first - WOMEN WHO GAVE BIRTH 3-12 MONTHS BEFORE SURVEY
************************************************************

do "$paths"

use "$all_nfhs_ir", clear

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

keep if sample==1

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
* 2) Stack + wide
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

tempfile postpartum_sample
save `postpartum_sample', replace


************************************************************
* CURRENTLY PREGNANT WOMEN
************************************************************

use "$all_nfhs_ir", clear

keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)
keep if ever_married==1
keep if sample==2

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
* 1) Wealth means (w_state)
*-------------------------------
preserve

* The pregnant sample is restricted to women who were asked the decision-making
* questions, which are in the state module. For this table, pregnant-sample
* estimates use state-module weights.

collapse (mean) ///
	finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
	latrine owns_land ///
	[aw=w_state], by(columns)

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
* 3) Stack + wide
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

append using `postpartum_sample'


************************************************************
* ORDER, SPACING, ROW LABELS
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
replace rows = "\textbf{\shortstack[l]{Autonomy measures\\(pregnant sample)}}" if order==1
replace rows = "No say in own healthcare"                  if order==2
replace rows = "No say in visits to family/friends"        if order==3
replace rows = ""                                          if order==4

* Healthcare
replace rows = "\textbf{\shortstack[l]{Healthcare measures\\(recent birth sample)}}" if order==5
replace rows = "Birth in a health facility"                 if order==6
replace rows = "4+ prenatal visits"                         if order==7
replace rows = ""                                           if order==8

* Wealth (pregnant)
replace rows = "\textbf{\shortstack[l]{Wealth measures\\(pregnant sample)}}" if order==9
replace rows = "Finished floor"           if order==10
replace rows = "Electricity"              if order==11
replace rows = "Owns radio"               if order==12
replace rows = "Owns TV"                  if order==13
replace rows = "Owns refrigerator"        if order==14
replace rows = "Owns bicycle"             if order==15
replace rows = "Owns car"                 if order==16
replace rows = "Uses toilet/latrine"      if order==17
replace rows = "Owns land"                if order==18
replace rows = ""                         if order==19

* Wealth (recent birth)
replace rows = "\textbf{\shortstack[l]{Wealth measures\\(recent birth sample)}}" if order==20
replace rows = "Finished floor"           if order==21
replace rows = "Electricity"              if order==22
replace rows = "Owns radio"               if order==23
replace rows = "Owns TV"                  if order==24
replace rows = "Owns refrigerator"        if order==25
replace rows = "Owns bicycle"             if order==26
replace rows = "Owns car"                 if order==27
replace rows = "Uses toilet/latrine"      if order==28
replace rows = "Owns land"                if order==29
replace rows = ""                         if order==30

* N rows
replace rows = "\textbf{N (pregnant sample)}"      if order==31
replace rows = ""                                  if order==32
replace rows = "\textbf{N (recent birth sample)}"  if order==33
replace rows = ""                                  if order==34

order rows


************************************************************
* DISPLAY STRINGS
************************************************************

keep rows Nuclear* Patrilocal*

gen byte isNrow = inlist(rows, ///
    "\textbf{N (pregnant sample)}", ///
    "\textbf{N (recent birth sample)}")

foreach r in 3 4 5 {

    gen str12 dispNuclear`r'    = ""
    gen str12 dispPatrilocal`r' = ""

    * N rows: integers with commas
    replace dispNuclear`r' = string(round(Nuclear`r'), "%9.0fc") if isNrow
    replace dispPatrilocal`r' = string(round(Patrilocal`r'), "%9.0fc") if isNrow

    * Other non-header, non-spacer rows: proportions
    replace dispNuclear`r' = string(Nuclear`r', "%4.2f") ///
        if rows!="" & !isNrow & strpos(rows, "\textbf{")==0

    replace dispPatrilocal`r' = string(Patrilocal`r', "%4.2f") ///
        if rows!="" & !isNrow & strpos(rows, "\textbf{")==0
}

* Blank out section header rows and spacer rows
foreach var in dispNuclear3 dispPatrilocal3 ///
               dispNuclear4 dispPatrilocal4 ///
               dispNuclear5 dispPatrilocal5 {
    replace `var' = "" if strpos(rows, "\textbf{")!=0 & !isNrow
    replace `var' = "" if rows==""
}

drop isNrow
keep rows disp*

list rows disp*, noobs clean

drop if rows=="Owns land"


************************************************************
* EXPORT TO LATEX
************************************************************

listtex ///
    rows ///
    dispNuclear3 dispPatrilocal3 ///
    dispNuclear4 dispPatrilocal4 ///
    dispNuclear5 dispPatrilocal5 ///
    using "tables/table2_summarystats_byhhstruc.tex", ///
    replace rstyle(tabular) ///
    head( ///
"\begin{tabular}{lcccccc}" ///
"\toprule" ///
" & \multicolumn{2}{c}{2005-2006} & \multicolumn{2}{c}{2015-2016} & \multicolumn{2}{c}{2019-2021} \\" ///
"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}" ///
" & Nuclear & \shortstack{Patrilocal\\Extended} & Nuclear & \shortstack{Patrilocal\\Extended} & Nuclear & \shortstack{Patrilocal\\Extended} \\" ///
"\midrule" ///
) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    )

