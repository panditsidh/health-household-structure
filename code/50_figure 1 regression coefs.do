

clear
set more off

use $all_nfhs_ir, clear

keep if inlist(round,3,4,5)

*******************************************************
* 1) Define samples + variables
*******************************************************

* Postpartum restriction
gen months_ago_last_birth = v008 - b3_01
gen postpartum = inrange(months_ago_last_birth, 3, 12)

* Outcomes
gen facility_birth = (home_birth==0) if !missing(home_birth)

* Wealth controls
gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)
gen latrine        = !inlist(v116,30,31) if !missing(v116)
gen electricity    = v119==1 if !missing(v119)
gen owns_radio     = v120==1 if !missing(v120)
gen owns_tv        = v121==1 if !missing(v121)
gen owns_fridge    = v122==1 if !missing(v122)
gen owns_bike      = v123==1 if !missing(v123)
gen owns_car       = v125==1 if !missing(v125)
gen owns_land      = inlist(v745b,1,2,3) if !missing(v745b)
gen floor = v127 if v127 < 96
replace floor = 10 if inrange(floor, 10, 19)
replace floor = 20 if inrange(floor, 20, 29)
replace floor = 30 if inrange(floor, 30, 39)
label define floor 10 "unfinished" 20 "part finished" 30 "finished" 
label val floor floor

gen wall = v128 if v128 < 96
replace wall = 10 if inrange(wall, 10, 19)
replace wall = 20 if inrange(wall, 20, 29)
replace wall = 30 if inrange(wall, 30, 39)
label define wall 10 "unfinished" 20 "part finished" 30 "finished" 
label val wall wall

gen roof = v129 if v129 < 96
replace roof = 10 if inrange(roof, 10, 19)
replace roof = 20 if inrange(roof, 20, 29)
replace roof = 30 if inrange(roof, 30, 39)
label define roof 10 "unfinished" 20 "part finished" 30 "finished" 
label val roof roof

gen finished_wall = wall==30 if !missing(wall)
gen finished_roof = roof==30 if !missing(roof)

gen water = v113 if v113<51
replace water = 10 if inrange(water, 10,19)
replace water = 20 if inrange(water, 20,29)
replace water = 30 if inrange(water, 30,39)
replace water = 40 if inrange(water, 40,49)
label val water V113

gen piped_water = water


egen wealth_group = group(finished_floor finished_wall finished_roof ///
                         electricity owns_radio owns_tv owns_fridge ///
                         owns_bike owns_car latrine)


local wealth_controls ///
    finished_floor finished_wall finished_roof electricity owns_radio owns_tv owns_fridge owns_bike owns_car latrine 

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

        * no controls
        reghdfe `y' i.patrilocal [aw=wt] if round==`r' & pregnant==1, cluster(psu) absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=wt] if round==`r' & pregnant==1, cluster(psu) absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("wealth controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])
    }
}

* -------- Postpartum outcomes --------
foreach y in facility_birth anc_four {
    foreach r in 3 4 5 {

        * no controls
        reghdfe `y' i.patrilocal [aw=wt] ///
            if round==`r' & postpartum==1, cluster(psu) absorb(v024)
        matrix M = r(table)
        post h ("`y'") (`r') ("no controls") ///
            (M["b","1.patrilocal"]) (M["ll","1.patrilocal"]) (M["ul","1.patrilocal"])

        * wealth controls
        reghdfe `y' i.patrilocal i.wealth_group ///
            [aw=wt] if round==`r' & postpartum==1, cluster(psu) absorb(v024)
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
    xlabel(0.7 `"2005-06"' 2 `"2015-16"' 3.3 `"2019-21"', ///
           noticks nogrid labsize(small)) ///
	ylabel(,labsize(small)) ///
    xscale(range(0.5 3.5)) ///
    xtitle("") ///
    ytitle("Difference in outcome (Patrilocal – Nuclear, pp)", margin(medsmall)) ///
    yline(0, lpattern(solid) lcolor(gs10)) ///
    graphregion(color(white) margin(b+10 l+6 r+6 t+4)) ///
    plotregion(color(white) margin(l+4 r+4 t+4 b+4)) 

	
	
graph export "figures/figure 1 regression coefficients.png", as(png) name("Graph") replace
