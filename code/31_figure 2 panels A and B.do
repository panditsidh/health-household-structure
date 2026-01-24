/*

In order to make the graph we want we need our results in this format of a stata dataset.

nfhs_round | hh_type | outcome            | mean | ci_low | ci_high | N
-----------+---------+--------------------+------+--------+---------+---
3          | 1       | nosay_healthcare   | ...
3          | 1       | nosay_visits       | ...


*/

************************************************************
* Build ONE results tempfile for MULTIPLE outcomes
************************************************************

use "$all_nfhs_ir", clear
keep if inlist(round,3,4,5)

* Restrict once
keep if pregnant==1
keep if preg==1

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
local outcomes "nosay_healthcare nosay_visits"

************************************************************
* Post results for BOTH outcomes into ONE tempfile
************************************************************
tempfile results
cap postclose handle

postfile handle ///
    nfhs_round hh_type str30 outcome mean ci_low ci_high N ///
    using `results', replace

foreach outcome of local outcomes {

    * Round-specific Ns (optional, for captions)
    foreach r of numlist 3/5 {
        quietly count if round==`r' & !missing(`outcome')
        local round`r'_`outcome' = r(N)
    }

    foreach r of numlist 3/5 {
        foreach i of numlist 1/3 {

            * skip empty hh_struc x round cells
            quietly count if sub_`i'_`r'==1
            if r(N)==0 continue

            * N for this cell for THIS outcome
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
use `results', clear


* At this point we have the results in the stata dataset format we want. The rest of the code is just formatting and making the figure


label var nfhs_round  "NFHS round"
label var hh_type     "Household structure"
label var mean        "Mean"
label var ci_low      "CI low"
label var ci_high     "CI high"
label var N           "Cell N (nonmissing outcome)"

************************************************************
* Create x-axis year variables for your twoway syntax
* (one x var per hh_type, missing otherwise)
************************************************************
gen year = 1998 if nfhs_round==2
replace year = 2005 if nfhs_round==3
replace year = 2015 if nfhs_round==4
replace year = 2020 if nfhs_round==5

gen survey_year_nuclear = year - 0.8
gen survey_year_sasural = year
gen survey_year_natal   = year + 0.8

gen prop_label = string(round(mean, .01), "%4.2f")


* First command is for nosay healthcare

preserve

keep if outcome=="nosay_healthcare"

quietly summarize N if nfhs_round==3, meanonly
local N2005 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==4, meanonly
local N2015 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==5, meanonly
local N2020 : display %7.0fc r(sum)


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
		mlabgap(*2)
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
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
	xscale(range(2003 2023))
    ytitle("No say in own healthcare", size(medium))
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
	caption("Sample is restricted to currently pregnant women." "Sample sizes are `N2005', `N2015', and `N2020' for survey years" "2005-2006, 2015-2016, and 2019-2021, respectively.", size(small));

#delimit cr

restore


graph save "Graph" "figures/figure 2 panel A.gph", replace


* Now for the other outcome

preserve

keep if outcome=="nosay_visits"

quietly summarize N if nfhs_round==3, meanonly
local N2005 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==4, meanonly
local N2015 : display %7.0fc r(sum)

quietly summarize N if nfhs_round==5, meanonly
local N2020 : display %7.0fc r(sum)

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
        mlabgap(*2)
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
    ylabel(0(.2)1, labsize(medium) grid)
    yscale(range(0 1))
    xscale(range(2003 2023))
    ytitle("No say in visits", size(medium))
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
    caption(
        "Sample is restricted to currently pregnant women."
        "Sample sizes are `N2005', `N2015', and `N2020' for survey years"
        "2005-2006, 2015-2016, and 2019-2021, respectively.", size(small)
    );
#delimit cr

restore


graph save "Graph" "figures/figure 2 panel B.gph", replace
