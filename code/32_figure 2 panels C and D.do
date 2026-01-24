/*

Wanted results dataset format:

nfhs_round | hh_type | outcome    | mean | ci_low | ci_high | N
-----------+---------+------------+------+--------+---------+---
3          | 1       | home_birth | ...
3          | 1       | anc_four   | ...

*/

************************************************************
* Build ONE results tempfile for MULTIPLE outcomes
* Postpartum sample: last birth 3–12 months ago
************************************************************

use "$all_nfhs_ir", clear
keep if inlist(round,3,4,5)

* months since most recent birth (you used b3_01)
gen months_ago_last_birth = v008 - b3_01
keep if inrange(months_ago_last_birth, 3, 12)

svyset psu [pweight=wt], strata(strata) singleunit(centered)

************************************************************
* Subpop indicators (hh_struc x round)
************************************************************
foreach r of numlist 3/5 {
    foreach i of numlist 1/3 {
        gen byte sub_`i'_`r' = (hh_struc==`i' & round==`r')
    }
}

************************************************************
* Define outcomes
************************************************************
local outcomes "home_birth anc_four"

************************************************************
* Post results for BOTH outcomes into ONE tempfile
************************************************************
tempfile results_pp
cap postclose handle

postfile handle ///
    nfhs_round hh_type str30 outcome mean ci_low ci_high N ///
    using `results_pp', replace

foreach outcome of local outcomes {

    foreach r of numlist 3/5 {
        foreach i of numlist 1/3 {

            * skip empty hh_struc x round cells
            quietly count if sub_`i'_`r'==1
            if r(N)==0 continue

            * N for this cell for THIS outcome (nonmissing)
            quietly count if sub_`i'_`r'==1 & !missing(`outcome')
            local cellN = r(N)

            if `cellN' > 0 {
                quietly svy, subpop(sub_`i'_`r'): mean `outcome'
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

            post handle ///
                (`r') ///
                (`i') ///
                ("`outcome'") ///
                (`mean') ///
                (`low') ///
                (`high') ///
                (`cellN')
        }
    }
}

postclose handle
use `results_pp', clear

************************************************************
* Formatting vars for graphing
************************************************************
label var nfhs_round  "NFHS round"
label var hh_type     "Household structure"
label var outcome     "Outcome"
label var mean        "Mean"
label var ci_low      "CI low"
label var ci_high     "CI high"
label var N           "Cell N (nonmissing outcome)"

* X-axis: round -> year
gen year = .
replace year = 2005 if nfhs_round==3
replace year = 2015 if nfhs_round==4
replace year = 2020 if nfhs_round==5

* offsets so the 3 hh types don't overlap
gen survey_year_nuclear = year - 0.8 if hh_type==1
gen survey_year_sasural = year        if hh_type==2
gen survey_year_natal   = year + 0.8 if hh_type==3

* point labels
gen prop_label = string(round(mean, .01), "%4.2f") if !missing(mean)

************************************************************
* Panel A: home_birth
************************************************************
preserve
keep if outcome=="home_birth"

quietly summarize N if nfhs_round==3, meanonly
local N2005 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==4, meanonly
local N2015 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==5, meanonly
local N2020 : display %7.0fc r(sum)

#delimit ;
twoway 
    (rcap ci_low ci_high survey_year_nuclear if hh_type==1,
        lcolor(black) lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_type==1,
        msymbol(Oh) mcolor(black) mfcolor(white) msize(medium)
        mlabel(prop_label) mlabpos(9) mlabsize(tiny) mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_type==2,
        lcolor(black) lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_type==2,
        msymbol(square) mcolor(black) msize(medium)
        mlabel(prop_label) mlabgap(*2) mlabpos(12) mlabsize(tiny) mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_type==3,
        lcolor(gs8) lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_type==3,
        msymbol(triangle) mcolor(gs8) msize(medium)
        mlabel(prop_label) mlabpos(3) mlabsize(tiny) mlabcolor(black)
    ),
    xlabel(2005 "2005-2006" 2015 "2015-2016" 2020 "2019-2021", labsize(small) angle(0))
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
    xscale(range(2003 2023))
    ytitle("Last birth at home", size(medium))
    xtitle("Survey year", size(medium))
    legend(order(2 "Nuclear" 4 "Patrilocal" 6 "Natal") row(1) pos(6) size(medium))
    graphregion(color(white))
    aspect(0.7)
    caption(
        "Sample: women with a birth 3–12 months before interview."
        "Sample sizes are `N2005', `N2015', and `N2020' for survey years"
        "2005-2006, 2015-2016, and 2019-2021, respectively.", size(small)
    );
#delimit cr

restore
graph save "Graph" "figures/figure 2 panel C.gph", replace 
************************************************************
* Panel B: anc_four
************************************************************
preserve
keep if outcome=="anc_four"

quietly summarize N if nfhs_round==3, meanonly
local N2005 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==4, meanonly
local N2015 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==5, meanonly
local N2020 : display %7.0fc r(sum)

#delimit ;
twoway 
    (rcap ci_low ci_high survey_year_nuclear if hh_type==1,
        lcolor(black) lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_type==1,
        msymbol(Oh) mcolor(black) mfcolor(white) msize(medium)
        mlabel(prop_label) mlabpos(9) mlabsize(tiny) mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_type==2,
        lcolor(black) lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_type==2,
        msymbol(square) mcolor(black) msize(medium)
        mlabel(prop_label) mlabgap(*2) mlabpos(12) mlabsize(tiny) mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_type==3,
        lcolor(gs8) lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_type==3,
        msymbol(triangle) mcolor(gs8) msize(medium)
        mlabel(prop_label) mlabpos(3) mlabsize(tiny) mlabcolor(black)
    ),
    xlabel(2005 "2005-2006" 2015 "2015-2016" 2020 "2019-2021", labsize(small) angle(0))
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
    xscale(range(2003 2023))
    ytitle("4+ ANC visits in last pregnancy", size(medium))
    xtitle("Survey year", size(medium))
    legend(order(2 "Nuclear" 4 "Patrilocal" 6 "Natal") row(1) pos(6) size(medium))
    graphregion(color(white))
    aspect(0.7)
    caption(
        "Sample: women with a birth 3–12 months before interview."
        "Sample sizes are `N2005', `N2015', and `N2020' for survey years"
        "2005-2006, 2015-2016, and 2019-2021, respectively.", size(small)
    );
#delimit cr

restore
graph save "Graph" "figures/figure 2 panel D.gph", replace
