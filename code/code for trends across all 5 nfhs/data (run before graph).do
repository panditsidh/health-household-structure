/*

This file constructs household structure for NFHS-1 and NFHS-2 and appends
these observations to the existing NFHS-3 through NFHS-5 analytic dataset.

Household structure is constructed using the same definitions used for later
NFHS rounds wherever the older surveys permit.

NFHS-1 and NFHS-2 do not contain the husband roster-line variable v034 used
in later rounds. Therefore, the classification rule that identifies a woman
as patrilocal based specifically on her husband's relationship to the
household head is not used for NFHS-1 or NFHS-2.

The file DOES NOT save or overwrite $all_nfhs_ir. At the end of the file,
the combined NFHS-1 through NFHS-5 dataset remains in memory.

*/


clear

do "$paths"



*******************************************************
* Paths for NFHS-1 and NFHS-2
*******************************************************

local nfhs1hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs1hmr/IAPR23FL.DTA"
local nfhs2hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs2hmr/IAPR42FL.DTA"

local nfhs1ir  "/Users/sidhpandit/Desktop/data/nfhs/nfhs1ir/IAIR23FL.DTA"
local nfhs2ir  "/Users/sidhpandit/Desktop/data/nfhs/nfhs2ir/IAIR42FL.DTA"



*******************************************************
* 1. Stack NFHS-1 and NFHS-2 household member recodes
*******************************************************

use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 ///
    using "`nfhs1hmr'", clear

gen round = 1

tempfile nfhs1hmr_temp
save `nfhs1hmr_temp'


use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 ///
    using "`nfhs2hmr'", clear

gen round = 2

append using `nfhs1hmr_temp'



*******************************************************
* Check relationship coding across the two rounds
*******************************************************

tab hv101 round, missing
tab hv104 round, missing



*******************************************************
* 2. Tag each household member's relation to household head
*******************************************************

* someone who is not household head, spouse, child, or foster child
gen non_nuclear_member = !inlist(hv101,1,2,3,11) if !missing(hv101)


* parent of household head
gen mother = hv101==6 & hv104==2
gen father = hv101==6 & hv104==1
gen parent = mother | father


* parent-in-law of household head
gen mil = hv101==7 & hv104==2
gen fil = hv101==7 & hv104==1
gen pil = mil | fil


* adult sibling of household head
gen sib = hv101==8 & hv105>=18 & hv105<.


* other adult relative
gen other = hv101==10 & hv105>=18 & hv105<.


*******************************************************
* Relationship indicators
*
* NFHS-1 and NFHS-2 only distinguish relationship
* categories 1-12, so there is no separate sibling-in-law
* category as in later rounds.
*******************************************************

tab hv101, gen(rel)



*******************************************************
* 3. Collapse member characteristics to household level
*******************************************************

foreach var in non_nuclear_member mother father parent mil fil pil sib other {

    bysort round hv000 hhid: egen has_`var' = max(`var')

}


foreach v of varlist rel* {

    bysort round hv000 hhid: egen has_`v' = max(`v')

}



*******************************************************
* Keep one observation per household
*******************************************************

keep round hv000 hv001 hv002 has*

duplicates drop round hv000 hv001 hv002, force

rename hv000 v000
rename hv001 v001
rename hv002 v002


* verify merge key is unique
isid round v000 v001 v002


tempfile hh_nfhs12
save `hh_nfhs12'

*******************************************************
* 4. Stack NFHS-1 and NFHS-2 individual recodes
*******************************************************

use "`nfhs1ir'", clear

gen round = 1

tempfile nfhs1ir_temp
save `nfhs1ir_temp'


use "`nfhs2ir'", clear

gen round = 2

append using `nfhs1ir_temp'



*******************************************************
* Check key variables
*******************************************************

describe v000 v001 v002 v150 v501 v005 v012 v213 v214

tab v150 round, missing



*******************************************************
* 5. Merge household composition onto women's records
*******************************************************

merge m:1 round v000 v001 v002 using `hh_nfhs12', ///
    generate(hh_merge)

tab round hh_merge, missing


* household-member records with no corresponding interviewed woman
drop if hh_merge==2



