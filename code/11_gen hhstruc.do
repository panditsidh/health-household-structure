/*

This do file takes awhile to run
First it stacks  nfhs 1-5 household member recode
and uses that to figure out what household structure each household is
(based on who is there and who isn't)
then it merges this household level information to the stacked woman's individual file

*/


clear 

foreach file in nfhs3hmr nfhs4hmr nfhs5hmr {
	use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 hv115 using "${`file'}"
	tempfile `file'
	save ``file'', replace
} 

use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 hv115 using "${nfhs3hmr}", clear
append using "${nfhs4hmr}"
append using "${nfhs5hmr}"



* someone who is not child or spouse of the hh head
gen non_nuclear_member = !inlist(hv101,1,2,3,11)

* parent of household head
gen mother = hv101==6 & hv104==2
gen father = hv101==6 & hv104==1
gen parent = mother | father

* parent in law of household head
gen mil = hv101==7 & hv104==2
gen fil = hv101==7 & hv104==1
gen pil = mil | fil

* adult sibling in law of household head
gen sibil = hv101==15 & hv105>=18

* adult sibling of household head
gen sib = hv101==8  & hv105>=18

* other adult relative
gen other = hv101==10 & hv105>=18


gen nieceneph_adult = inlist(hv101,13,14,16) & hv105>=18

tab hv101, gen(rel)

foreach var in non_nuclear_member mother father parent mil fil pil sibil sib other {
	bysort hv000 hhid: egen has_`var' = max(`var')
}


foreach v of varlist rel* {
    bysort hv000 hhid: egen has_`v' = max(`v')
}


rename hv000 v000
rename hv001 v001 
rename hv002 v002



preserve

keep if hv104==1
keep if hv115==1
rename hvidx v034
keep v000 v001 v002 v034 hv101

duplicates drop v000 v001 v002 v034, force
tempfile husbands
save `husbands'
restore

keep v000 v001 v002 has*
duplicates drop v000 v001 v002, force
tempfile hr_combined
save `hr_combined'






* NFHS-3
use caseid s824b w124 v044 d* s46* v* s558a-s558g m15* d105* b3* bord* m14* using "${nfhs3ir}", clear
tempfile nfhs3
save `nfhs3'

* NFHS-5
use caseid s930b s932 s929 v743a* v044 d105a-d105j d129 s909 s910 s920 s116 v* ///
    s236 s220b* ssmod sb* sb18d sb25d sb29d sb18s sb25s sb29s sweight sdweight ///
    s731a-s731i m15* d105* b3* bord* m14* using "${nfhs5ir}", clear
tempfile nfhs5
save `nfhs5'

* NFHS-4
use caseid s928b s930 s927 v743a* v044 d105a-d105j d129 s907 s908 s116 v* ///
    s236 s220b* ssmod sb* sb16d sb23d sb27d sb16s sb23s sb27s ///
    sv005 sd005 s726a-s726i m15* d105* b3* bord* m14* using "${nfhs4ir}", clear

* Append NFHS-5, NFHS-3, NFHS-1, NFHS-2 to NFHS-4
append using `nfhs5'
append using `nfhs3'
append using "${nfhs1ir}"
append using "${nfhs2ir}"

merge m:1 v000 v001 v002 using `hr_combined', generate(hh_merge)

merge m:1 v000 v001 v002 v034 using `husbands', generate(husband_merge)
drop if husband_merge==2

***************** start from here ***********************
*********************************************************
// gen ever_married = v501!=0


* 281k households didn't match to a woman in the IR
drop if hh_merge==2


gen nuclear = 0
gen patrilocal = 0
gen natal = 0



* hh head is woman or her husband and nobody besides their children is present
replace nuclear = 1 if inlist(v150,1,2) & has_non_nuclear_member==0

* woman is dil of hh head
replace patrilocal = 1 if v150==4

* woman is hh head and has parent in law or sibling in law
replace patrilocal = 1 if v150==1 & (has_pil | has_sibil)

* hh head is husband & his parent, sibling, or other adult relative is present
replace patrilocal = 1 if v150==2 & (has_rel6==1 | has_sib==1 | has_other)

* woman is sister-in-law of hh head (so woman's brother or sister in law is the hh head)
replace patrilocal = 1 if v150==15 

* woman's husband is the grandchild of the household head
replace patrilocal = 1 if v150==10 & hv101==5

* woman is daughter of hh head
replace natal = 1 if (v150==3 | v150==11) & patrilocal!=1

* woman is sister of hh head
replace natal = 1 if v150==8 & patrilocal!=1

* woman is niece of hh head
replace natal = 1 if inlist(v150,13,16) & patrilocal!=1

* woman is hh head and her brother/parent is present
replace natal = 1 if v150==1 & (has_parent | has_sib) & patrilocal!=1

* woman is granddaughter of hh head
replace natal = 1 if v150==5 & patrilocal!=1

* woman is wife of hh head and her parents or sibling are present (???????)
replace natal = 1 if v150==2 & patrilocal!=1 & (has_pil | has_sibil)


gen other_extended = 0 

* wife of hh head, not patrilocal/nuclear/natal, and has younger-generation relatives
replace other_extended = 1 if v150==2 & !(patrilocal | nuclear | natal) & (has_rel4 | has_rel5) & (!has_parent)

* woman is hh head and her son/daughter in law or grandchild is present
replace other_extended = 1 if v150==1 & !(patrilocal | nuclear | natal) & (has_rel4 | has_rel5)

* woman is mother of hh head
replace other_extended = 1 if v150==6 & !(patrilocal | nuclear | natal)

* woman is mother in law of hh head
replace other_extended = 1 if v150==7 & !(patrilocal | nuclear | natal)

* woman is wife of hh head and her cospouse is present and hhstruc not already classified
gen unclassified_poly = 0 
replace unclassified_poly = 1 if v150==2 & !(patrilocal | nuclear | natal | other_extended) & (has_rel9)

* woman is hh head and her cospouse is present and hhstruc not already classified
replace unclassified_poly = 1 if v150==1 & !(patrilocal | nuclear | natal | other_extended) & (has_rel9)


* woman or husband is hh head and "not related" is present
gen shared = 0
replace shared = 1 if inlist(v150,1,2) & !(patrilocal | nuclear | natal | other_extended | unclassified_poly) & (has_rel12)

* woman is not related to household head
replace shared = 1 if v150==12

* woman is a domestic worker for household head
gen domestic_worker = 0
replace domestic_worker = 1 if v150==17

gen hh_struc = 1 if nuclear==1
replace hh_struc = 2 if patrilocal==1
replace hh_struc = 3 if natal==1
replace hh_struc = 4 if other_extended==1
replace hh_struc = 5 if unclassified_poly==1
replace hh_struc = 6 if domestic_worker==1

label variable hh_struc "Household Structure Type"
label define hh_struc_lbl1 1 "Nuclear" 2 "Patrilocal extended" 3 "Natal" 4 "Downwardly extended" 5 "Unclassified polygamous" 6 "Domestic worker"
label values hh_struc hh_struc_lbl1

gen missing_hhstruc = missing(hh_struc)

gen round = 3 if v000=="IA5"
replace round = 4 if v000=="IA6"
replace round = 5 if v000=="IA7"

