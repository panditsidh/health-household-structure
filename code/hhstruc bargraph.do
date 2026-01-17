/*

This do file creates a bar graph
each bar is an NFHS round
it is proportioned by household structure composition

we make this bar graph twice for pregnant and nonpregnant women

in both cases we look at the entire sample



*/

cd "/Users/bipasabanerjee/Documents/GitHub/health-household-structure"
use $all_nfhs_ir, clear

* FOCUS ON EVER MARRIED SAMPLE

keep if ever_married==1

keep if (nuclear | natal | patrilocal | other_extended)

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


	


