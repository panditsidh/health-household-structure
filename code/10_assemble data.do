do "code/11_gen hhstruc.do"

do "code/12_state district match.do"






*==============================================================*
* 4. Decision-Making Variables
*==============================================================*


* Own healthcare
gen nosay_healthcare = .
replace nosay_healthcare = 1 if inlist(v743a,4,5,6) & inlist(round,3,4,5)
replace nosay_healthcare = 0 if inlist(v743a,1,2,3) & inlist(round,3,4,5)

gen nosay_visits = .
replace nosay_visits = 0 if inlist(v743d,1,2,3) & inlist(round,3,4,5)
replace nosay_visits = 1 if inlist(v743d,4,5,6) & inlist(round,3,4,5)




// * OLD CODE
// * Own healthcare
// gen nosay_healthcare = 0
//
// * NFHS-2 (everyone asked; husband/others vs respondent/partner)
// replace nosay_healthcare = 1 if inlist(s511b,2,4) & round==2
//
// * NFHS-3–5 (husband alone, someone else, other vs respondent/partner)
// replace nosay_healthcare = 1 if inlist(v743a,4,5,6) & inlist(round,3,4,5)
//
// * Missing by state module (NFHS-4,5)
// replace nosay_healthcare = . if ssmod==0 & inlist(round,4,5)
//
// * NFHS-3 missing (only where v743a missing)
// replace nosay_healthcare = . if missing(v743a) & round==3
// replace nosay_healthcare = . if v743a==9
//
// * Visits to natal family
// gen nosay_visits = .
// replace nosay_visits = !inlist(v743d,1,2,3) if !missing(v743d)
// replace nosay_visits = 1 if inlist(v743d,4,5,6) if !missing(v743d) & inlist(round,3,4,5)
// replace nosay_visits = s512b!=1 if !missing(s512b) & round==2
// replace nosay_visits = . if v743a==9



*==============================================================*
* 8. Birth Place
*==============================================================*

gen home_birth = inlist(m15_1,10,11,12,13) if !missing(m15_1)

gen mo_since_birth = v008-b3_01

gen home_birth_312 = home_birth if inrange(mo_since_birth,3,12)


* Outcomes
gen facility_birth = (home_birth==0) if !missing(home_birth)



*==============================================================*
* 8. Pregnancy
*==============================================================*

//generate months since last period in order to exclude women who are 1 or 2 months pregnant from the analysis.
gen moperiod = .
replace moperiod = 1 if v215>=101 & v215 <= 128 
replace moperiod = 2 if v215>=129 & v215 <= 156 
replace moperiod = 3 if v215>=157 & v215 <= 184 
replace moperiod = 4 if v215>=185 & v215 <= 198 
replace moperiod = 1 if v215>=201 & v215 <= 204 
replace moperiod = 2 if v215>=205 & v215 <= 208 
replace moperiod = 3 if v215>=209 & v215 <= 213 
replace moperiod = 1 if v215==301 
replace moperiod = 2 if v215==302 
replace moperiod = 3 if v215==303 
replace moperiod = 4 if v215==304 
replace moperiod = 5 if v215==305 
replace moperiod = 6 if v215==306 
replace moperiod = 7 if v215==307 
replace moperiod = 8 if v215==308 
replace moperiod = 9 if v215==309 
replace moperiod = 10 if v215==310 
replace moperiod = 11 if v215==311 

gen gestdur = moperiod if v213==1
replace gestdur = v214 if missing(moperiod) & v213==1

gen preg = v213
replace preg = . if gestdur<3 & v213==1

* this variable is only defined for pregnant women 
gen gestdur_3plus = gestdur>=3 if !missing(gestdur) & v213==1

gen pregnant = v213 
replace pregnant = gestdur_3plus if v213==1

gen not_pregnant = !pregnant


*==============================================================*
* 12. Social Group Coding (group)
*==============================================================*

