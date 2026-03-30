*============================================================*
* Appendix table: NFHS-5 only, controlled regressions
* 4 columns = 4 outcomes
*============================================================*

clear
set more off

use $all_nfhs_ir, clear
keep if inlist(round,3,4,5)

*******************************************************
* 1) Recreate variables used in the figure code
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
label values floor floor

gen wall = v128 if v128 < 96
replace wall = 10 if inrange(wall, 10, 19)
replace wall = 20 if inrange(wall, 20, 29)
replace wall = 30 if inrange(wall, 30, 39)
label define wall 10 "unfinished" 20 "part finished" 30 "finished"
label values wall wall

gen roof = v129 if v129 < 96
replace roof = 10 if inrange(roof, 10, 19)
replace roof = 20 if inrange(roof, 20, 29)
replace roof = 30 if inrange(roof, 30, 39)
label define roof 10 "unfinished" 20 "part finished" 30 "finished"
label values roof roof

gen finished_wall = wall==30 if !missing(wall)
gen finished_roof = roof==30 if !missing(roof)

gen water = v113 if v113<51
replace water = 10 if inrange(water, 10,19)
replace water = 20 if inrange(water, 20,29)
replace water = 30 if inrange(water, 30,39)
replace water = 40 if inrange(water, 40,49)
label values water V113

gen piped_water = water

local wealth_controls ///
    finished_floor finished_wall finished_roof electricity ///
    owns_radio owns_tv owns_fridge owns_bike owns_car latrine

*******************************************************
* 2) Run NFHS-5 regressions with controls only
*******************************************************

* install estout if needed
* ssc install estout, replace

eststo clear

* Pregnant sample outcomes
eststo m1: reghdfe nosay_healthcare i.patrilocal `wealth_controls' ///
    [aw=wt] if round==5 & pregnant==1, cluster(psu) absorb(v024)

eststo m2: reghdfe nosay_visits i.patrilocal `wealth_controls' ///
    [aw=wt] if round==5 & pregnant==1, cluster(psu) absorb(v024)

* Postpartum sample outcomes
eststo m3: reghdfe facility_birth i.patrilocal `wealth_controls' ///
    [aw=wt] if round==5 & postpartum==1, absorb(v024) cluster(psu)

eststo m4: reghdfe anc_four i.patrilocal `wealth_controls' ///
    [aw=wt] if round==5 & postpartum==1, absorb(v024) cluster(psu)

*******************************************************
* 3) Add useful summary rows
*******************************************************

estadd local state_fe "No" : m1
estadd local state_fe "No" : m2
estadd local state_fe "Yes" : m3
estadd local state_fe "Yes" : m4

estadd local sample "Pregnant"   : m1
estadd local sample "Pregnant"   : m2
estadd local sample "Postpartum" : m3
estadd local sample "Postpartum" : m4

*******************************************************
* 4) Export appendix table
*******************************************************

esttab m1 m2 m3 m4 using "tables/appendix_nfhs5_controlled_regs.tex", replace ///
    label se star(* 0.10 ** 0.05 *** 0.01) ///
    b(%9.3f) se(%9.3f) nonumbers ///
    mtitles("No say in healthcare" "No say in visits" "Facility birth" "4+ ANC visits") ///
    title("Appendix Table: NFHS-5 Controlled Regressions") ///
    stats(N r2 sample state_fe, ///
          labels("Observations" "R-squared" "Sample" "State fixed effects")) ///
    varlabels(1.patrilocal "Patrilocal" ///
              finished_floor "Finished floor" ///
              finished_wall "Finished wall" ///
              finished_roof "Finished roof" ///
              electricity "Electricity" ///
              owns_radio "Owns radio" ///
              owns_tv "Owns TV" ///
              owns_fridge "Owns fridge" ///
              owns_bike "Owns bike" ///
              owns_car "Owns car" ///
              latrine "Has latrine") ///
    nonotes nonumbers booktabs

	

esttab m1 m2 m3 m4, replace ///
    label se star(* 0.10 ** 0.05 *** 0.01) ///
    b(%9.3f) se(%9.3f) ///
    mtitles("No say in healthcare" "No say in visits" "Facility birth" "4+ ANC visits") ///
    title("Appendix Table: NFHS-5 Controlled Regressions") ///
    stats(N r2 sample state_fe, ///
          labels("Observations" "R-squared" "Sample" "State fixed effects")) ///
    varlabels(1.patrilocal "Patrilocal" ///
              finished_floor "Finished floor" ///
              finished_wall "Finished wall" ///
              finished_roof "Finished roof" ///
              electricity "Electricity" ///
              owns_radio "Owns radio" ///
              owns_tv "Owns TV" ///
              owns_fridge "Owns fridge" ///
              owns_bike "Owns bike" ///
              owns_car "Owns car" ///
              latrine "Has latrine") ///
    nonotes nonumbers 

	

*******************************************************
* 5) Optional: also export to csv
*******************************************************
