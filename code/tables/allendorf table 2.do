
*------------------------------------------------------------
* NFHS-5, pregnant women
* Table 2-style: All vs Extended vs Nuclear + sig
*------------------------------------------------------------
use $all_nfhs_ir, clear

keep if inlist(hh_struc,1,2)

* Continuous

* Percent (default weight: wt)
local natvars bmi underweight anemic ///
    meat_egg_fish_weekly dairy_daily ///
    prob_facility_distance prob_health_money anc_four ///
    north central east west south northeast ///
    forward obc dalit adivasi muslim sjc ///
    no_educ primary secondary higher ///
    poorest poorer middle richer richest ///
    fridge tv motorcycle ///
    parity1 parity2 parity3 parity4

* State-weighted
local statevars nosay_healthcare prob_health_permission nosay_visits nosay_purchases

* DV-weighted
local dvvars dv_phys dv_sex

tabstat `pctvars' if pregnant==1 [aw=wt],  by(hh_struc) statistics(mean) columns(stat) format(%9.4f) long


tabstat `statevars', by(hh_struc) stat(mean) columns(stat) format(%9.4f) long [aw=w_state]



tabstat `dvvars', by(hh_struc) stat(mean) columns(stat) format(%9.4f) long [aw=w_dv]



local allvars `natvars' `statevars' `dvvars'

foreach var in `allvars' {
	
	
	if strpos(" `nat_outcomes' ", " `outcome' ")   local wvar wt
	if strpos(" `dv_outcomes' ",  " `outcome' ")   local wvar w_dv
	if strpos(" `state_outcomes' ", " `outcome' ") local wvar w_state

	
	
	sum `var' [aw=`wvar'] 
	local all = r(mean)
	
	
	sum `var' [aw=`wvar'] if hh_struc==1
	local nucelar = r(mean)
	
	sum `var' [aw=`wvar'] if hh_struc==2
	local patrilocal = r(mean)
	
	
	
	* some stuff to do the significane test
	post handle (`all')(`nuclear')(`patrilocal')
	
}



// * region
// focus 
// central
// east
// west
// north
// south
// northeast
//
// * social group
// forward
// obc
// dalit 
// adivasi
// muslim
// sjc
//
// * health
// bmi
// underweight
// anemic
//
// * diet
// meat_egg_fish_weekly
// dairy_daily
//
//
// * healthcare access
// prob_facility_distance
// prob_health_money
// anc_four
//
//
// * decision making power (must use weights as w_state)
// nosay_healthcare
// prob_health_permission
// nosay_visits
// nosay_purchases
//
// * domestic violence (must use weights as w_dv)
// dv_phys
// dv_sex
//
// * wealth
// poorest
// poorer
// middle 
// richer
// richest
//
// * assets
// fridge 
// tv 
// motorcycle
//
//
// *educ 
// no_educ
// primary
// secondary
// higher 
//
//
// * parity
// parity1
// parity2
// parity3
// parity4
//
//
//