* Base coding (NFHS-4/5 style: s116 + v130)
gen group = .
replace group = 1 if s116 == 2                                     // Adivasi
replace group = 2 if s116 == 1                                     // Dalit
replace group = 6 if inlist(v130,3,4,6) & group==.                 // Christian, Sikh, Jain
replace group = 5 if v130 == 2 & group==.                          // Muslims (non-Adivasi/Dalit)
replace group = 3 if inlist(v130,1,4) & s116 == 3                  // OBC Hindu or Sikh
replace group = 4 if v130 == 1 & inlist(s116,4,8,.)                // Forward caste Hindus

*---------- NFHS-2-specific extension (round == 2) ----------*

* 1 = Adivasi (ST)
replace group = 1 if round==2 & v131 == 2

* 2 = Dalit (SC)
replace group = 2 if round==2 & v131 == 1

* 6 = Christian / Sikh / Jain
replace group = 6 if round==2 & inlist(v130,3,4,6) & group==.

* 5 = Muslims (non SC/ST)
replace group = 5 if round==2 & v130 == 2 & group==.

* 3 = OBC that are Hindu or Sikh
replace group = 3 if round==2 & inlist(v130,1,4) & v131 == 3

* 4 = Forward caste Hindus
replace group = 4 if round==2 & v130 == 1 & v131 == 4

*---------- NFHS-3-specific extension (round == 3) ----------*

* 1 = Adivasi (ST)
replace group = 1 if round==3 & s46 == 2

* 2 = Dalit (SC)
replace group = 2 if round==3 & s46 == 1

* 6 = Christian / Sikh / Jain
replace group = 6 if round==3 & inlist(v130,3,4,6) & group==.

* 5 = Muslims (non SC/ST)
replace group = 5 if round==3 & v130 == 2 & group==.

* 3 = OBC that are Hindu or Sikh
replace group = 3 if round==3 & inlist(v130,1,4) & s46 == 3

* 4 = Forward caste Hindus
replace group = 4 if round==3 & v130 == 1 & inlist(s46,4,8)


label define grouplbl ///
    1 "Adivasi" ///
    2 "Dalit" ///
    3 "OBC" ///
    4 "Forward Caste" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian", replace
label values group grouplbl

label values group grouplbl




*==============================================================*
* 12. Wealth variables
*==============================================================*


gen forward = group==1
gen obc = group==2
gen dalit = group==3
gen adivasi = group==4
gen muslim = group==5
gen sjc = group==6


gen poorest = v190==1
gen poorer = v190==2
gen middle = v190==3
gen richer = v190==4
gen richest = v190==5


gen fridge = v122==1 if inlist(v122,0,1)
gen tv = v121==1 if inlist(v121,0,1)
gen motorcycle = v124==1 if inlist(v124,0,1)


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

						 
*==============================================================*
* 12. Other variables
*==============================================================*

	

gen parity = bord_01
replace parity = 4 if bord_01>4

tab parity, gen(parity)


label define paritylbl ///
    1 "1 (no live births)" ///
    2 "2 (1 live birth)" ///
	3 "3 (2 live births)" ///
	4 "4+ (3+ live births)" 	
label values parity paritylbl


gen rural = v025==2


gen anc_four = m14_1>=4 if !missing(m14_1)


gen no_educ = v106==0
gen primary = v106==1
gen secondary = v106==2
gen higher = v106==3


gen less_edu = inlist(v106,0,1)
tab less_edu, m

label define lessedulbl ///
    0 "primary education or higher" ///
    1 "less than primary education" 
label values less_edu lessedulbl


gen hasboy = v202 >0 & v202!=.
replace hasboy = 1 if v204 >0 & v204!=.
gen noboy = hasboy
recode noboy (1=0) (0=1)
tab hasboy noboy, m

label define noboylbl ///
    1 "does not have boy child" ///
    0 "has at least one boy child" 
label values noboy noboylbl

*age
gen agebin = .
replace agebin = 1 if inrange(v012, 15, 19)     // Teens
replace agebin = 2 if inrange(v012, 20, 24)     // Highest fertility
replace agebin = 3 if inrange(v012, 25, 29)     // Lower fertility
replace agebin = 4 if inrange(v012, 30, 49)     // Lowest fertility


