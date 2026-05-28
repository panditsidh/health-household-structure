
/*********************************************************************
0. Stack household member recode files
*********************************************************************/

clear

foreach file in nfhs3hmr nfhs4hmr nfhs5hmr {
    use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 hv115 using "${`file'}", clear
    tempfile `file'
    save ``file'', replace
}

use hvidx hv000 hv001 hv002 hhid hv101 hv104 hv105 hv115 using "${nfhs3hmr}", clear
append using `nfhs4hmr'
append using `nfhs5hmr'


/*********************************************************************
1. Create household-level indicators from HMR
*********************************************************************/

* Someone who is not the head, spouse, child, or adopted/foster child
gen non_nuclear_member = !inlist(hv101, 1, 2, 3, 11)

* Parent of household head
gen mother = hv101 == 6 & hv104 == 2
gen father = hv101 == 6 & hv104 == 1
gen parent = mother | father

* Parent-in-law of household head
gen mil = hv101 == 7 & hv104 == 2
gen fil = hv101 == 7 & hv104 == 1
gen pil = mil | fil

* Adult sibling-in-law of household head
gen sibil = hv101 == 15 & hv105 >= 18 if !missing(hv105)
replace sibil = 0 if missing(sibil)

* Adult sibling of household head
gen sib = hv101 == 8 & hv105 >= 18 if !missing(hv105)
replace sib = 0 if missing(sib)

* Other adult relative
gen other = hv101 == 10 & hv105 >= 18 if !missing(hv105)
replace other = 0 if missing(other)

* Adult niece/nephew categories
gen nieceneph_adult = inlist(hv101, 13, 14, 16) & hv105 >= 18 if !missing(hv105)
replace nieceneph_adult = 0 if missing(nieceneph_adult)

* Explicit relationship-code indicators
foreach r in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 98 {
    gen rel`r' = hv101 == `r'
}


/*********************************************************************
2. Collapse indicators to household level
*********************************************************************/

foreach var in non_nuclear_member mother father parent mil fil pil sibil sib other nieceneph_adult {
    bysort hv000 hv001 hv002: egen has_`var' = max(`var')
}

foreach r in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 98 {
    bysort hv000 hv001 hv002: egen has_rel`r' = max(rel`r')
}

rename hv000 v000
rename hv001 v001
rename hv002 v002

keep v000 v001 v002 has_*
duplicates drop v000 v001 v002, force

tempfile hr_combined
save `hr_combined', replace


/*********************************************************************
3. Stack men's recode files
*********************************************************************/

* NFHS-5
use "/Users/sidhpandit/Desktop/data/nfhs/nfhs5mr/IAMR7EFL.DTA", clear
tempfile nfhs5mr
save `nfhs5mr', replace

* NFHS-4
use "/Users/sidhpandit/Desktop/data/nfhs/nfhs4mr/IAMR74FL.DTA", clear
tempfile nfhs4mr
save `nfhs4mr', replace

* NFHS-3
use "/Users/sidhpandit/Desktop/data/nfhs/nfhs3mr/IAMR52FL.dta", clear
append using `nfhs4mr'
append using `nfhs5mr'


/*********************************************************************
4. Harmonize IDs and merge household-level indicators
*********************************************************************/

rename mv000 v000
rename mv001 v001
rename mv002 v002

merge m:1 v000 v001 v002 using `hr_combined', generate(hh_merge)

drop if hh_merge == 2
keep if hh_merge == 3
drop hh_merge


/*********************************************************************
5. Survey round
*********************************************************************/

gen round = .
replace round = 3 if v000 == "IA5"
replace round = 4 if v000 == "IA6"
replace round = 5 if v000 == "IA7"

label define roundlbl ///
    3 "2005-2006" ///
    4 "2015-2016" ///
    5 "2019-2021"

label values round roundlbl


/*********************************************************************
6. Sample indicators
*********************************************************************/

* Men who report wife/partner is currently pregnant
gen wife_pregnant = mv213 == 1 if !missing(mv213)
label var wife_pregnant "Man reports wife/partner is pregnant"

* Man is usual resident of interviewed household
gen man_usual_resident = mv135 == 1 if !missing(mv135)
label var man_usual_resident "Man is usual resident of interviewed HH"

* Man is visitor to interviewed household
gen man_visitor = mv135 == 2 if !missing(mv135)
label var man_visitor "Man is visitor to interviewed HH"


/*********************************************************************
7. Intermediate categories for men's household structure

These are used only to construct hh_struc_men.
*********************************************************************/

gen men_nuclear = 0
gen men_patrilocal = 0


/***** Nuclear *****/

