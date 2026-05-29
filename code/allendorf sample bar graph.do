
use $all_nfhs_ir, clear


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

graph bar (mean) nuclear patrilocal if allendorf_sample==1 [aw=wt],
    over(round, label(angle(0) labsize(small)))
    stack
    ytitle("Percent", size(medium))
    ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(0) labsize(small))
    blabel(bar, format(%4.2f) size(vsmall) position(center))
    legend(order(2 "Patrilocal extended"
                 1 "Nuclear")
           rows(2) size(small) pos(6) region(lstyle(none)))
    bar(2, color(gs8)  fintensity(75) lcolor(none))
    bar(1, color(gs11) fintensity(65) lcolor(none))
    graphregion(color(white))
    plotregion(color(white))
    ysize(9) xsize(5)
    name(g2, replace);

#delimit cr


graph save "g2" "figures/DR/allendorf sample bar graph.gph"
