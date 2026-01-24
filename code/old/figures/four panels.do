****************************************************
* Four-panel figure: household structure x NFHS round
* Outcomes:
*   1. nosay_healthcare
*   2. prob_health_money
*   3. dairy_daily
*   4. bmi
****************************************************

use $all_nfhs_ir, clear

* If you still want to blank round 2 for these vars (not strictly needed now):
replace prob_health_permission = . if round==2
replace prob_health_money      = . if round==2

*--------------------------------------------------------------------
* 0. Outcomes and labels
*--------------------------------------------------------------------

* Outcomes by weight type
local nat_outcomes   prob_health_money dairy_daily bmi
local state_outcomes nosay_healthcare
local dv_outcomes

local outcomes `state_outcomes' `nat_outcomes'

*--------------------------------------------------------------------
* 1. Keep only necessary variables
*--------------------------------------------------------------------
keep psu strata hh_struc round pregnant wt w_dv w_state `outcomes'
compress

*--------------------------------------------------------------------
* 2. Precompute subpop flags (NFHS 3–5 only)
*--------------------------------------------------------------------
foreach r of numlist 3/5 {
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            gen byte sub_`i'_`r'_`p' = (hh_struc==`i' & round==`r' & pregnant==`p')
        }
    }
}

*--------------------------------------------------------------------
* 3. Axis labels for outcomes
*--------------------------------------------------------------------
local lab_prob_health_money   "Money is a problem for healthcare access"
local lab_dairy_daily         "Consumes dairy daily"
local lab_bmi                 "Body Mass Index (BMI)"
local lab_nosay_healthcare    "No say in own healthcare"

*--------------------------------------------------------------------
* 4. Directory for saving graphs
*--------------------------------------------------------------------
cd "/Users/sidhpandit/Documents/GitHub/household-structure/figures/"

*--------------------------------------------------------------------
* 5. Loop over 4 outcomes: build graph for pregnant women only
*--------------------------------------------------------------------
foreach outcome in nosay_healthcare prob_health_money dairy_daily bmi {

    preserve

    * Choose weight
    if strpos(" `nat_outcomes' ", " `outcome' ")   local wvar wt
    if strpos(" `dv_outcomes' ",  " `outcome' ")   local wvar w_dv
    if strpos(" `state_outcomes' ", " `outcome' ") local wvar w_state

    * Svyset
    svyset psu [pweight=`wvar'], strata(strata) singleunit(centered)

    * Label for y-axis
    local ylab `lab_`outcome''

    *------------------------------------------------------------
    * 5a. Postfile for results
    *------------------------------------------------------------
    tempfile results
    postfile handle nfhs_round hh_type preg mean ci_low ci_high using `results', replace

    * Store sample sizes for caption (pregnant only)
    foreach r of numlist 3/5 {
        count if round==`r' & pregnant==0 & !missing(`outcome')
        local round`r'0 = r(N)
        count if round==`r' & pregnant==1 & !missing(`outcome')
        local round`r'1 = r(N)
    }

    *------------------------------------------------------------
    * 5b. Main svy loop: NFHS 3–5, hh_struc 1–3, preg 0/1
    *------------------------------------------------------------
    foreach r of numlist 3/5 {
        foreach i of numlist 1/3 {
            foreach p of numlist 0/1 {

                quietly count if sub_`i'_`r'_`p'
                if r(N)==0 continue

                if `round`r'`p'' != 0 {
                    quietly svy, subpop(sub_`i'_`r'_`p'): mean `outcome'
                    matrix M = r(table)
                    local mean = M[1,1]
                    local low  = M[5,1]
                    local high = M[6,1]
                }
                else {
                    local mean = .
                    local low  = .
                    local high = .
                }

                post handle (`r') (`i') (`p') (`mean') (`low') (`high')
            }
        }
    }

    postclose handle

    *------------------------------------------------------------
    * 5c. Prepare dataset for plotting (NFHS 3–5 only, pregnant only)
    *------------------------------------------------------------
    use `results', clear
    keep if inlist(nfhs_round,3,4,5)

    gen year = .
    replace year = 2005 if nfhs_round==3
    replace year = 2015 if nfhs_round==4
    replace year = 2020 if nfhs_round==5

    gen survey_year_nuclear = year - 0.8
    gen survey_year_sasural = year
    gen survey_year_natal   = year + 0.8

    gen prop_label = string(round(mean, .01), "%4.2f")

    * Only pregnant women for plotting
    keep if preg==1

    * y-axis options differ for BMI vs proportions
    local yopts ""
    if inlist("`outcome'","nosay_healthcare","prob_health_money","dairy_daily") {
        local yopts "ylabel(0(.2)1, labsize(medium) grid) yscale(range(0 1))"
    }
    else if "`outcome'"=="bmi" {
        * Let Stata pick the range, just add grid
        local yopts "ylabel(, labsize(medium) grid)"
    }

    *------------------------------------------------------------
    * 5d. Graph: pregnant only
    *------------------------------------------------------------
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
        xlabel(2005 "2005-2006" 2015 "2015-2016" 2020 "2019-2021", 
            labsize(small) angle(0)
        )
        `yopts'
        ytitle("`ylab'", size(medium))
        xtitle("Survey year", size(medium))
        legend(
            order(
                2 "Nuclear"
                4 "Patrilocal"
                6 "Natal"
            )
            row(1)
            pos(6)
            size(medium)
        )
        graphregion(color(white))
        aspect(0.7)
        caption("2005–06: `round31' pregnant, 2015–16: `round41' pregnant, 2019–21: `round51' pregnant");
    #delimit cr

    graph save "`outcome'_pregnant", replace
    graph export "`outcome'_pregnant.png", as(png) replace

    restore
}

*--------------------------------------------------------------------
* 6. Combine into four-panel figure (2x2)
*--------------------------------------------------------------------

graph combine "code/tables/prob_health_money_pregnant.gph" "code/tables/dairy_daily_pregnant.gph" "code/tables/bmi_pregnant.gph"



graph combine                         ///
    nosay_healthcare_pregnant         ///
    prob_health_money_pregnant        ///
    dairy_daily_pregnant              ///
    bmi_pregnant,                     ///
    col(2) row(2)                     ///
    graphregion(color(white))         ///
    imargin(zero)

graph save "four_panel_pregnant", replace
graph export "four_panel_pregnant.png", as(png) replace
