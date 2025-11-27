*==============================================================*
* 1. Stack IR Files (NFHS-3,4,5 + NFHS-1,2)
*==============================================================*

*==============================================================*
* 2. Household Structure and Sample Definition
*==============================================================*

do "code/gen hhstruc.do"


do "code/state district match.do"

/*
married
between ages 15-29
usual resident
currently residing with husband
*/


gen ever_married = v501!=0
gen allendorf_sample = (v501==1 & v012>=15 & v012<=29 & v135==1 & v504==1)



*******************************************************
* Initialize woman-centric parent-in-law variables
*******************************************************
gen mil_present = .   // woman's mother-in-law present
gen fil_present = .   // woman's father-in-law present
gen pil_present = .   // any parent-in-law present

label var mil_present "Woman's mother-in-law present"
label var fil_present "Woman's father-in-law present"
label var pil_present "Any parent-in-law present"

*******************************************************
* CASE 1: Woman is WIFE OF HEAD (v150 == 2)
* Her husband is the head → head's parents = her in-laws
*******************************************************
replace mil_present = has_mother if v150 == 2
replace fil_present = has_father if v150 == 2
replace pil_present = has_parent if v150 == 2

*******************************************************
* CASE 2: Woman is DAUGHTER-IN-LAW OF HEAD (v150 == 4)
* Her husband is a son of the head → head + head's spouse = her in-laws
*******************************************************
* PIL always present because the head is present
replace pil_present = 1 if v150 == 4

* Use sex of the head to determine which parent-in-law is present
replace mil_present = 1 if v150 == 4 & v151 == 2      // head is female = MIL
replace fil_present = 1 if v150 == 4 & v151 == 1      // head is male   = FIL

*******************************************************
* CASE 3: Woman is HEAD (v150 == 1)
* Cannot determine her in-laws from head-centric variables
*******************************************************
replace mil_present = . if v150 == 1
replace fil_present = . if v150 == 1
replace pil_present = . if v150 == 1


*******************************************************
* Done
*******************************************************





*==============================================================*
* 3. Attitudes Toward Wife Beating
*==============================================================*

egen beating_justified = anymatch(s514a-s514f), values(1)
replace beating_justified = . if missing(s514a)

egen beating_justified_nfhs345 = anymatch(v744a-v744e), values(1)
replace beating_justified       = beating_justified_nfhs345 if inlist(round,3,4,5)
replace beating_justified       = . if v044!=1 & inlist(round,3,4,5)


*==============================================================*
* 4. Decision-Making Variables
*==============================================================*

* Own healthcare
gen nosay_healthcare = 0

* NFHS-2 (everyone asked; husband/others vs respondent/partner)
replace nosay_healthcare = 1 if inlist(s511b,2,4) & round==2

* NFHS-3–5 (husband alone, someone else, other vs respondent/partner)
replace nosay_healthcare = 1 if inlist(v743a,4,5,6) & inlist(round,3,4,5)

* Missing by state module (NFHS-4,5)
replace nosay_healthcare = . if ssmod==0 & inlist(round,4,5)

* NFHS-3 missing (only where v743a missing)
replace nosay_healthcare = . if missing(v743a) & round==3

* Own earnings
gen nosay_ownearnings = .
replace nosay_ownearnings = !inlist(v739,1,2,3) if !missing(v739)

* Visits to natal family
gen nosay_visits = .
replace nosay_visits = !inlist(v743d,1,2,3) if !missing(v743d)
replace nosay_visits = s512b!=1 if !missing(s512b) & round==2


gen nosay_purchases = .
replace nosay_purchases = !inlist(s511c,1,3,5) if round==2 & !missing(s511c)
replace nosay_purchases = !inlist(v743b,1,2,3) if !missing(v743b) & inlist(round,3,4,5)
*==============================================================*
* 6. Diet Variables (Meat/Egg/Fish/Dairy)
*==============================================================*

* Meat weekly
gen meat_weekly = .
replace meat_weekly = !inlist(s124g,3,4) if !missing(s124g) & round==2
replace meat_weekly = inlist(s558g,1,2) if round==3 & !missing(s558g)
replace meat_weekly = inlist(s726g,1,2) if round==4 & !missing(s726g)
replace meat_weekly = inlist(s731g,1,2) if round==5 & !missing(s731g)

* Meat daily
gen meat_daily = .
replace meat_daily = (s124g==1) if !missing(s124g) & round==2
replace meat_daily = (s558g==1) if round==3 & !missing(s558g)
replace meat_daily = (s726g==1) if round==4 & !missing(s726g)
replace meat_daily = (s731g==1) if round==5 & !missing(s731g)