* Man is head or spouse of head and no non-nuclear members are present
replace men_nuclear = 1 if inlist(mv150, 1, 2) & has_non_nuclear_member == 0


/***** Patrilocal extended from pregnant wife's perspective *****/

* Man is son/adopted son of household head.
* His wife would be daughter-in-law of the head.
replace men_patrilocal = 1 if inlist(mv150, 3, 11)

* Man is grandchild of household head.
replace men_patrilocal = 1 if mv150 == 5

* Man is brother of household head.
replace men_patrilocal = 1 if mv150 == 8

* Man is nephew of household head.
replace men_patrilocal = 1 if inlist(mv150, 13, 16)

* Man is brother-in-law of household head.
replace men_patrilocal = 1 if mv150 == 15

* Man is household head and his own parent, sibling, or adult relative is present.
replace men_patrilocal = 1 if mv150 == 1 ///
    & (has_parent | has_sib | has_other | has_nieceneph_adult)

* Man is spouse of household head and his own parents/siblings are present.
replace men_patrilocal = 1 if mv150 == 2 ///
    & (has_pil | has_sibil | has_nieceneph_adult)

* Man is other relative of household head.
replace men_patrilocal = 1 if mv150 == 10 & men_nuclear != 1


/*********************************************************************
8. Final men's household structure variable
*********************************************************************/

gen hh_struc_men = .

* Visitor gets priority because the graph separates visitors.
replace hh_struc_men = 4 if man_visitor == 1

* Usual resident in wife's natal household.
* For male respondent, mv150==4 means son-in-law / child-in-law of head.
replace hh_struc_men = 3 if missing(hh_struc_men) ///
    & man_usual_resident == 1 ///
    & mv150 == 4

* Usual resident of nuclear household.
replace hh_struc_men = 2 if missing(hh_struc_men) ///
    & man_usual_resident == 1 ///
    & men_nuclear == 1

* Usual resident of patrilocal extended household.
replace hh_struc_men = 1 if missing(hh_struc_men) ///
    & man_usual_resident == 1 ///
    & men_patrilocal == 1

* Other.
replace hh_struc_men = 5 if missing(hh_struc_men)

label define hh_struc_men_lbl ///
    1 "Usual resident: patrilocal extended" ///
    2 "Usual resident: nuclear" ///
    3 "Usual resident: wife's natal HH" ///
    4 "Visitor to interviewed HH" ///
    5 "Other"

label values hh_struc_men hh_struc_men_lbl
label var hh_struc_men "Household structure among men with pregnant wives"


/*********************************************************************
9. Tabulate result
*********************************************************************/

bys round: tab hh_struc_men [aw=mv005] if wife_pregnant == 1


/*********************************************************************
10. Create 0/100 indicators for stacked bar figure
*********************************************************************/

gen hm_pat = 100 * (hh_struc_men == 1) if wife_pregnant == 1
gen hm_nuc = 100 * (hh_struc_men == 2) if wife_pregnant == 1
gen hm_wifenatal = 100 * (hh_struc_men == 3) if wife_pregnant == 1
gen hm_visitor = 100 * (hh_struc_men == 4) if wife_pregnant == 1
gen hm_other = 100 * (hh_struc_men == 5) if wife_pregnant == 1


/*********************************************************************
11. Graph men's household structure among men with pregnant wives

Variables are ordered so that the legend order matches the visual
top-to-bottom order of the stacked bars.
*********************************************************************/

graph bar (mean) hm_other hm_visitor hm_wifenatal hm_nuc hm_pat [aw=mv005] ///
    if wife_pregnant == 1, ///
    over(round, label(angle(0))) ///
    stack ///
    ytitle("Percent") ///
    ylabel(0(20)100, angle(0)) ///
    blabel(bar, format(%4.1f) size(vsmall) position(center)) ///
    legend(order(5 "Usual resident: patrilocal extended" ///
                 4 "Usual resident: nuclear" ///
                 3 "Usual resident: wife's natal HH" ///
                 2 "Visitor to interviewed HH" ///
                 1 "Other") ///
           rows(5) size(small) pos(6)) ///
    bar(5, color(gs8)  fintensity(75) lcolor(none)) ///
    bar(4, color(gs11) fintensity(65) lcolor(none)) ///
    bar(3, color(gs15) fintensity(100) lcolor(none)) ///
    bar(2, color(gs10) fintensity(35) lcolor(none)) ///
    bar(1, color(gs6)  fintensity(45) lcolor(none)) ///
    ysize(9) xsize(5)

graph export "figures/apdx bar graph three panel men.png", as(png) replace
