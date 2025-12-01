*------------------------------------------------------------
* Table: % patrilocal among pregnant women, NFHS-3/4/5
* by region, group, v025, v013 + significance (3 vs 5)
*------------------------------------------------------------

set more off

* Start from your big IR file
use $all_nfhs_ir, clear

* Keep only what we need and restrict sample
keep patrilocal wt round region group v025 v013 pregnant
keep if pregnant == 1 & inlist(round, 3, 4, 5)

*------------------------------------------------------------
* Set up postfile
*------------------------------------------------------------

capture postclose handle

tempfile results
postfile handle ///
    str20 panel ///      // which variable: region, group, v025, v013
    str30 category ///   // value label or section header
    str12 NFHS3 ///
    str12 NFHS4 ///
    str12 NFHS5 ///
    str12 significance ///
    using `results', replace

* Over-variables to loop over
local overvars "region group v025 v013"

*------------------------------------------------------------
* Main loop
*------------------------------------------------------------

foreach ov of local overvars {

    di "Processing `ov' ..."

    * ---------- Section header row for this panel ----------
    local hdr ""
    if "`ov'" == "region" local hdr "\textbf{Region}"
    if "`ov'" == "group"  local hdr "\textbf{Social group}"
    if "`ov'" == "v025"   local hdr "\textbf{Residence}"
    if "`ov'" == "v013"   local hdr "\textbf{Age group}"

    * post a blank row with only the header in 'category'
    post handle ("`ov'") ("`hdr'") ("") ("") ("") ("")
    * -------------------------------------------------------

    * Get the levels that actually appear in this restricted sample
    levelsof `ov', local(levels)

    foreach lvl of local levels {

        * Reset strings for this subgroup
        local s3 ""
        local s4 ""
        local s5 ""
        local sig ""

        * ---- Means for each round ----
        foreach r in 3 4 5 {
            quietly summarize patrilocal [aw=wt] ///
                if round==`r' & `ov'==`lvl'

            if r(N) > 0 {
                local m`r' = r(mean)*100
                local s`r' : display %4.1f `m`r''
            }
        }

        * ---- Significance: NFHS-3 vs NFHS-5 ----
        quietly regress patrilocal i.round ///
            if inlist(round,3,5) & `ov'==`lvl' [aw=wt]

        capture noisily lincom 5.round - 3.round
        if _rc == 0 {
            local p = r(p)
            if `p' < 0.10 local sig "*"
            if `p' < 0.05 local sig "**"
            if `p' < 0.01 local sig "***"
        }

        * ---- Category label ----
        local lbl : label (`ov') `lvl'
        if "`lbl'" == "" local lbl "`ov'=`lvl'"

        * ---- Post one row ----
        post handle ("`ov'") ("`lbl'") ("`s3'") ("`s4'") ("`s5'") ("`sig'")
    }
}

*------------------------------------------------------------
* Close and look
*------------------------------------------------------------

postclose handle

use `results', clear
order panel category NFHS3 NFHS4 NFHS5 significance
list, sepby(panel)


// use $all_nfhs_ir, clear
//
// drop if v013==0
// keep if pregnant==1
//
// capture postclose handle
//
// tempfile results
// postfile handle ///
//     str20 panel ///   // which overvar: region / group / v025 / v013
//     str30 category ///   // value label: e.g. "North", "Rural", "15-19"
//     str12 NFHS3  ///
//     str12 NFHS4  ///
//     str12 NFHS5  ///
//     str12 significance ///
//     using `results', replace
//
// * define the over-variables
// local overvars "region group v025 v013"
//
// foreach overvar of local overvars {
//
//     * restrict levelsof to observations actually used
//     levelsof `overvar' if pregnant==1 & inlist(round,3,4,5), local(levels)
//
//     foreach i of local levels {
//
//         * reset strings each subgroup
//         local s3 ""
//         local s4 ""
//         local s5 ""
//         local sig ""
//
//         * loop over rounds
//         foreach r in 3 4 5 {
//
//             quietly summarize patrilocal [aw=wt] ///
//                 if round==`r' & `overvar'==`i' & pregnant==1
//
//             if r(N) > 0 {
//                 local m`r' = r(mean)*100
//                 local s`r' : display %4.1f `m`r''
//             }
//         }
//
//         * test change between NFHS-3 and NFHS-5
//         quietly regress patrilocal i.round ///
//             if inlist(round,3,5) & `overvar'==`i' & pregnant==1 [aw=wt]
//
//         capture noisily lincom 5.round - 3.round
//         if _rc==0 {
//             local p = r(p)
//             if `p' < 0.10 local sig "*"
//             if `p' < 0.05 local sig "**"
//             if `p' < 0.01 local sig "***"
//         }
//
//         * get value label for category, or fallback to "var=code"
//         local lbl : label (`overvar') `i'
//         if "`lbl'" == "" local lbl "`overvar'=`i'"
//
//         post handle ("`overvar'") ("`lbl'") ("`s3'") ("`s4'") ("`s5'") ("`sig'")
//     }
// }
//
// postclose handle
//
// use `results', clear
// list, sepby(panel)
