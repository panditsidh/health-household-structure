* we don't use any of these variables anymore, they were there for previous analysis. we can move it to "old"

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
* health utilization variables asked of everyone

gen prob_facility_distance = inlist(v467d,1,2)
gen prob_health_permission = inlist(v467b,1,2)
gen prob_health_money = inlist(v467c,1,2)

*==============================================================*
* 3. Attitudes Toward Wife Beating
*==============================================================*

egen beating_justified = anymatch(s514a-s514f), values(1)
replace beating_justified = . if missing(s514a)

egen beating_justified_nfhs345 = anymatch(v744a-v744e), values(1)
replace beating_justified       = beating_justified_nfhs345 if inlist(round,3,4,5)
replace beating_justified       = . if v044!=1 & inlist(round,3,4,5)



gen nosay_purchases = .
replace nosay_purchases = !inlist(s511c,1,3,5) if round==2 & !missing(s511c)
replace nosay_purchases = !inlist(v743b,1,2,3) if !missing(v743b) & inlist(round,3,4,5)

* Own earnings
gen nosay_ownearnings = .
replace nosay_ownearnings = !inlist(v739,1,2,3) if !missing(v739)

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

gen public = inlist(m15_1,20,21,22,23,24,25,26,27) if !missing(m15_1)
label var public "Delivery in public facility"

gen private = inlist(m15_1,30,31,32,33) if !missing(m15_1)
label var private "Delivery in private facility"

gen public_312 = public  if inrange(mo_since_birth,3,12)
gen private_312 = private  if inrange(mo_since_birth,3,12)

* C-section
gen c_section = (v401==1) if !missing(v401)
gen c_section_312 = c_section if inrange(mo_since_birth,3,12)


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

gen underweight = bmi<18.5
gen overweight = bmi>25 
gen obesity = bmi>30


regress bmi i.gestdur [aw=wt]
predict bmi_resid, resid


* Compute z-score of v191 *within each round*
bysort round: egen v191_mean = mean(v191)
bysort round: egen v191_sd   = sd(v191)

gen wealth_z = (v191 - v191_mean) / v191_sd
label variable wealth_z "Wealth index z-score (round-specific)"
