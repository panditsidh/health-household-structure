
use $all_nfhs_ir, clear

************************************************************
* COLLAPSE: women with birth 3–12 months before survey
* - healthcare + wealth vars: wt
* - adds N row (unweighted count) by columns
* Output: columns varname mean  (ready to reshape wide)
************************************************************

* sample restriction
keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)


gen columns = 1 if round==3 & hh_struc==1

replace columns = 2 if round==3 & hh_struc==2

replace columns = 3 if round==4 & hh_struc==1

replace columns = 4 if round==4 & hh_struc==2

replace columns = 5 if round==5 & hh_struc==1

replace columns = 6 if round==5 & hh_struc==2
drop if missing(columns)

gen months_ago_last_birth = v008 - b3_01
keep if inrange(months_ago_last_birth, 3, 12)

* outcomes
gen facility_birth = (home_birth==0) if !missing(home_birth)
* anc_four assumed already exists / harmonized

* wealth vars (you already wrote these; included here for completeness if not yet run)
gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)
gen latrine        = !inlist(v116, 30, 31) if !missing(v116)
gen electricity    = v119==1 if !missing(v119)
gen owns_radio     = v120==1 if !missing(v120)
gen owns_tv        = v121==1 if !missing(v121)
gen owns_fridge    = v122==1 if !missing(v122)
gen owns_bike      = v123==1 if !missing(v123)
gen owns_car       = v125==1 if !missing(v125)
gen owns_land      = inlist(v745b,1,2,3) if !missing(v745b)

*-------------------------------
* 0) N by columns (unweighted)
*-------------------------------
preserve
contract columns
rename _freq N
gen varname = "n"
rename N mean
keep columns varname mean
tempfile collapsed_N_pp
save `collapsed_N_pp', replace
restore

*-------------------------------
* 1) Healthcare + wealth measures (wt)
*-------------------------------
preserve
collapse (mean) ///
    facility_birth anc_four ///
    finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
    latrine owns_land ///
    [aw=wt], by(columns)

rename (facility_birth anc_four ///
        finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
        latrine owns_land) ///
       (m_facility_birth m_anc_four ///
        m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car ///
        m_latrine m_owns_land)

reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_main_pp
save `collapsed_main_pp', replace
restore

*-------------------------------
* 2) Stack + (optional) wide
*-------------------------------
use `collapsed_main_pp', clear
append using `collapsed_N_pp'

* Now: columns varname mean
* If you want wide with 6 columns:
reshape wide mean, i(varname) j(columns)

gen sample = "3-12 months ago last birth"
