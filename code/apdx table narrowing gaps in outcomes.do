clear
set more off

use $all_nfhs_ir, clear

keep if inlist(round,3,4,5)
keep if ever_married==1
keep if inlist(hh_struc,1,2)

*******************************************************
* 1) Create samples and variables
*******************************************************

gen nfhs3to4 = inlist(round,3,4)
gen nfhs4to5 = inlist(round,4,5)
gen all_nfhs = 1

* postpartum sample

* facility birth
capture drop facility_birth
gen facility_birth = (home_birth==0) if !missing(home_birth)


*******************************************************
* 2) Post results
*******************************************************

tempfile results
capture postclose hh
postfile hh ///
    str30 outcome ///
    str20 column ///
    double b se p ///
    using `results', replace

	
*******************************************************
* 3) Loop over outcomes first, then samples
*******************************************************

foreach outcome in nosay_healthcare nosay_visits facility_birth anc_four {

    foreach sample in nfhs3to4 nfhs4to5 all_nfhs {

        preserve
        keep if `sample'==1

        * choose sample + weights depending on outcome
        if inlist("`outcome'","nosay_healthcare","nosay_visits") {
            local ifcond "pregnant==1"
            local wt "[aw=w_state]"
        }
        else {
            local ifcond "postpartum==1"
            local wt "[aw=v005]"
        }

        quietly reghdfe `outcome' i.round##i.patrilocal i.wealth_group ///
            `wt' if `ifcond', cluster(psu) absorb(v024)

        matrix M = r(table)

        *-------------------------------
        * Pairwise 3 -> 4
        *-------------------------------
        if "`sample'"=="nfhs3to4" {
            local c = colnumb(M,"4.round#1.patrilocal")
            post hh ("`outcome'") ("NFHS-3 to 4") ///
                (M[1,`c']) (M[2,`c']) (M[4,`c'])
        }

        *-------------------------------
        * Pairwise 4 -> 5
        *-------------------------------
        if "`sample'"=="nfhs4to5" {
            local c = colnumb(M,"5.round#1.patrilocal")
            post hh ("`outcome'") ("NFHS-4 to 5") ///
                (M[1,`c']) (M[2,`c']) (M[4,`c'])
        }

        *-------------------------------
        * Stacked (all rounds)
        *-------------------------------
        if "`sample'"=="all_nfhs" {
            local c4 = colnumb(M,"4.round#1.patrilocal")
            local c5 = colnumb(M,"5.round#1.patrilocal")

            post hh ("`outcome'") ("Stacked: 3 to 4") ///
                (M[1,`c4']) (M[2,`c4']) (M[4,`c4'])

            post hh ("`outcome'") ("Stacked: 3 to 5") ///
                (M[1,`c5']) (M[2,`c5']) (M[4,`c5'])
        }

        restore
    }
}

postclose hh
use `results', clear	
// *******************************************************
// * 3) Loop over samples and outcomes
// *******************************************************
//
// foreach sample in nfhs3to4 nfhs4to5 all_nfhs {
//
//     preserve
//     keep if `sample'==1
//
//     foreach outcome in nosay_healthcare nosay_visits {
//
//         quietly reghdfe `outcome' i.round##i.patrilocal i.wealth_group ///
//             [aw=w_state] if pregnant==1, cluster(psu) absorb(v024)
//
//         matrix M = r(table)
//
//         * pairwise 3->4
//         if "`sample'"=="nfhs3to4" {
//             local c = colnumb(M,"4.round#1.patrilocal")
//             post hh ("`outcome'") ("NFHS-3 to 4") ///
//                 (M[1,`c']) (M[2,`c']) (M[4,`c'])
//         }
//
//         * pairwise 4->5
//         if "`sample'"=="nfhs4to5" {
//             local c = colnumb(M,"5.round#1.patrilocal")
//             post hh ("`outcome'") ("NFHS-4 to 5") ///
//                 (M[1,`c']) (M[2,`c']) (M[4,`c'])
//         }
//
//         * stacked all 3 rounds: report both interactions
//         if "`sample'"=="all_nfhs" {
//             local c4 = colnumb(M,"4.round#1.patrilocal")
//             local c5 = colnumb(M,"5.round#1.patrilocal")
//
//             post hh ("`outcome'") ("Stacked: 3 to 4") ///
//                 (M[1,`c4']) (M[2,`c4']) (M[4,`c4'])
//
//             post hh ("`outcome'") ("Stacked: 3 to 5") ///
//                 (M[1,`c5']) (M[2,`c5']) (M[4,`c5'])
//         }
//     }
//
//     foreach outcome in facility_birth anc_four {
//
//         quietly reghdfe `outcome' i.round##i.patrilocal i.wealth_group ///
//             [aw=v005] if postpartum==1, cluster(psu) absorb(v024)
//
//         matrix M = r(table)
//
//         * pairwise 3->4
//         if "`sample'"=="nfhs3to4" {
//             local c = colnumb(M,"4.round#1.patrilocal")
//             post hh ("`outcome'") ("NFHS-3 to 4") ///
//                 (M[1,`c']) (M[2,`c']) (M[4,`c'])
//         }
//
//         * pairwise 4->5
//         if "`sample'"=="nfhs4to5" {
//             local c = colnumb(M,"5.round#1.patrilocal")
//             post hh ("`outcome'") ("NFHS-4 to 5") ///
//                 (M[1,`c']) (M[2,`c']) (M[4,`c'])
//         }
//
//         * stacked all 3 rounds
//         if "`sample'"=="all_nfhs" {
//             local c4 = colnumb(M,"4.round#1.patrilocal")
//             local c5 = colnumb(M,"5.round#1.patrilocal")
//
//             post hh ("`outcome'") ("Stacked: 3 to 4") ///
//                 (M[1,`c4']) (M[2,`c4']) (M[4,`c4'])
//
//             post hh ("`outcome'") ("Stacked: 3 to 5") ///
//                 (M[1,`c5']) (M[2,`c5']) (M[4,`c5'])
//         }
//     }
//
//     restore
// }
//
// postclose hh
// use `results', clear
//
*******************************************************
* 4) Label outcomes and format coeffs
*******************************************************