*******************************************************
* 6. Code household structure
*******************************************************

gen nuclear    = 0
gen patrilocal = 0
gen natal      = 0



*******************************************************
* Nuclear
*******************************************************

* woman or husband is household head and nobody besides
* the household head, spouse, children, or foster children is present

replace nuclear = 1 if inlist(v150,1,2) & ///
    has_non_nuclear_member==0



*******************************************************
* Patrilocal extended
*******************************************************

* woman is daughter-in-law of household head
replace patrilocal = 1 if v150==4


* woman is household head and parent-in-law is present
replace patrilocal = 1 if v150==1 & ///
    has_pil==1


* husband is household head and his parent, sibling,
* or another adult relative is present
replace patrilocal = 1 if v150==2 & ///
    (has_rel6==1 | has_sib==1 | has_other==1)


*******************************************************
* NOTE:
*
* In NFHS-3 through NFHS-5 we also classify some women
* using the husband's own relationship to the household
* head. That requires v034, which is not available in
* NFHS-1/2, so that rule is omitted here.
*******************************************************



*******************************************************
* Natal
*******************************************************

* woman is daughter / adopted daughter of household head
replace natal = 1 if inlist(v150,3,11) & ///
    patrilocal!=1


* woman is sister of household head
replace natal = 1 if v150==8 & ///
    patrilocal!=1


* woman is granddaughter of household head
replace natal = 1 if v150==5 & ///
    patrilocal!=1


* woman is household head and her parent or sibling is present
replace natal = 1 if v150==1 & ///
    (has_parent==1 | has_sib==1) & ///
    patrilocal!=1


* woman's husband is household head and his parent-in-law
* is present, i.e. the woman's parent is present
replace natal = 1 if v150==2 & ///
    has_pil==1 & ///
    patrilocal!=1



*******************************************************
* 7. Other extended households
*******************************************************

gen other_extended = 0


* wife of household head with son/daughter-in-law or grandchild
replace other_extended = 1 if v150==2 & ///
    !(patrilocal | nuclear | natal) & ///
    (has_rel4==1 | has_rel5==1) & ///
    has_parent!=1


* woman is household head with son/daughter-in-law or grandchild
replace other_extended = 1 if v150==1 & ///
    !(patrilocal | nuclear | natal) & ///
    (has_rel4==1 | has_rel5==1)


* woman is parent of household head
replace other_extended = 1 if v150==6 & ///
    !(patrilocal | nuclear | natal)


* woman is parent-in-law of household head
replace other_extended = 1 if v150==7 & ///
    !(patrilocal | nuclear | natal)



*******************************************************
* 8. Polygamous households
*******************************************************

gen unclassified_poly = 0


replace unclassified_poly = 1 if v150==2 & ///
    !(patrilocal | nuclear | natal | other_extended) & ///
    has_rel9==1


replace unclassified_poly = 1 if v150==1 & ///
    !(patrilocal | nuclear | natal | other_extended) & ///
    has_rel9==1



*******************************************************
* 9. Shared / unrelated households
*******************************************************

gen shared = 0


replace shared = 1 if inlist(v150,1,2) & ///
    !(patrilocal | nuclear | natal | other_extended | unclassified_poly) & ///
    has_rel12==1


replace shared = 1 if v150==12



*******************************************************
* 10. Final household structure variable
*******************************************************

gen hh_struc = 1 if nuclear==1

replace hh_struc = 2 if patrilocal==1
replace hh_struc = 3 if natal==1
replace hh_struc = 4 if other_extended==1
replace hh_struc = 5 if unclassified_poly==1


label variable hh_struc "Household Structure Type"

label define hh_struc_lbl1 ///
    1 "Nuclear" ///
    2 "Patrilocal extended" ///
    3 "Natal" ///
    4 "Downwardly extended" ///
    5 "Unclassified polygamous", replace

label values hh_struc hh_struc_lbl1


gen missing_hhstruc = missing(hh_struc)



*******************************************************
* Check mutual exclusivity of main household structures
*******************************************************

egen main_hh_total = rowtotal(nuclear patrilocal natal)

tab main_hh_total round, missing

assert main_hh_total<=1

