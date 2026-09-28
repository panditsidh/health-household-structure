/*

This file creates Figure X.

The figure shows changes across NFHS rounds in the household structure of
pregnant women. Household structure is split into three mutually exclusive
categories: nuclear, natal, and patrilocal extended households.

For each survey round, the figure plots the proportion of pregnant women in
each household structure category, with 95% confidence intervals.

The file uses the combined NFHS-1 through NFHS-5 analytic dataset currently
in memory.

*/


do "$paths"
 
preserve



cap drop allendorf_sample
gen allendorf_sample = (v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1) 

keep if allendorf_sample==1

keep if pregnant==1

*******************************************************
* Sample restrictions
*******************************************************

// keep if ever_married==1
// keep if pregnant==1

* restrict to the three household structures shown in the figure
keep if inlist(hh_struc, 1, 2, 3)


*******************************************************
* Create mutually exclusive household structure indicators
*******************************************************

gen nuclear_fig    = hh_struc==1
gen patrilocal_fig = hh_struc==2
gen natal_fig      = hh_struc==3

label var nuclear_fig    "Nuclear"
label var patrilocal_fig "Patrilocal extended"
label var natal_fig      "Natal"


* check that categories are mutually exclusive and exhaustive
egen hh_check = rowtotal(nuclear_fig patrilocal_fig natal_fig)
assert hh_check==1
drop hh_check



*******************************************************
* Survey design
*******************************************************

svyset psu [pweight=v005], strata(strata) singleunit(centered)



*******************************************************
* Calculate proportions and 95% confidence intervals
*******************************************************

tempfile figure_data

postfile results ///
    round ///
    hh_type ///
    estimate ///
    se ///
    ci_low ///
    ci_high ///
    using `figure_data', replace


levelsof round, local(rounds)

foreach r of local rounds {

    local type = 1

    foreach var in nuclear_fig patrilocal_fig natal_fig {

        quietly svy, subpop(if round==`r'): mean `var'

        local mean = _b[`var']
        local se   = _se[`var']

        local low  = `mean' - invnormal(.975)*`se'
        local high = `mean' + invnormal(.975)*`se'

        post results ///
            (`r') ///
            (`type') ///
            (`mean') ///
            (`se') ///
            (`low') ///
            (`high')

        local type = `type' + 1
    }
}

postclose results



*******************************************************
* Prepare figure dataset
*******************************************************

use `figure_data', clear


* convert proportions to percentages
foreach var in estimate se ci_low ci_high {
    replace `var' = `var' * 100
}


label define hh_type_lbl ///
    1 "Nuclear" ///
    2 "Patrilocal extended" ///
    3 "Natal"

label values hh_type hh_type_lbl


* labels for point estimates
gen estimate_label = string(estimate, "%4.1f")


* labels at the end of each line
gen end_label = ""

replace end_label = "Nuclear"             if hh_type==1 & round==5
replace end_label = "Patrilocal extended" if hh_type==2 & round==5
replace end_label = "Natal"               if hh_type==3 & round==5



*******************************************************
* Figure
*******************************************************

#delimit ;

twoway

    /*
    95% confidence intervals
    */

    (rcap ci_low ci_high round if hh_type==1,
        lcolor(gs6)
        lwidth(vthin))

    (rcap ci_low ci_high round if hh_type==2,
        lcolor(gs3)
        lwidth(vthin))

    (rcap ci_low ci_high round if hh_type==3,
        lcolor(gs10)
        lwidth(vthin))


    /*
    Connected point estimates
    */

    (connected estimate round if hh_type==1,
        lcolor(gs6)
        mcolor(gs6)
        lpattern(solid)
        lwidth(thin)
        msymbol(circle)
        msize(small))

    (connected estimate round if hh_type==2,
        lcolor(gs3)
        mcolor(gs3)
        lpattern(dash)
        lwidth(thin)
        msymbol(diamond)
        msize(small))

    (connected estimate round if hh_type==3,
        lcolor(gs10)
        mcolor(gs10)
        lpattern(shortdash)
        lwidth(thin)
        msymbol(triangle)
        msize(small))


    /*
    Point labels
    */

    (scatter estimate round if hh_type==1,
        msymbol(none)
        mlabel(estimate_label)
        mlabposition(12)
        mlabgap(2.5)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs6))

    (scatter estimate round if hh_type==2,
        msymbol(none)
        mlabel(estimate_label)
        mlabposition(12)
        mlabgap(2.5)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs3))

    (scatter estimate round if hh_type==3,
        msymbol(none)
        mlabel(estimate_label)
        mlabposition(6)
        mlabgap(2.5)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs10))


    /*
    Direct labels at NFHS-5
    */

    (scatter estimate round if hh_type==1 & round==5,
        msymbol(none)
        mlabel(end_label)
        mlabposition(3)
        mlabgap(3)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs6))

    (scatter estimate round if hh_type==2 & round==5,
        msymbol(none)
        mlabel(end_label)
        mlabposition(3)
        mlabgap(3)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs3))

    (scatter estimate round if hh_type==3 & round==5,
        msymbol(none)
        mlabel(end_label)
        mlabposition(3)
        mlabgap(3)
		msize(small)
        mlabsize(vsmall)
        mlabcolor(gs10))


    ,
    legend(off)

    xlabel(
        1 "1992–1993"
        2 "1998–1999"
        3 "2005–2006"
        4 "2015–2016"
        5 "2019–2021",
        labsize(small)
    )

    ylabel(
        10(10)60,
        labsize(small)
        angle(horizontal)
    )

    ytitle("Percent of pregnant coresiding married women ages 15–29", size(medsmall))
    xtitle("")

    xscale(range(.8 5.8))
    yscale(range(10 60))

    graphregion(color(white))
    plotregion(color(white))

    ysize(5)
    xsize(8)

    name(hh_structure_pregnant_trends, replace)

;

#delimit cr



*******************************************************
* Export figure

restore
