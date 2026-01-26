*******************************************************
* Table: Patrilocal vs nuclear
* Outcomes:
*  - Pregnant: nosay_healthcare, nosay_visits
*  - Postpartum (3+ months): facility_birth, anc_four
*******************************************************

clear
set more off

use $all_nfhs_ir, clear

*******************************************************
* 1) Define samples + variables
*******************************************************

* Postpartum restriction
gen months_ago_last_birth = v008 - b3_01
gen postpartum = inrange(months_ago_last_birth, 3, .)

* Outcomes
gen facility_birth = (home_birth==0) if !missing(home_birth)

* Wealth controls
gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)
gen latrine        = !inlist(v116,30,31) if !missing(v116)
gen electricity    = v119==1 if !missing(v119)
gen owns_radio     = v120==1 if !missing(v120)
gen owns_tv        = v121==1 if !missing(v121)
gen owns_fridge    = v122==1 if !missing(v122)
gen owns_bike      = v123==1 if !missing(v123)
gen owns_car       = v125==1 if !missing(v125)
gen owns_land      = inlist(v745b,1,2,3) if !missing(v745b)

local wealth_controls ///
    finished_floor electricity owns_radio owns_tv owns_fridge ///
    owns_bike owns_car latrine 

*******************************************************
* 2) Post regression results
*******************************************************

tempfile results
postfile h ///
    str25 outcome ///
    byte round ///
    str20 spec ///
    double b se ///
    using `results', replace

* -------- Pregnant outcomes --------
foreach y in nosay_healthcare nosay_visits {
    foreach r in 3 4 5 {

        * no controls
        reghdfe `y' i.patrilocal [aw=wt] if round==`r' & pregnant==1
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["se","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal `wealth_controls' ///
            [aw=wt] if round==`r' & pregnant==1
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["se","1.patrilocal"])
    }
}

* -------- Postpartum outcomes --------
foreach y in facility_birth anc_four {
    foreach r in 3 4 5 {

        * no controls
        reghdfe `y' i.patrilocal [aw=wt] ///
            if round==`r' & postpartum==1
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["se","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal `wealth_controls' ///
            [aw=wt] if round==`r' & postpartum==1
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["se","1.patrilocal"])
    }
}

postclose h
use `results', clear



**************************************************
* Step 2: reshape wide so each outcome has b + se
**************************************************
reshape wide b se, i(round spec) j(outcome) string

**************************************************
* Step 3: create display strings (coef and se rows)
**************************************************
foreach v of varlist b* {
    gen str10 disp_`v' = string(`v', "%4.3f")
}

foreach v of varlist se* {
    gen str10 disp_`v' = "(" + string(`v', "%4.3f") + ")"
}


keep round spec disp*

