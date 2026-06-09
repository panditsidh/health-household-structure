/*

This file creates Appendix Figure C-1.

The figure shows changes across NFHS-3, NFHS-4, and NFHS-5 in the distribution
of women's household structure. Household structure is split into four
categories: nuclear, natal usual resident, natal visitor, and patrilocal
extended household.

The file creates three stacked bar graph panels: pregnant women, non-pregnant
women, and all women. It then combines the three panels into one figure and
exports the figure as a PDF.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/


do "$paths"
use "$all_nfhs_ir", clear


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
* Panel 1: Pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal if pregnant==1 [aw=wt],
    over(round, label(labsize(vsmall) angle(0)))
    stack
    bar(1, color(`nuclear_gray')    lcolor(none))
    bar(2, color(`natal_ur_gray')   lcolor(none))
    bar(3, color(`natal_vis_gray')  lcolor(none))
    bar(4, color(`patrilocal_gray') lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(small))
    blabel(bar, format(%4.2f) position(center) size(vsmall))
    ytitle("Proportion of women", size(medsmall))
    ylabel(0(.2)1, labsize(medsmall) angle(horizontal))
    title("(a) Pregnant women", size(medium))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(4.5)
    name(g1, replace);
#delimit cr


*******************************************************
* Panel 2: Non-pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal if pregnant!=1 [aw=wt],
    over(round, label(labsize(vsmall) angle(0)))
    stack
    bar(1, color(`nuclear_gray')    lcolor(none))
    bar(2, color(`natal_ur_gray')   lcolor(none))
    bar(3, color(`natal_vis_gray')  lcolor(none))
    bar(4, color(`patrilocal_gray') lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(small))
    blabel(bar, format(%4.2f) position(center) size(vsmall))
    ylabel(0(.2)1, labsize(medsmall) angle(horizontal))
    title("(b) Non-pregnant women", size(medium))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(4.5)
    name(g3, replace);
#delimit cr


*******************************************************
* Panel 3: All women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal [aw=wt],
    over(round, label(labsize(vsmall) angle(0)))
    stack
    bar(1, color(`nuclear_gray')    lcolor(none))
    bar(2, color(`natal_ur_gray')   lcolor(none))
    bar(3, color(`natal_vis_gray')  lcolor(none))
    bar(4, color(`patrilocal_gray') lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(small))
    blabel(bar, format(%4.2f) position(center) size(vsmall))
    ylabel(0(.2)1, labsize(medsmall) angle(horizontal))
    title("(c) All women", size(medium))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(4.5)
    name(g4, replace);
#delimit cr


*******************************************************
* Combine into side-by-side 3-panel figure, vertically stretched
*******************************************************
grc1leg g1 g3 g4, ///
    cols(3) ///
    imargin(2 2 2 2) ///
    iscale(0.85) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    legendfrom(g1) ///
    name(hh_structure_threepanel, replace) ///
    fysize(110) fxsize(160)

graph export "figures/figureC1_hhstruc_composition_allwomen.pdf", replace as(pdf) name("hh_structure_threepanel")
