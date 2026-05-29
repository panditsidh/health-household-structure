
use $all_nfhs_ir, clear

cap drop allendorf_sample

gen allendorf_sample = (v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1) 

/*
married
between ages 15-29
usual resident
currently residing with husband
*/



cap label drop roundlbl
label define roundlbl ///
    3 "2005—2006" ///
    4 "2015—2016" ///
    5 "2019—2021"
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
* Common style: grayscale
*******************************************************
local nuclear_gray      "gs11%75"
local natal_ur_gray     "gs14%85"
local natal_vis_gray    "gs8%55"
local patrilocal_gray   "gs6%70"



*******************************************************
* Panel 2: Allendorf sample
*******************************************************
#delimit ;
graph bar (mean) nuclear natal_usual_resident natal_visitor patrilocal if preg!=1 [aw=wt],
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
           cols(2) pos(6) region(lstyle(none)) size(small))
    blabel(bar, format(%4.2f) position(center) size(small))
    ylabel(0(.2)1, labsize(medsmall) angle(horizontal))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(4.5)
    name(g3, replace);
#delimit cr


graph export "figures/DR/allendorf sample bar graph.png", as(png) name("g2")
