use $all_nfhs_ir, clear



* keep the analytic sample
keep if inlist(round,3,4,5)
keep if inlist(hh_struc,1,2)
keep if pregnant==1 & preg==1
keep if ever_married==1



gen finished_floor = (v127>=30 & v127<=96) if !missing(v127)


gen latrine = !inlist(v116, 30, 31) if !missing(v116)

gen electricity = v119==1 if !missing(v119)
gen owns_radio  = v120==1 if !missing(v120)
gen owns_tv     = v121==1 if !missing(v121)
gen owns_fridge = v122==1 if !missing(v122)
gen owns_bike   = v123==1 if !missing(v123)
gen owns_car    = v125==1 if !missing(v125)


gen owns_land = inlist(v745b,1,2,3) if !missing(v745b)

gen facility_birth = (home_birth==0) if !missing(home_birth)





gen columns = 1 if round==3 & hh_struc==1

replace columns = 2 if round==3 & hh_struc==2

replace columns = 3 if round==4 & hh_struc==1

replace columns = 4 if round==4 & hh_struc==2

replace columns = 5 if round==5 & hh_struc==1

replace columns = 6 if round==5 & hh_struc==2



label define columnlbl ///
    1 "Nuclear NFHS-3 " ///
    2 "Patrilocal NFHS-3" ///
    3 "Nuclear NFHS-4" ///
    4 "Patrilocal NFHS-4" ///
    5 "Nuclear NFHS-5" ///
    6 "Patrilocal NFHS-5"

label values columns columnlbl



preserve
contract columns   // makes: columns _freq
rename _freq N
gen varname = "n"
rename N mean      // so it appends cleanly as same schema
keep columns varname mean
tempfile collapsed_N
save `collapsed_N', replace
restore

*-------------------------------
* 1) Wealth measures (wt)
*-------------------------------
preserve
collapse (mean) ///
    finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car ///
    latrine owns_land ///
    [aw=wt], by(columns)

rename (finished_floor electricity owns_radio owns_tv owns_fridge owns_bike owns_car latrine owns_land) ///
       (m_finished_floor m_electricity m_owns_radio m_owns_tv m_owns_fridge m_owns_bike m_owns_car m_latrine m_owns_land)

reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_wealth
save `collapsed_wealth', replace
restore

*-------------------------------
* 2) Autonomy measures (w_state)
*-------------------------------
preserve
collapse (mean) ///
    nosay_healthcare nosay_visits ///
    [aw=w_state], by(columns)

rename (nosay_healthcare nosay_visits) (m_nosay_healthcare m_nosay_visits)
reshape long m_, i(columns) j(varname) string
rename m_ mean
tempfile collapsed_auto
save `collapsed_auto', replace
restore

*-------------------------------
* 3) Stack them, with N last
*-------------------------------
use `collapsed_auto', clear
append using `collapsed_wealth'
append using `collapsed_N'

* Now: columns varname mean
* If you want wide with 6 columns:
reshape wide mean, i(varname) j(columns)



rename mean1 Nuclear3 
rename mean2 Patrilocal3 
rename mean3 Nuclear4
rename mean4 Patrilocal4
rename mean5 Nuclear5
rename mean6 Patrilocal5


gen sample = "pregnant"
