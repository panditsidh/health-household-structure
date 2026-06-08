/*

This file creates Appendix Figure C-3.

The figure shows changes across NFHS-3, NFHS-4, and NFHS-5 in household
structure among women in the sample defined as currently married women ages 15-29 who are
usual residents and currently living with their husbands.

This is the same sample used in Allendorf (2013) except that paper restricts to only nuclear and patrilocal households

We keep usual residents in natal households too for comparison

The figure shows the weighted share of women living in nuclear households,
natal households as usual residents, and patrilocal extended households.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/

use "$all_nfhs_ir", clear

cap drop allendorf_sample

gen allendorf_sample = (v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1) 

/*
married
between ages 15-29
usual resident
currently residing with husband
*/



keep if ever_married==1
keep if nuclear | natal | patrilocal
keep if inlist(round, 3, 4, 5)

*******************************************************
* Split natal women into usual residents and visitors
*******************************************************
gen usual_resident = v135==1 if inlist(v135,1,2)
gen visitor        = v135==2 if inlist(v135,1,2)

gen natal_usual_resident = natal==1 & usual_resident==1 if inlist(v135,1,2)
gen natal_visitor        = natal==1 & visitor==1        if inlist(v135,1,2)

label var natal_usual_resident "Natal: usual resident"
label var natal_visitor        "Natal: visitor"



*******************************************************
* Common style: grayscale
*******************************************************
local nuclear_gray      "gs11%75"
local natal_ur_gray     "gs14%85"
local natal_vis_gray    "gs8%55"
local patrilocal_gray   "gs6%70"


*******************************************************
* Sample sizes for figure note
*******************************************************
local N3 ""
local N4 ""
local N5 ""

foreach r in 3 4 5 {
    quietly count if allendorf_sample==1 & round==`r' ///
        & (nuclear==1 | natal==1 | patrilocal==1)

    local Nraw = r(N)
    local Nfmt : display %12.0fc `Nraw'
    local Nfmt = strtrim("`Nfmt'")

    if `r' == 3 local N3 "`Nfmt'"
    if `r' == 4 local N4 "`Nfmt'"
    if `r' == 5 local N5 "`Nfmt'"
}




*******************************************************
* Stacked bar graph
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident patrilocal if allendorf_sample==1 [aw=wt],
    over(round, label(labsize(vsmall) angle(0)))
    stack
    bar(1, color(`nuclear_gray')    lcolor(none))
    bar(2, color(`natal_ur_gray')   lcolor(none))
    bar(3, color(`patrilocal_gray') lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Patrilocal")
           cols(2) pos(6) region(lstyle(none)) size(small))
    blabel(bar, format(%4.2f) position(center) size(small))
    ylabel(0(.2)1, labsize(medsmall) angle(horizontal))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(4.5)
    name(g3, replace)
	note("Sample sizes: N=`N3' in 2005—-2006, N=`N4' in 2015-—2016," "                        N=`N5' in 2019–2021");
#delimit cr


graph export "figures/figureC3_hhstruc_composition_allendorf2013sample.pdf", as(pdf) replace 
