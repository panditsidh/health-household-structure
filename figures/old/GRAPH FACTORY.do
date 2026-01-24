
use $all_nfhs_ir, clear


gen recent_birth_date = v008 - b3_01 // how many months ago was this

keep if inrange(recent_birth_date,3,12)

*--------------------------------------------------------------------
* 0. Setup
*--------------------------------------------------------------------

* outcomes
local nat_outcomes   meat_egg_fish_weekly meat_egg_fish_daily dairy_daily home_birth anc_four
local dv_outcomes    beating_justified
local state_outcomes nosay_healthcare nosay_ownearnings nosay_visits
local outcomes `nat_outcomes' `state_outcomes' `dv_outcomes' 

*--------------------------------------------------------------------
* 1. Keep only necessary variables — MASSIVE SPEED BOOST
*--------------------------------------------------------------------
keep psu strata hh_struc round pregnant wt w_dv w_state `outcomes'
compress


*--------------------------------------------------------------------
* 2. Precompute all subpopulation flags once
*    sub_i_r_p = (hh_struc==i & round==r & pregnant==p)
*--------------------------------------------------------------------
foreach r of numlist 2/5 {
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            gen byte sub_`i'_`r'_`p' = (hh_struc==`i' & round==`r' & pregnant==`p')
        }
    }
}





*--------------------------------------------------------------------
* 3. Choose correct weights for this outcome
*--------------------------------------------------------------------






local nat_outcomes   meat_egg_fish_weekly meat_egg_fish_daily dairy_daily home_birth anc_four
local dv_outcomes    beating_justified
local state_outcomes nosay_healthcare nosay_ownearnings nosay_visits
// local outcomes `nat_outcomes' `state_outcomes' `dv_outcomes'

local outcomes anc_four


local lab_anc_four "Completed four ANC visits"
local lab_meat_egg_fish_weekly   "Consumes meat,egg,fish at least weekly"
local lab_meat_egg_fish_daily    "Consumes meat,egg,fish daily"
local lab_dairy_daily            "Consumes dairy daily"
local lab_home_birth             "Last birth occurred at home"

local lab_beating_justified      "Believes husband is justified in beating wife"

local lab_nosay_healthcare       "No say in own healthcare"
local lab_nosay_ownearnings      "No say in spending own earnings"
local lab_nosay_visits           "No say in visiting natal family"


cd "/Users/sidhpandit/Documents/GitHub/health-household-structure/figures"

* choose which outcome to run (example)

foreach outcome in `outcomes' {




preserve 


local outcome anc_four
local lab_anc_four "Completed four ANC visits"
local wvar wt

local ylab `lab_`outcome''

*-----------------

if strpos(" `nat_outcomes' ", " `outcome' ")   local wvar wt
if strpos(" `dv_outcomes' ",  " `outcome' ")   local wvar w_dv
if strpos(" `state_outcomes' ", " `outcome' ") local wvar w_state




svyset psu [pweight=`wvar'], strata(strata) singleunit(centered)


*--------------------------------------------------------------------
* 4. Create postfile to store results
*--------------------------------------------------------------------
tempfile results
postfile handle nfhs_round hh_type preg mean ci_low ci_high using `results', replace


*--------------------------------------------------------------------
* 5. FAST MAIN LOOP (no preserve/restore)
*--------------------------------------------------------------------
foreach r of numlist 2/5 {
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            
            * skip empty cells (important)
            count if sub_`i'_`r'_`p'
            if r(N)==0 continue

            * calculate mean + CI
            svy, subpop(sub_`i'_`r'_`p'): mean `outcome'
            
            matrix M = r(table)
            local mean = M[1,1]
            local low  = M[5,1]
            local high = M[6,1]

            * store results
            post handle (`r') (`i') (`p') (`mean') (`low') (`high')

        }
    }
}

postclose handle


*--------------------------------------------------------------------
* 6. Load results dataset
*--------------------------------------------------------------------
* diagnostics (optional but super useful)
di as txt "tempfile is: `results'"
confirm file "`results'"

use "`results'", clear


* Nice labels for panels
label define pregn 0 "Non-pregnant" 1 "Pregnant", replace
label values preg pregn

gen year = 1998 if nfhs_round==2
replace year = 2005 if nfhs_round==3
replace year = 2015 if nfhs_round==4
replace year = 2020 if nfhs_round==5

gen survey_year_nuclear = year - 0.8
gen survey_year_sasural = year
gen survey_year_natal   = year + 0.8

gen prop_label = string(round(mean, .01), "%4.2f")

#delimit ;
twoway 
    (rcap ci_low ci_high survey_year_nuclear if hh_type==1,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_type==1,
        msymbol(Oh)
        mcolor(black)
        mfcolor(white)
        msize(medium)
        mlabel(prop_label)
        mlabpos(9)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_type==2,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_type==2,
        msymbol(square)
        mcolor(black)
        msize(medium)
        mlabel(prop_label)
        mlabpos(12)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_type==3,
        lcolor(gs8)
        lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_type==3,
        msymbol(triangle)
        mcolor(gs8)
        msize(medium)
        mlabel(prop_label)
        mlabpos(3)
        mlabsize(tiny)
        mlabcolor(black)
    ),
    xlabel(1998 "1998-1999" 2005 "2005-2006" 2015 "2015-2016" 2020 "2019-2021", 
        labsize(small) angle(0)
    )
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
    ytitle("`ylab'", 
        size(medium)
    )
    xtitle("Survey year", size(medium))
    legend(
        order(
            2 "Nuclear"
            4 "Sasural"
            6 "Natal"
        )
        row(1)
        pos(6)
        size(medium)
    )
    graphregion(color(white))
    aspect(0.7)
    by(preg, col(2) note("") legend(off))
;

#delimit cr




graph export "`ylab'", as(png) replace


restore

}
