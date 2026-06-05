/*

This file creates Figure 1.

Figure 1 shows the estimated difference in outcomes between women in patrilocal
extended households and women in nuclear households.

The file runs regressions separately by NFHS round for four outcomes:
birth in a health facility, 4+ prenatal visits, no say in own healthcare, and
no say in visits to family or friends.

For each outcome and round, the file estimates two regressions:
one with state fixed effects only, and one with state fixed effects plus wealth
controls. The plotted coefficient is the coefficient on patrilocal extended
household residence. Standard errors are clustered at the PSU level.

The autonomy outcomes use the pregnant sample and state-module weights. The
healthcare-use outcomes use the recent birth sample and regular women's weights.

This file uses the final analytic dataset created by 10_assemble_data.do.
You need to have defined all required paths in 00_paths.do for this file to work.

*/


clear
set more off


do "$paths"
use "$all_nfhs_ir", clear

keep if inlist(round,3,4,5)

keep if inlist(hh_struc,1,2)

keep if ever_married==1


* this just helps it run faster, load tempfiles of each round instead of the entire file 
foreach r in 3 4 5 {
	
	preserve
	
	keep if round==`r'
	tempfile round`r'
	save `round`r''
	restore
}	



tempfile results
capture postclose h
postfile h ///
    str25 outcome ///
    byte round ///
    str20 spec ///
    double b ll ul ///
    using `results', replace

* -------- Pregnant outcomes --------
* we use w_state here because these are state module outcomes that require different weights be used
foreach y in nosay_healthcare nosay_visits {
    foreach r in 3 4 5 {
		
		use `round`r'', clear
        * no controls
        reghdfe `y' i.patrilocal [aw=w_state] if round==`r' & sample==2, cluster(psu) absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=w_state] if round==`r' & sample==2, cluster(psu)  absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])
    }
}

* -------- Postpartum outcomes --------
foreach y in facility_birth anc_four {
    foreach r in 3 4 5 {
		
		use `round`r'', clear
        * no controls
        reghdfe `y' i.patrilocal [aw=wt] ///
            if round==`r' & sample==1, cluster(psu)  absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=wt] if round==`r' & sample==1, cluster(psu)  absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])
    }
}

postclose h
use `results', clear



*============================================================*
* Figure: coefficients across NFHS rounds (4 panels)
*============================================================*

* --- x-axis positions ---
gen byte x = .
replace x = 1 if round==3
replace x = 2 if round==4
replace x = 3 if round==5


* stagger the points on the x axis so they don't overlap 
gen double xoff = x
replace xoff = x - 0.025 if spec=="no controls"
replace xoff = x + 0.025 if spec=="wealth controls"

* --- nicer outcome titles for by-panels ---
gen str40 outcome_title = outcome
replace outcome_title = "(c) No say in own healthcare"              if outcome=="nosay_healthcare"
replace outcome_title = "(d) No say in visits to family/friends"    if outcome=="nosay_visits"
replace outcome_title = "(a) Gave birth in a health facility"       if outcome=="facility_birth"
replace outcome_title = "(b) Had 4+ prenatal visits"               if outcome=="anc_four"

* --- marker labels: coef with stars if you have them; else just b formatted ---
* If you already have stars in a variable, swap mlabel() to that.
gen str12 mlabel = string(b, "%4.3f")



twoway ///
    (rcap ul ll xoff if spec=="no controls", lcolor(black) legend(off)) ///
    (scatter b xoff if spec=="no controls", ///
        msymbol(Oh) mcolor(black) mfc(none) ///
        mlabel(mlabel) mlabpos(9) mlabsize(vsmall) mlabcolor(black)) ///
    (rcap ul ll xoff if spec=="wealth controls", lcolor(gs8) legend(off)) ///
    (scatter b xoff if spec=="wealth controls", ///
        msymbol(Th) mcolor(gs8) mfc(none) ///
        mlabel(mlabel) mlabpos(3) mlabsize(vsmall) mlabcolor(black)) ///
    , ///
    by(outcome_title, ///
        cols(2) ///
        note("") ///
        graphregion(color(white)) ///
        legend(pos(6)) ///
		subtitle(, size(vsmall) nobexpand) ///
        yrescale ///
        xrescale ///
        imargin(small) iscale(0.6)) ///
    legend(order(2 "No controls" 4 "Wealth controls") ///
           rows(1) ring(1) pos(6) ///
           region(lstyle(none)) size(small)) ///
    xlabel(1 `"2005--2006"' 2 `"2015--2016"' 3 `"2019--2021"', ///
           noticks nogrid labsize(small)) ///
    ylabel(, labsize(small) angle(0)) ///
    xscale(range(0.85 3.15)) ///
    xtitle("") ///
    ytitle("Coefficient on patrilocal extended household", size(small) margin(small)) ///
    yline(0, lpattern(solid) lcolor(gs10)) ///
    graphregion(color(white) margin(l+3 r+3 t+3 b+3)) ///
    plotregion(color(white) margin(l+1 r+1 t+2 b+2)) ///
    xsize(7) ysize(5.8)
	
graph export "figures/figure1_patrilocaldiffs_wealthcontrols.pdf", as(pdf) name("Graph") replace