label define agebinlbl 1 "15–19" 2 "20–24" 3 "25–29" 4 "30–49"
label values agebin agebinlbl

gen age1519 = agebin==1
gen age2024 = agebin==2
gen age2529 = agebin==3
gen age3049 = agebin==4



//birth spacing is time between last delivery and interview for non-pregnant women and time between last delivery and estimated conception of current pregnancy for pregnant women
//it is only defined for women that have had at least one live birth
//v008 is the date of the interview and b3 is the date of birth of the child
gen birth_space = (v008 - b3_01) + 9 if preg==0 & !missing(b3_01)
replace birth_space = (v008 - b3_01) + (9-gestdur) if preg==1 & !missing(b3_01)

gen bs = .
replace bs = 1 if birth_space < 24
replace bs = 2 if inrange(birth_space, 24, 36)
replace bs = 3 if birth_space > 36

gen bs_below2 = bs==1
gen bs_2to3 = bs==2
gen bs_above3 = bs==3
gen bs_noprior = parity<2

label define bslbl /// 
	1 "under 2 years" ///
	2 "2-3 years" ///
	3 "over 3 years" 

label values bs bslbl

//now generate a variable that combines parity and birth spacing
gen parity_bs = .
replace parity_bs = 1 if parity==1

local i = 2
foreach p of numlist 2/4 {
	
	foreach b of numlist 1/3 {
		
		replace parity_bs = `i' if parity==`p' & bs==`b'		
		local i = `i' + 1
	}
}



forvalues i = 1/10 {
    gen parity_bs`i' = parity_bs == `i'
}

label define parity_bs_lbl ///
    1 "No births/1 birth, NA spacing" ///
    2 "1 birth, below 2y spacing" ///
    3 "1 birth, 2–3y spacing" ///
    4 "1 birth, 3+y spacing" ///
    5 "2 births, below 2y spacing" ///
    6 "2 births, 2–3y spacing" ///
    7 "2 births, 3+y spacing" ///
    8 "3+ births, below 2y spacing" ///
    9 "3+ births, 2–3y spacing" ///
   10 "3+ births, 3+y spacing"
label values parity_bs parity_bs_lbl



*==============================================================*
* 4. Sample Restrictions
*==============================================================*


gen ever_married = v501!=0

gen months_ago_last_birth = v008 - b3_01
gen postpartum = inrange(months_ago_last_birth, 3, 12)

gen allendorf_sample = (v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1) 

/*
married
between ages 15-29
usual resident
currently residing with husband
*/


gen sample = 1 if inrange(months_ago_last_birth, 3, 12) & !missing(anc_four) & !missing(facility_birth) & ever_married==1 & !missing(wealth_group)
replace sample = 2 if pregnant==1 & !missing(nosay_visits) & !missing(nosay_healthcare) & ever_married==1 & !missing(wealth_group)

label define samplelbl ///
    1 "postpartum" ///
    2 "pregnant" 
label values sample samplelbl



*==============================================================*
* 7. Survey Weights (General, State Module, DV Module)
*==============================================================*

* General weights
egen strata = group(v000 v024 v025)
egen psu    = group(v000 v001 v024 v025)

bysort v000: egen totalwt = total(v005)
gen wt = v005 / totalwt

* State-module (decision, sexual behavior, etc.)
gen w_state_base = .
replace w_state_base = v005     if round == 2   // no state module; v005
replace w_state_base = v005s    if round == 3
replace w_state_base = sv005    if round == 4
replace w_state_base = sweight  if round == 5

bysort round: egen total_w_state = total(w_state_base)
gen w_state = w_state_base / total_w_state

* Domestic violence
gen w_dv_base = .
replace w_dv_base = v005      if round == 2
replace w_dv_base = d005      if round == 3
replace w_dv_base = sd005     if round == 4
replace w_dv_base = sdweight  if round == 5

bysort round: egen total_w_dv = total(w_dv_base)
gen w_dv = w_dv_base / total_w_dv

	


save $all_nfhs_ir, replace


