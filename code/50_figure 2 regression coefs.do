

clear
set more off

use $all_nfhs_ir, clear

keep if inlist(round,3,4,5)

keep if inlist(hh_struc,1,2)

keep if ever_married==1


* this just helps it run faster
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
foreach y in nosay_healthcare nosay_visits {
    foreach r in 3 4 5 {
		
		use `round`r'', clear
        * no controls
        reghdfe `y' i.patrilocal [aw=w_state] if round==`r' & pregnant==1, cluster(psu) absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=w_state] if round==`r' & pregnant==1, cluster(psu)  absorb(v024)
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
            if round==`r' & postpartum==1, cluster(psu)  absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=wt] if round==`r' & postpartum==1, cluster(psu)  absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])
    }
}

postclose h
use `results', clear



*============================================================*
* Figure: coefficients across NFHS rounds (4 panels)
*  - no grid
*  - mlabels
*  - smaller stagger
*  - x-axis shows 2005-06 / 2015-16 / 2019-21 (not 1 2 3)
*  - NO connecting lines
*  - legend: circle = no controls, triangle = wealth controls
*============================================================*

* If b is missing but ll/ul exist, uncomment midpoint fallback:
* gen double b = (ll + ul)/2 if missing(b) & !missing(ll) & !missing(ul)

* --- x-axis positions ---
gen byte x = .
replace x = 1 if round==3
replace x = 2 if round==4
replace x = 3 if round==5

* --- smaller stagger ---
gen double xoff = x
replace xoff = x - 0.04 if spec=="no controls"
replace xoff = x + 0.04 if spec=="wealth controls"

* --- nicer outcome titles for by-panels ---
gen str40 outcome_title = outcome
replace outcome_title = "No say in own healthcare"              if outcome=="nosay_healthcare"
replace outcome_title = "No say in visits to family/friends"    if outcome=="nosay_visits"
replace outcome_title = "Gave birth in a health facility"       if outcome=="facility_birth"
replace outcome_title = "Had 4+ antenatal visits"               if outcome=="anc_four"

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
        yrescale ///
        xrescale ///
        imargin(small)) ///
    legend(order(2 "No controls" 4 "Wealth controls") ///
           rows(1) ring(0) pos(6) bplacement(south) ///
           region(lstyle(none))) ///
    xlabel(0.7 `"2005-2006"' 2 `"2015-2016"' 3.3 `"2019-2021"', ///
           noticks nogrid labsize(small)) ///
	ylabel(,labsize(small)) ///
    xscale(range(0.5 3.5)) ///
    xtitle("") ///
    ytitle("Coefficient on indicator for patrilocal extended households", margin(medsmall)) ///
    yline(0, lpattern(solid) lcolor(gs10)) ///
    graphregion(color(white) margin(b+10 l+6 r+6 t+4)) ///
    plotregion(color(white) margin(l+4 r+4 t+4 b+4)) 

	
	
graph export "figures/figure 1 regression coefficients with state fes.png", as(png) name("Graph") replace
