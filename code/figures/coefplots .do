use $all_nfhs_ir, clear

keep if pregnant==1

keep if inlist(hh_struc,1,2)

*--------------------------------------------------------------------
* Assumes:
*   - $all_nfhs_ir loaded
*   - keep if inlist(round,3,4,5)
*   - locals outcomes_* defined as in your code
*--------------------------------------------------------------------


gen patrilocal3 = patrilocal if round==3
gen patrilocal4 = patrilocal if round==4
gen patrilocal5 = patrilocal if round==5


local y public
local wvar w_state

* Clear old stored estimates
eststo clear

foreach r in 3 4 5 {

    *-------------------------
    * Unadjusted spec
    *-------------------------
    reghdfe `y' patrilocal`r' ///
        [aw=`wvar'] if round==`r', absorb(state) cluster(psu)
    
	eststo u`r'

    *-------------------------
    * Adjusted spec
    *-------------------------
    reghdfe `y' patrilocal`r' i.gestdur i.v149 i.v013 i.group i.parity i.prob_facility_distance i.rural i.v190 ///
        [aw=`wvar'] if round==`r', absorb(state) cluster(psu)
    
	eststo a`r'
}

#delimit ;
coefplot ///
    (u3, mcolor(blue)  ciopts(lcolor(blue))) ///
    (u4, mcolor(blue)  ciopts(lcolor(blue))) ///
    (u5, mcolor(blue)  ciopts(lcolor(blue))) ///
    (a3, mcolor(red)   ciopts(lcolor(red)))  ///
    (a4, mcolor(red)   ciopts(lcolor(red)))  ///
    (a5, mcolor(red)   ciopts(lcolor(red))), ///
    keep(patrilocal3 patrilocal4 patrilocal5)
    rename(patrilocal3 = "2005–06" patrilocal4 = "2015–16" patrilocal5 = "2019–21")
    vertical
    ///
    mlabel(@b)            /// show the numeric coefficient
    mlabpos(12)           /// put label above the marker
    mlabcolor(black)      /// <<< ALL LABELS BLACK
    mlabsize(small)       /// optional, looks clean
    ///
    yline(0, lpattern(dash))
    legend(order(1 "No controls" 7 "With controls"))
    ytitle("Patrilocal–nuclear gap")
    xtitle("NFHS Round")
    format(%5.3f);
#delimit cr


graph export "figures/COEFS public birth .png", as(png) replace

