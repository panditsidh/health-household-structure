

use $all_nfhs_ir, clear

cap label drop roundlbl
label define roundlbl ///
    3 "2005-2006" ///
    4 "2015-2016" ///
    5 "2019-2021"
label values round roundlbl
label values group grouplbl

keep if ever_married==1
keep if nuclear | natal | patrilocal
keep if inlist(round, 3, 4, 5)

replace allendorf_sample = . if natal==1

*******************************************************
* Common style
*******************************************************
local blue  "navy%55"
local gray  "gs10%65"
local red   "maroon%55"

*******************************************************
* Panel 1: Pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal if pregnant==1 [aw=wt],
    over(round, label(labsize(small)))
    stack
    bar(1, color(`blue') lcolor(none))
    bar(2, color(`gray') lcolor(none))
    bar(3, color(`red')  lcolor(none))
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal")
           cols(3) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(medsmall))
    ytitle("Proportion of women", size(medlarge))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("A. Pregnant women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g1, replace);
#delimit cr

*******************************************************
* Panel 2: Allendorf sample
*******************************************************
#delimit ;
graph bar (mean) nuclear patrilocal if allendorf_sample==1 [aw=wt],
    over(round, label(labsize(small)))
    stack
    bar(1, color(`blue') lcolor(none))
    bar(2, color(`red')  lcolor(none))
    legend(order(1 "Nuclear" 2 "Patrilocal")
           cols(2) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(medsmall))
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
graph bar (mean) nuclear natal patrilocal if pregnant==0 [aw=wt],
    over(round, label(labsize(small)))
    stack
    bar(1, color(`blue') lcolor(none))
    bar(2, color(`gray') lcolor(none))
    bar(3, color(`red')  lcolor(none))
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal")
           cols(3) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(medsmall))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("B. Non-pregnant women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g3, replace);
#delimit cr

*******************************************************
* Panel 4: All women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal [aw=wt],
    over(round, label(labsize(small)))
    stack
    bar(1, color(`blue') lcolor(none))
    bar(2, color(`gray') lcolor(none))
    bar(3, color(`red')  lcolor(none))
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal")
           cols(3) pos(6) region(lstyle(none)) size(medlarge))
    blabel(bar, format(%4.2f) position(inside) size(medsmall))
    ylabel(0(.2)1, labsize(medlarge) angle(horizontal))
    title("C. All women", size(large))
    graphregion(color(white))
    plotregion(color(white))
    name(g4, replace);
#delimit cr

*******************************************************
* Combine into 2x2 panel
*******************************************************
// grc1leg g1 g2 g3 g4, ///
//     cols(2) ///
//     imargin(2 2 2 2) ///
//     iscale(0.6) ///
//     graphregion(color(white)) ///
//     legendfrom(g1)

// grc1leg g1 g3 g4, ///
//     cols(1) ///
//     imargin(1 1 1 1) ///
//     iscale(0.8) ///
//     graphregion(color(white) margin(0 0 0 0)) ///
//     legendfrom(g1) ///
//     name(hh_structure_threepanel, replace) fysize(180) fxsize(75)
//	
	
grc1leg g1 g3 g4, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    iscale(0.8) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    legendfrom(g1) ///
    name(hh_structure_threepanel, replace) fysize(75) fxsize(150)

graph export "figures/apdx bar graph four panel.png", as(png) replace


	
	
/*


#delimit ;
graph bar (mean) nuclear natal patrilocal other_extended if pregnant==0  [aw=wt],
        over(round) 
        stack
        legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal" 4 "Downwardly extended"))
        blabel(bar, format(%4.2f) position(inside) size(small))
        ytitle("Proportion")
        
        title("Distribution of household structure among nonpregnant women");
#delimit cr


xlabel(3 "2005-06" 4 "2015-16" 5 "2019-21")

#delimit ;
graph bar (mean) nuclear natal patrilocal other_extended if pregnant==0  [aw=wt],
        over(round) 
        stack
        legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal" 4 "Downwardly extended"))
        blabel(bar, format(%4.2f) position(inside) size(small))
        ytitle("Proportion")
        xlabel(1 "test" 2 "1998-99" 3 "2005-06" 4 "2015-16" 5 "2019-21")
        title("Distribution of household structure among nonpregnant women");
#delimit cr



graph export "figures/hhstruc non pregnant.png", as(png) replace
<<<<<<< Updated upstream
<<<<<<< Updated upstream:code/hhstruc bargraph.do
preserve 	
keep if nuclear | natal | patrilocal
keep if pregnant==1

#delimit ;
graph bar (mean) nuclear natal patrilocal if pregnant==1  [aw=wt],
	over(round) 
	stack
	legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal"))
	blabel(bar, format(%4.2f) position(inside) size(small))
	ytitle("Proportion")
	title("Distribution of household structure among pregnant women")
	note("Sample restricted to nuclear, natal, patrilocal - dropped 5% downwardly extended in NFHS-2, otherwise negligible");
#delimit cr
restore
	
graph export "figures/hhstruc pregnant.png", as(png) replace


	
=======
>>>>>>> Stashed changes:code/20_figure 1 change in hhstructure.do
=======
>>>>>>> Stashed changes


*/