drop main_hh_total



*******************************************************
* 11. Ever-married
*******************************************************

gen ever_married = v501!=0 if !missing(v501)



*******************************************************
* 12. Pregnancy
*******************************************************

* First try to construct gestational duration from v215,
* following the NFHS-3 through NFHS-5 code.

gen moperiod = .


capture confirm variable v215

if !_rc {

    replace moperiod = 1 if v215>=101 & v215<=128
    replace moperiod = 2 if v215>=129 & v215<=156
    replace moperiod = 3 if v215>=157 & v215<=184
    replace moperiod = 4 if v215>=185 & v215<=198

    replace moperiod = 1 if v215>=201 & v215<=204
    replace moperiod = 2 if v215>=205 & v215<=208
    replace moperiod = 3 if v215>=209 & v215<=213

    replace moperiod = 1  if v215==301
    replace moperiod = 2  if v215==302
    replace moperiod = 3  if v215==303
    replace moperiod = 4  if v215==304
    replace moperiod = 5  if v215==305
    replace moperiod = 6  if v215==306
    replace moperiod = 7  if v215==307
    replace moperiod = 8  if v215==308
    replace moperiod = 9  if v215==309
    replace moperiod = 10 if v215==310
    replace moperiod = 11 if v215==311

}


* otherwise use self-reported months pregnant
gen gestdur = moperiod if v213==1

replace gestdur = v214 if missing(gestdur) & v213==1


* match the later-round analytic definition:
* currently pregnant and at least 3 months pregnant

gen gestdur_3plus = gestdur>=3 if ///
    !missing(gestdur) & v213==1


gen pregnant = v213

replace pregnant = gestdur_3plus if v213==1


gen not_pregnant = !pregnant if !missing(pregnant)



*******************************************************
* 13. Natal usual resident / visitor
*******************************************************

capture confirm variable v135

if !_rc {

    gen usual_resident = v135==1 if inlist(v135,1,2)
    gen visitor        = v135==2 if inlist(v135,1,2)

    gen natal_usual_resident = ///
        natal==1 & usual_resident==1 if inlist(v135,1,2)

    gen natal_visitor = ///
        natal==1 & visitor==1 if inlist(v135,1,2)

}
else {

    gen usual_resident = .
    gen visitor = .
    gen natal_usual_resident = .
    gen natal_visitor = .

}



*******************************************************
* 14. Check NFHS-1 and NFHS-2 before appending
*******************************************************

tab round

tab hh_struc round, column missing

tab pregnant round, missing


preserve

keep if ever_married==1
keep if pregnant==1
keep if inlist(hh_struc,1,2,3)

tab hh_struc round [aw=v005], column

restore



*******************************************************
* Hold NFHS-1 and NFHS-2 temporarily
*******************************************************

tempfile nfhs12
save `nfhs12'



*******************************************************
* 15. Bring in existing NFHS-3 through NFHS-5 dataset
*******************************************************

use "$all_nfhs_ir", clear


* in case this code is rerun on a dataset that already
* contains rounds 1 or 2
drop if inlist(round,1,2)


append using `nfhs12'



*******************************************************
* 16. Harmonize round labels
*******************************************************

label define roundlbl ///
    1 "1992–93" ///
    2 "1998–99" ///
    3 "2005–2006" ///
    4 "2015–2016" ///
    5 "2019–2021", replace

label values round roundlbl



*******************************************************
* 17. Recreate survey design variables across all rounds
*******************************************************

capture drop strata
capture drop psu
capture drop totalwt
capture drop wt


egen strata = group(v000 v024 v025)

egen psu = group(v000 v001 v024 v025)


bysort v000: egen totalwt = total(v005)

gen wt = v005 / totalwt



*******************************************************
* 18. Final checks
*******************************************************

tab round

tab hh_struc round, column missing


preserve

keep if ever_married==1
keep if pregnant==1
keep if inlist(hh_struc,1,2,3)

tab hh_struc round [aw=wt], column

restore



*******************************************************
* END
*
* Nothing is saved here.
* The combined NFHS-1 through NFHS-5 dataset remains
* in memory for the figure code that follows.
*******************************************************