replace outcome = "No say in own healthcare"            if outcome=="nosay_healthcare"
replace outcome = "No say in visits to family/friends"  if outcome=="nosay_visits"
replace outcome = "Gave birth in a health facility"     if outcome=="facility_birth"
replace outcome = "Had 4+ antenatal visits"             if outcome=="anc_four"

gen stars = ""
replace stars = "***" if p < 0.01
replace stars = "**"  if p < 0.05 & p >= 0.01
replace stars = "*"   if p < 0.10 & p >= 0.05

gen cell = string(b,"%9.3f") + stars
gen secell = "(" + string(se,"%9.3f") + ")"

*******************************************************
* 5) Reshape to wide
*******************************************************

gen colkey = ""
replace colkey = "y0506to1516"   if column=="NFHS-3 to 4"
replace colkey = "y1516to1921"   if column=="NFHS-4 to 5"
replace colkey = "stack0506to1516" if column=="Stacked: 3 to 4"
replace colkey = "stack0506to1921" if column=="Stacked: 3 to 5"

tempfile coefs

preserve
    keep outcome colkey cell
    reshape wide cell, i(outcome) j(colkey) string
    save `coefs'
restore

keep outcome colkey secell
reshape wide secell, i(outcome) j(colkey) string
merge 1:1 outcome using `coefs', nogen

*******************************************************
* 6) Order rows
*******************************************************

gen order = .
replace order = 1 if outcome=="No say in own healthcare"
replace order = 2 if outcome=="No say in visits to family/friends"
replace order = 3 if outcome=="Gave birth in a health facility"
replace order = 4 if outcome=="Had 4+ antenatal visits"
sort order

expand 2
bys outcome: gen line = _n

gen rowlabel = outcome if line==1
replace rowlabel = "" if line==2

gen c1 = celly0506to1516 if line==1
replace c1 = secelly0506to1516 if line==2

gen c2 = celly1516to1921 if line==1
replace c2 = secelly1516to1921 if line==2

gen c3 = cellstack0506to1516 if line==1
replace c3 = secellstack0506to1516 if line==2

gen c4 = cellstack0506to1921 if line==1
replace c4 = secellstack0506to1921 if line==2

*******************************************************
* 7) Export LaTeX table
*******************************************************
#delimit ;
listtex rowlabel c1 c2 c3 c4 using "tables/interaction_gap_table.tex", replace ///
    rstyle(tabular) ///
    head( ///
        "\begin{tabular}{lcccc}" ///
        "\toprule" ///
        " & \multicolumn{1}{c}{\shortstack{2005--2006\\to\\2015--2016}} & \multicolumn{1}{c}{\shortstack{2015--2016\\to\\2019--2021}} & \multicolumn{1}{c}{\shortstack{Stacked\\2005--2006\\to\\2015--2016}} & \multicolumn{1}{c}{\shortstack{Stacked\\2005--2006\\to\\2019--2021}} \\\\" ///
        "\midrule" ///
    ) ///
    foot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
    );
#delimit cr

*******************************************************
* 8) Also show in Stata
*******************************************************

list rowlabel c1 c2 c3 c4, noobs sepby(order)
