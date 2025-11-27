*--------------------------------------------------------------------
* 1. Outcome groups and controls
*--------------------------------------------------------------------



* these we use all pregnant sample
local outcomes_pregnant ///
    meat_egg_fish_weekly ///
    dairy_daily  

* these we use state module sample
local outcomes_state ///
    nosay_healthcare ///
    nosay_visits

* these we need to adjust for gestdur
local outcomes_adjusted ///
    anemic ///
    bmi

* these we use dv sample
local outcomes_dv ///
    dv_phys ///
    dv_sex 

* these we need to use all women with recent births
local outcomes_recentbirth ///
    home_birth_312 ///
    c_section_312

* master list of all outcomes
// local outcomes `outcomes_pregnant' `outcomes_state' ///
//                `outcomes_adjusted' `outcomes_dv' ///
//                `outcomes_recentbirth'



use $all_nfhs_ir, clear

keep if inlist(hh_struc,1,2)
keep if inlist(round, 3,4,5)


local controls urban i.age_bin i.edu_cat 

*------------------------------------------------------------
* 1. Define outcome groups
*------------------------------------------------------------
* Pregnant-sample, nat weights
local outcomes_pregnant   meat_egg_fish_weekly dairy_daily  

* State-module sample
local outcomes_state      nosay_healthcare nosay_visits

* Need gestational duration control
local outcomes_adjusted   anemic bmi 

* Domestic violence sample
local outcomes_dv         dv_phys dv_sex

* Recent birth outcomes (3–12 months)
local outcomes_recentbirth home_birth_312 c_section_312

* All outcomes in the order you want them as columns
local outcomes ///
    meat_egg_fish_weekly ///
    dairy_daily ///
    anemic ///
    bmi ///
    nosay_healthcare ///
    nosay_visits ///
    dv_phys ///
    dv_sex ///
    home_birth_312 ///
    c_section_312

*------------------------------------------------------------
* 2. Run regressions and store with eststo
*------------------------------------------------------------
eststo clear

foreach y of local outcomes {

    *-------------------------
    * Choose weight variable
    *-------------------------
    local wvar ""
    if strpos(" `outcomes_pregnant' ",   " `y' ") local wvar wt
    if strpos(" `outcomes_state' ",      " `y' ") local wvar w_state
    if strpos(" `outcomes_dv' ",         " `y' ") local wvar w_dv
    if strpos(" `outcomes_recentbirth' ", " `y' ") local wvar wt   
	if strpos(" `outcomes_adjusted' ", " `y' ") local wvar wt   

    *-------------------------
    * Extra controls (gestdur)
    *-------------------------
    if strpos(" `outcomes_adjusted' ", " `y' ") local extra "i.gestdur"

    *-------------------------
    * Sample restriction
    *-------------------------
    * Pregnant sample for most outcomes
    local sample "if pregnant==1"

    * For recent births, use all women with last 3–12 mo birth
    if strpos(" `outcomes_recentbirth' ", " `y' ") {
        local sample "if inlist(hh_struc,1,2)"   // you already encoded sample in how you constructed home_birth_312/c_section_312
    }

    *-------------------------
    * Run regression and store
    *-------------------------
	
	display("`y'")
    reghdfe `y' i.hh_struc#i.round `extra' `controls' ///
        [aw=`wvar'] `sample', ///
        absorb(state) cluster(psu)

    * store with the outcome name as the model id
    eststo `y'
}

#delimit;
esttab meat_egg_fish_weekly ///
    dairy_daily
	anemic 
    bmi, drop(3.gestdur 4.gestdur 5.gestdur 6.gestdur 7.gestdur 8.gestdur 9.gestdur 10.gestdur 11.gestdur) nonumbers
	rename(1.hh_struc#5.round "Patrilocal 2019-21"
			1.hh_struc#4.round "Patrilocal 2015-16"
			1.hh_struc#);
	
	
    nosay_healthcare ///
    nosay_visits ///
    dv_phys ///
    dv_sex ///
    home_birth_312 ///
    c_section_312
	