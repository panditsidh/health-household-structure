
/*

This do file creates a bar graph
each bar is an NFHS round
it is proportioned by household structure composition

we make this bar graph twice for pregnant and nonpregnant women

in both cases we look at the entire sample



*/

use $all_nfhs_ir, clear

keep if ever_married==1
keep if nuclear | natal | patrilocal
keep if inlist(round, 3, 4, 5)

*******************************************************
* Panel 1: Pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal if pregnant==1 [aw=wt],
    over(round)
    stack
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal"))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women")
    title("Pregnant women")
    name(g1, replace);
#delimit cr

*******************************************************
* Panel 2: Allendorf sample
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal if allendorf_sample==1 [aw=wt],
    over(round)
    stack
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal"))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women")
    title("Allendorf sample")
    name(g2, replace);
#delimit cr

*******************************************************
* Panel 3: Non-pregnant women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal if pregnant==0 [aw=wt],
    over(round)
    stack
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal"))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women")
    title("Non-pregnant women")
    name(g3, replace);
#delimit cr

*******************************************************
* Panel 4: All women
*******************************************************
#delimit ;
graph bar (mean) nuclear natal patrilocal [aw=wt],
    over(round)
    stack
    legend(order(1 "Nuclear" 2 "Natal" 3 "Patrilocal"))
    blabel(bar, format(%4.2f) position(inside) size(small))
    ytitle("Proportion of women")
    title("All women")
    name(g4, replace);
#delimit cr

*******************************************************
* Combine into 2x2 panel
*******************************************************
grc1leg g1 g2 g3 g4, ///
    cols(2) ///
    imargin(2 2 2 2) ///
    graphregion(color(white)) ///
	iscale(0.6)

	
graph export "figures/apdx bar graph four panel.png", as(png) name("Graph")

	



	
	
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
