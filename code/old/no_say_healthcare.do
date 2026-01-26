use $all_nfhs_ir, clear



foreach r of numlist 3/5 {
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            gen byte sub_`i'_`r'_`p' = (hh_struc==`i' & round==`r' & pregnant==`p')
			
        }
    }
	
	
}


local lab_nosay_healthcare       "No say in own healthcare"
local ylab "`lab_nosay_healthcare'"


svyset psu [pweight= w_state], strata(strata) singleunit(centered)

tempfile results
postfile handle nfhs_round hh_type preg mean ci_low ci_high using `results', replace

foreach r of numlist 3/5 {
	
	count if round==`r' & pregnant==0 & !missing(nosay_healthcare)
	local round`r'0 = r(N)
	count if round==`r' & pregnant==1 & !missing(nosay_healthcare)
	local round`r'1 = r(N) 
	
	
	
	
    foreach i of numlist 1/3 {
        foreach p of numlist 0/1 {
            
			
			
            * skip empty cells (important)
            quietly count if sub_`i'_`r'_`p'
            if r(N)==0 continue
			
			local a`i'_`r'_`p' = r(N)

            * calculate mean + CI
			
			if `round`r'`p''!=0 {
				quietly svy, subpop(sub_`i'_`r'_`p'): mean nosay_healthcare
				matrix M = r(table)
				local mean = M[1,1]
				local low  = M[5,1]
				local high = M[6,1]

			}
			
			else {
				local mean = .
				local low = . 
				local high = .
			}
			
			
            
            
            * store results
            post handle (`r') (`i') (`p') (`mean') (`low') (`high')

        }
    }
}

postclose handle

use `results', clear
gen year = 2005 if nfhs_round==3
replace year = 2015 if nfhs_round==4
replace year = 2020 if nfhs_round==5

gen survey_year_nuclear = year - 0.8
gen survey_year_sasural = year
gen survey_year_natal   = year + 0.8

gen prop_label = string(round(mean, .01), "%4.2f")

#delimit ;
twoway 
    (rcap ci_low ci_high survey_year_nuclear if hh_type==1 & preg==1,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_type==1 & preg==1,
        msymbol(Oh)
        mcolor(black)
        mfcolor(white)
        msize(medium)
        mlabel(prop_label)
        mlabpos(9)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_type==2 & preg==1,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_type==2 & preg==1,
        msymbol(square)
        mcolor(black)
        msize(medium)
        mlabel(prop_label)
        mlabpos(12)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_type==3 & preg==1,
        lcolor(gs8)
        lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_type==3 & preg==1,
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
	caption(" pregnant, 2005–06: `round31' pregnant" ///
				"2015–16: `round41' pregnant, 2019–21: `round51' pregnant");

#delimit cr
cd "/Users/bipasabanerjee/Documents/GitHub/health-household-structure/figures3_4_5"
graph save "`ylab'_pregnant", replace
graph export "`ylab'_pregnant.png", as(png) replace