* Eggs
gen eggs = s731e if round==5
replace eggs = s726e if round==4
replace eggs = s558e if round==3
replace eggs = s124f if round==2
gen eggs_weekly = (eggs==1) if eggs!=.
gen eggs_daily  = (eggs==1) if eggs!=.

* Fish
gen fish = s731f if round==5
replace fish = s726f if round==4
replace fish = s558f if round==3
replace fish = !inlist(s124g,3,4) if !missing(s124g) & round==2
gen fish_weekly = inlist(fish,1,2) if fish!=.
gen fish_daily  = (fish==1) if fish!=.

* Dairy
gen dairy = s731a if round==5
replace dairy = s726a if round==4
replace dairy = s558a if round==3
replace dairy = s124a if round==2
gen dairy_daily = (dairy==1) if dairy!=.

* Combined meat/egg/fish
gen meat_egg_fish_weekly = (meat_weekly==1 | eggs_weekly==1 | fish_weekly==1)
gen meat_egg_fish_daily  = (meat_daily==1  | eggs_daily==1  | fish_daily==1)


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


*==============================================================*
* 8. Birth Place
*==============================================================*

gen home_birth = inlist(m15_1,10,11,12,13) if !missing(m15_1)

gen mo_since_birth = v008-b3_01

gen home_birth_312 = home_birth if inrange(mo_since_birth,3,12)


* C-section
gen c_section = (v401==1) if !missing(v401)
gen c_section_312 = c_section if inrange(mo_since_birth,3,12)



* b3_01 date of birrth cmc
* v008 date of interview

*==============================================================*
* 9. Domestic Violence: Physical and Sexual
*==============================================================*

* Physical DV
local physvars d105a d105b d105c d105d d105e d105f d105j
gen dv_phys = .
foreach x of local physvars {
    replace dv_phys = 1 if inlist(`x',1,2,3,4)
    replace dv_phys = 0 if inlist(`x',0)
}
label variable dv_phys "Experienced physical domestic violence"

* Sexual DV
local sexvars d105h d105i d105k
gen dv_sex = .
foreach x of local sexvars {
    replace dv_sex = 1 if inlist(`x',1,2,3,4)
    replace dv_sex = 0 if inlist(`x',0)
}
label variable dv_sex "Experienced sexual domestic violence"

* NFHS-2 special handling
replace dv_phys = 0 if s515==0 & round==2
replace dv_phys = 1 if s516i==1 & round==2


**************************** GESTATIONAL DURATION ******************************

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

//months since last period is not reported for 1,274 women who also report pregnancy.  use self-reported "months pregnant" as a measure of gestational duration for those women.
//this allows us to assign a gestational duration for all but 5 women who report pregnancy.
count if moperiod==. & v213==1
gen gestdur = moperiod
replace gestdur = v214 if missing(moperiod) & v213==1
tab gestdur if v213==1, m

//create an appendix table to explain why we drop women who report 1, 2, or missing months of gestational duration.
tab gestdur if v213==1, m

//Create a variable "preg" to distinguish between the two groups.
gen preg = v213 == 1
tab preg, m


gen gestdur_3plus = gestdur>=3 if !missing(gestdur)

gen pregnant     = gestdur_3plus
gen not_pregnant = !pregnant

*==============================================================*
* 10. Anemia (Previous WHO Guidelines)
*==============================================================*

gen anemic = (v457!=4) if v457!=. & inlist(round,3,4,5)
gen severe = (v457==1) if v457!=. & inlist(round,3,4,5)

* NFHS-2: s902 (Hb × 10)
replace s902 = s902/10

* Any anemia
replace anemic = (s902 < 12) if round == 2 & pregnant == 0 & s902 < .   // non-pregnant
replace anemic = (s902 < 11) if round == 2 & pregnant == 1 & s902 < .   // pregnant

* Severe anemia
replace severe = (s902 < 8)  if round == 2 & pregnant == 0 & s902 < .   // non-pregnant
replace severe = (s902 < 7)  if round == 2 & pregnant == 1 & s902 < .   // pregnant


*==============================================================*
* 11. BMI
*==============================================================*

gen bmi = v445 if v445!=9998 & !missing(v445)
replace bmi = bmi/100
replace bmi = . if bmi > 60



* Compute z-score of v191 *within each round*
bysort round: egen v191_mean = mean(v191)
bysort round: egen v191_sd   = sd(v191)

gen wealth_z = (v191 - v191_mean) / v191_sd
label variable wealth_z "Wealth index z-score (round-specific)"

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


* Labels
label define grouplbl ///
    1 "Forward Caste" ///
    2 "OBC" ///
    3 "Dalit" ///
    4 "Adivasi" ///
    5 "Muslim" ///
    6 "Sikh, Jain, Christian"

label values group grouplbl





*==============================================================*
* 13. Save Stacked File
*==============================================================*

save $all_nfhs_ir, replace
