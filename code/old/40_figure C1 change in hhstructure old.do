use $all_nfhs_ir, clear


cap label drop roundlbl
label define roundlbl ///
    3 "2005--2006" ///
    4 "2015--2016" ///
    5 "2019--2021"
label values round roundlbl
label values group grouplbl

keep if ever_married==1
keep if nuclear | natal | patrilocal
keep if inlist(round, 3, 4, 5)

replace allendorf_sample = . if natal==1

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
* Common style
*******************************************************
local blue      "navy%55"
local gray      "gs10%65"
local lightgray "gs13%65"
local red       "maroon%55"

*******************************************************
* Panel 1: Pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal if pregnant==1 [aw=wt],
    over(round, label(labsize(vsmall)))
    stack
    bar(1, color(`blue')      lcolor(none))
    bar(2, color(`gray')      lcolor(none))
    bar(3, color(`lightgray') lcolor(none))
    bar(4, color(`red')       lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women", size(medlarge))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("(a) Pregnant women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g1, replace);
#delimit cr

*******************************************************
* Panel 2: Allendorf sample
*******************************************************
#delimit ;
graph bar (mean) nuclear patrilocal if allendorf_sample==1 [aw=wt],
    over(round, label(labsize(vsmall)))
    stack
    bar(1, color(`blue') lcolor(none))
    bar(2, color(`red')  lcolor(none))
    legend(order(1 "Nuclear" 2 "Patrilocal")
           cols(2) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women", size(medlarge))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("Sample used in Allendorf 2013", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g2, replace);
#delimit cr

*******************************************************
* Panel 3: Non-pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal if preg!=1 [aw=wt],
    over(round, label(labsize(vsmall)))
    stack
    bar(1, color(`blue')      lcolor(none))
    bar(2, color(`gray')      lcolor(none))
    bar(3, color(`lightgray') lcolor(none))
    bar(4, color(`red')       lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("(b) Non-pregnant women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g3, replace);
#delimit cr

*******************************************************
* Panel 4: All women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal [aw=wt],
    over(round, label(labsize(vsmall)))
    stack
    bar(1, color(`blue')      lcolor(none))
    bar(2, color(`gray')      lcolor(none))
    bar(3, color(`lightgray') lcolor(none))
    bar(4, color(`red')       lcolor(none))
    legend(order(1 "Nuclear" 
                 2 "Natal: usual resident" 
                 3 "Natal: visitor" 
                 4 "Patrilocal")
           cols(4) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("(c) All women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g4, replace);
#delimit cr

*******************************************************
* Combine into 3-panel figure
*******************************************************
grc1leg g1 g3 g4, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    iscale(0.8) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    legendfrom(g1) ///
    name(hh_structure_threepanel, replace) fysize(75) fxsize(150)

graph export "figures/apdx bar graph three panel.png", as(png) replace
