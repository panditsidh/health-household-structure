use $all_nfhs_ir, clear


keep if pregnant==1
svyset psu [pw=v005], strata(strata) singleunit(centered)


replace gestdur = 9 if gestdur>9

capture postclose handle
tempfile results
postfile handle nfhs_round hh_struc mean ci_low ci_high using `results', replace

foreach r in 2 3 4 5 { 

    svy, subpop(if pregnant==1 & round==`r'): reg bmi c.gestdur i.hh_struc
   
	display("ROUND is `r'")
	
    margins hh_struc, at(gestdur = 4)

    matrix M = r(table)
	
	foreach i in 1 2 3 {
		
		local mean = M[1,`i']
        local low  = M[5,`i']
        local high = M[6,`i']

        post handle (`r') (`i') (`mean') (`low') (`high')
		
	}	

}

postclose handle

use `results', clear

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
    (rcap ci_low ci_high survey_year_nuclear if hh_struc==1,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_nuclear if hh_struc==1,
        msymbol(Oh)
        mcolor(black)
        mfcolor(white)
        msize(medium)
        mlabel(prop_label)
        mlabpos(9)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_sasural if hh_struc==2,
        lcolor(black)
        lwidth(medthick)
    )
    (scatter mean survey_year_sasural if hh_struc==2,
        msymbol(square)
        mcolor(black)
        msize(medium)
        mlabel(prop_label)
        mlabpos(12)
        mlabsize(tiny)
        mlabcolor(black)
    )
    (rcap ci_low ci_high survey_year_natal if hh_struc==3,
        lcolor(gs8)
        lwidth(medthick)
    )
    (scatter mean survey_year_natal if hh_struc==3,
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
    ylabel(19(1)24, labsize(medium) grid)
    yscale(range(19 24))
    ytitle("Body mass index", size(medium))
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
    aspect(0.7);
	

graph export "/Users/sidhpandit/Documents/GitHub/household-structure/figures/hhstruc_bmi_preg.png", as(png) name("Graph")
