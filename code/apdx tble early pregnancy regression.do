
use $all_nfhs_ir, clear

gen less_edu = inlist(v106,0,1)
tab less_edu, m

label define lessedulbl ///
    0 "primary education or higher" ///
    1 "less than primary education" 
label values less_edu lessedulbl


* does not have living boy child
//v202 is "sons at home"
//v204 is "sons elsewhere"
//it is not missing for any pregnant or nonpregnant women
gen hasboy = v202 >0 & v202!=.
replace hasboy = 1 if v204 >0 & v204!=.
gen noboy = hasboy
recode noboy (1=0) (0=1)
tab hasboy noboy, m

label define noboylbl ///
    1 "does not have boy child" ///
    0 "has at least one boy child" 
label values noboy noboylbl

*age
gen agebin = .
replace agebin = 1 if inrange(v012, 15, 19)     // Teens
replace agebin = 2 if inrange(v012, 20, 24)     // Highest fertility
replace agebin = 3 if inrange(v012, 25, 29)     // Lower fertility
replace agebin = 4 if inrange(v012, 30, 49)     // Lowest fertility


label define agebinlbl 1 "15–19" 2 "20–24" 3 "25–29" 4 "30–49"
label values agebin agebinlbl

gen age1519 = agebin==1
gen age2024 = agebin==2
gen age2529 = agebin==3
gen age3049 = agebin==4



//birth spacing is time between last delivery and interview for non-pregnant women and time between last delivery and estimated conception of current pregnancy for pregnant women
//it is only defined for women that have had at least one live birth
//v008 is the date of the interview and b3 is the date of birth of the child
gen birth_space = (v008 - b3_01) + 9 if preg==0 & !missing(b3_01)
replace birth_space = (v008 - b3_01) + (9-gestdur) if preg==1 & !missing(b3_01)

gen bs = .
replace bs = 1 if birth_space < 24
replace bs = 2 if inrange(birth_space, 24, 36)
replace bs = 3 if birth_space > 36

gen bs_below2 = bs==1
gen bs_2to3 = bs==2
gen bs_above3 = bs==3
gen bs_noprior = parity<2

label define paritylbl ///
    1 "1 (no live births)" ///
    2 "2 (1 live birth)" ///
	3 "3 (2 live births)" ///
	4 "4+ (3+ live births)" 	
label values parity paritylbl

label define bslbl /// 
	1 "under 2 years" ///
	2 "2-3 years" ///
	3 "over 3 years" 

label values bs bslbl

//now generate a variable that combines parity and birth spacing
gen parity_bs = .
replace parity_bs = 1 if parity==1

local i = 2
foreach p of numlist 2/4 {
	
	foreach b of numlist 1/3 {
		
		replace parity_bs = `i' if parity==`p' & bs==`b'		
		local i = `i' + 1
	}
}



forvalues i = 1/10 {
    gen parity_bs`i' = parity_bs == `i'
}

label define parity_bs_lbl ///
    1 "No births/1 birth, NA spacing" ///
    2 "1 birth, below 2y spacing" ///
    3 "1 birth, 2–3y spacing" ///
    4 "1 birth, 3+y spacing" ///
    5 "2 births, below 2y spacing" ///
    6 "2 births, 2–3y spacing" ///
    7 "2 births, 3+y spacing" ///
    8 "3+ births, below 2y spacing" ///
    9 "3+ births, 2–3y spacing" ///
   10 "3+ births, 3+y spacing"
label values parity_bs parity_bs_lbl




eststo clear

keep if v213==1 // self reports pregnant
keep if !missing(gestdur)

* drop women who are not part of the 5 social groups we study
drop if group==6

gen gestdur_1or2 = inlist(gestdur,1,2) // self reports 1 or 2 months pregnant

*---------------------------------
* Run separately by NFHS round
*---------------------------------

#delimit ;
reghdfe gestdur_1or2
    i.less_edu
    i.rural
    i.noboy
    i.agebin
    i.parity_bs
    i.wealth
    if round==3, cluster(psu);
#delimit cr
eststo model_3

#delimit ;
reghdfe gestdur_1or2
    i.less_edu
    i.rural
    i.noboy
    i.agebin
    i.parity_bs
    i.wealth
    if round==4, cluster(psu);
#delimit cr
eststo model_4

#delimit ;
reghdfe gestdur_1or2
    i.less_edu
    i.rural
    i.noboy
    i.agebin
    i.parity_bs
    i.wealth
    if round==5, cluster(psu);
#delimit cr
eststo model_5

*---------------------------------
* LaTeX export
*---------------------------------

#delimit ;
esttab model_3 model_4 model_5 using "tables/tableA1_predicting_first_quarter_pregnancy1.tex",
    replace
    booktabs
    nonumbers
    nonote
    label
    se
    star(* 0.05 ** 0.01 *** 0.001)
    b(3) se(4)
    mtitle("2005--2006" "2015--2016" "2019--2021")
    mgroups("reports of 1 or 2 months of pregnancy", pattern(1 0 0) ///
        span prefix(\multicolumn{@span}{c}{) suffix(}) ///
        erepeat(\cmidrule(lr){@span}))
    drop(0.less_edu 0.rural 0.noboy 1.agebin 1.parity_bs 1.wealth)
    coeflabels( ///
        1.less_edu "\hspace*{1em}Less than primary education" ///
        1.rural    "\hspace*{1em}Rural resident" ///
        1.noboy    "\hspace*{1em}Does not have boy child" ///
        2.agebin   "\hspace*{1em}20--24" ///
        3.agebin   "\hspace*{1em}25--29" ///
        4.agebin   "\hspace*{1em}30--49" ///
        2.parity_bs "\hspace*{1em}1 birth, below 2y spacing" ///
        3.parity_bs "\hspace*{1em}1 birth, 2--3y spacing" ///
        4.parity_bs "\hspace*{1em}1 birth, above 3y spacing" ///
        5.parity_bs "\hspace*{1em}2 births, below 2y spacing" ///
        6.parity_bs "\hspace*{1em}2 births, 2--3y spacing" ///
        7.parity_bs "\hspace*{1em}2 births, above 3y spacing" ///
        8.parity_bs "\hspace*{1em}3+ births, below 2y spacing" ///
        9.parity_bs "\hspace*{1em}3+ births, 2--3y spacing" ///
        10.parity_bs "\hspace*{1em}3+ births, above 3y spacing" ///
        2.wealth   "\hspace*{1em}2nd quartile" ///
        3.wealth   "\hspace*{1em}3rd quartile" ///
        4.wealth   "\hspace*{1em}4th quartile" ///
        _cons      "\hspace*{1em}Constant")
    refcat( ///
        2.agebin "\textbf{Age categories} \\ (15--19 omitted)" ///
        2.parity_bs "\textbf{Parity \& time since last live birth categories} \\ (No prior births omitted)" ///
        2.wealth "\textbf{Wealth quartiles} \\ (1st quartile omitted)", nolabel)
    stats(N, fmt(%15.0fc) label("\textbf{N}"));
#delimit cr
